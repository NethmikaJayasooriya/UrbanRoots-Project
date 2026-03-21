import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';
import 'leaf_disease_screen.dart';

// ═══════════════════════════════════════════════
// Scan History Model
// ═══════════════════════════════════════════════
class ScanRecord {
  final String id;
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final String severity;
  final DateTime scannedAt;
  final bool isHealthy;

  ScanRecord({
    required this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.scannedAt,
    required this.isHealthy,
  });

  // Convert to JSON to save in SharedPreferences
  Map<String, dynamic> toJson() => {
        'id':          id,
        'imagePath':   imagePath,
        'diseaseName': diseaseName,
        'confidence':  confidence,
        'severity':    severity,
        'scannedAt':   scannedAt.toIso8601String(),
        'isHealthy':   isHealthy,
      };

  // Create from saved JSON
  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id:          json['id'],
        imagePath:   json['imagePath'],
        diseaseName: json['diseaseName'],
        confidence:  json['confidence'],
        severity:    json['severity'],
        scannedAt:   DateTime.parse(json['scannedAt']),
        isHealthy:   json['isHealthy'] ?? false,
      );

  // ✅ Severity color via AppSeverity helper
  Color get severityColor => AppSeverity.color(severity);
}

// ═══════════════════════════════════════════════
// Scan History Service (Save & Load)
// ═══════════════════════════════════════════════
class ScanHistoryService {
  static const _key = 'scan_history';

  // Save a new scan record
  static Future<void> saveScan(ScanRecord record) async {
    final prefs   = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.insert(0, record); // newest first

    // Keep only last 50 scans
    final trimmed = history.take(50).toList();
    final encoded = trimmed.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  // Load all scan records
  static Future<List<ScanRecord>> loadHistory() async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_key) ?? [];
    return encoded
        .map((e) => ScanRecord.fromJson(jsonDecode(e)))
        .toList();
  }

  // Delete a single scan
  static Future<void> deleteScan(String id) async {
    final prefs   = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.removeWhere((r) => r.id == id);
    final encoded = history.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  // Clear all history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ═══════════════════════════════════════════════
// SCAN HISTORY SCREEN
// ═══════════════════════════════════════════════
class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<ScanRecord> _history    = [];
  bool             _isLoading  = true;
  String           _filter     = 'All';   // All | Disease | Healthy
  String           _searchQuery = '';     // search text
  String           _sortBy      = 'Date'; // Date | Severity | Confidence
  bool             _searchActive = false; // show/hide search bar

  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: AppDuration.normal)
      ..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadHistory();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await ScanHistoryService.loadHistory();
    if (!mounted) return;
    setState(() {
      _history   = history;
      _isLoading = false;
    });
  }

  // Filtered + searched + sorted list
  List<ScanRecord> get _filtered {
    // Step 1 — filter by tab
    List<ScanRecord> list = switch (_filter) {
      'Disease' => _history.where((r) => !r.isHealthy).toList(),
      'Healthy' => _history.where((r) =>  r.isHealthy).toList(),
      _         => List.from(_history),
    };

    // Step 2 — filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) =>
        r.diseaseName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Step 3 — sort
    switch (_sortBy) {
      case 'Severity':
        const order = {'High': 0, 'Medium': 1, 'Low': 2};
        list.sort((a, b) =>
            (order[a.severity] ?? 3).compareTo(order[b.severity] ?? 3));
        break;
      case 'Confidence':
        list.sort((a, b) => b.confidence.compareTo(a.confidence));
        break;
      default: // Date — newest first (already default)
        list.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    }

    return list;
  }

  // Delete with confirmation
  Future<void> _deleteScan(ScanRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
        title: Text('Delete Scan?',
            style: AppText.subheading),
        content: Text('This scan record will be permanently removed.',
            style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ScanHistoryService.deleteScan(record.id);
      _loadHistory();
    }
  }

  // Clear all with confirmation
  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBR),
        title: Text('Clear All History?', style: AppText.subheading),
        content: Text('All scan records will be permanently deleted.',
            style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('Clear All', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ScanHistoryService.clearAll();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          _buildTopBar(),
          _buildStatsRow(),
          if (_searchActive) _buildSearchBar(),
          _buildFilterAndSortRow(),
          Expanded(child: _buildBody()),
        ],
      ),

      // Scan new button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeafScanScreen()),
        ).then((_) => _loadHistory()),
        backgroundColor: AppColors.neonGreen,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.black),
        label: Text('Scan Now',
            style: AppText.buttonLabel.copyWith(fontSize: 14)),
        elevation: 0,
      ),
    );
  }

  // ── Top bar ────────────────────────────────
  // ── Export PDF ────────────────────────────
  Future<void> _exportPdf() async {
    if (_history.isEmpty) return;

    final pdf = pw.Document();
    final records = _filtered.isEmpty ? _history : _filtered;
    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year}';

    // Stats
    final total    = records.length;
    final diseased = records.where((r) => !r.isHealthy).length;
    final healthy  = records.where((r) =>  r.isHealthy).length;
    final highRisk = records
        .where((r) => r.severity.toLowerCase() == 'high')
        .length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat:  PdfPageFormat.a4,
        margin:      const pw.EdgeInsets.all(32),
        header:      (_) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                  color: PdfColor.fromInt(0xFF00E676), width: 1.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('UrbanRoots',
                      style: pw.TextStyle(
                        fontSize:   20,
                        fontWeight: pw.FontWeight.bold,
                        color:      PdfColor.fromInt(0xFF00E676),
                      )),
                  pw.Text('Scan History Report',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color:    PdfColors.grey500,
                      )),
                ],
              ),
              pw.Text('Generated: $dateStr',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color:    PdfColors.grey500,
                  )),
            ],
          ),
        ),
        build: (_) => [
          pw.SizedBox(height: 20),

          // ── Summary stats ───────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color:        PdfColor.fromInt(0xFF16201B),
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(
                  color: PdfColor.fromInt(0xFF00E676).shade(0.3),
                  width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _pdfStat('Total',    '$total',    PdfColors.white),
                _pdfStatDivider(),
                _pdfStat('Diseased', '$diseased', PdfColor.fromInt(0xFFFF3B3B)),
                _pdfStatDivider(),
                _pdfStat('Healthy',  '$healthy',  PdfColor.fromInt(0xFF00E676)),
                _pdfStatDivider(),
                _pdfStat('High Risk','$highRisk', PdfColor.fromInt(0xFFFFD700)),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // ── Table header ─────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF00E676),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 3,
                    child: pw.Text('Disease',
                        style: pw.TextStyle(
                          color:      PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize:   11,
                        ))),
                pw.Expanded(flex: 2,
                    child: pw.Text('Confidence',
                        style: pw.TextStyle(
                          color:      PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize:   11,
                        ))),
                pw.Expanded(flex: 1,
                    child: pw.Text('Severity',
                        style: pw.TextStyle(
                          color:      PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize:   11,
                        ))),
                pw.Expanded(flex: 2,
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                          color:      PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize:   11,
                        ))),
              ],
            ),
          ),

          pw.SizedBox(height: 6),

          // ── Table rows ───────────────────────
          ...records.asMap().entries.map((e) {
            final r       = e.value;
            final isEven  = e.key % 2 == 0;
            final sevColor = switch (r.severity.toLowerCase()) {
              'high'   => PdfColor.fromInt(0xFFFF3B3B),
              'medium' => PdfColor.fromInt(0xFFFFD700),
              _        => PdfColor.fromInt(0xFF00E676),
            };
            final scanned =
                '${r.scannedAt.day}/${r.scannedAt.month}/${r.scannedAt.year}';

            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: pw.BoxDecoration(
                color: isEven
                    ? PdfColor.fromInt(0xFF16201B)
                    : PdfColor.fromInt(0xFF0F1A13),
                border: pw.Border(
                  bottom: pw.BorderSide(
                      color: PdfColors.white, width: 0.5),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 3,
                      child: pw.Text(
                        r.isHealthy ? 'Healthy ✓' : r.diseaseName,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color:    r.isHealthy
                              ? PdfColor.fromInt(0xFF00E676)
                              : PdfColors.white,
                        ),
                      )),
                  pw.Expanded(flex: 2,
                      child: pw.Text(
                        '${(r.confidence * 100).toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color:    PdfColors.white,
                        ),
                      )),
                  pw.Expanded(flex: 1,
                      child: pw.Text(
                        r.severity,
                        style: pw.TextStyle(
                          fontSize:   10,
                          color:      sevColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      )),
                  pw.Expanded(flex: 2,
                      child: pw.Text(
                        scanned,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color:    PdfColors.grey400,
                        ),
                      )),
                ],
              ),
            );
          }),

          pw.SizedBox(height: 32),

          // ── Footer note ──────────────────────
          pw.Text(
            'Report generated by UrbanRoots — Total of $total scan(s)',
            style: pw.TextStyle(
              fontSize: 9,
              color:    PdfColors.grey500,
            ),
          ),
        ],
      ),
    );

    // Share/print the PDF
    await Printing.sharePdf(
      bytes:    await pdf.save(),
      filename: 'urbanroots_scan_history_$dateStr.pdf'
          .replaceAll('/', '-'),
    );
  }

  // ── PDF stat widget helper ─────────────────
  pw.Widget _pdfStat(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
              color:      color,
              fontSize:   18,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 2),
        pw.Text(label,
            style: pw.TextStyle(
              color:   PdfColors.grey400,
              fontSize: 9,
            )),
      ],
    );
  }

  pw.Widget _pdfStatDivider() => pw.Container(
    width: 1, height: 30,
    color: PdfColors.white,
  );

  Widget _buildTopBar() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top:    statusBarHeight + 10,
        left:   18,
        right:  18,
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        border: Border(
          bottom: BorderSide(
              color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: AppStyles.iconCircle,
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),

          // Title
          Column(
            children: [
              Text('Scan History', style: AppText.title),
              Text('${_history.length} scans total',
                  style: AppText.caption),
            ],
          ),

          // Action buttons
          Row(
            children: [
              // Export PDF
              GestureDetector(
                onTap: _history.isEmpty ? null : _exportPdf,
                child: AnimatedOpacity(
                  opacity:  _history.isEmpty ? 0.3 : 1.0,
                  duration: AppDuration.fast,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.picture_as_pdf_rounded,
                        color: AppColors.neonGreen, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Clear all
              GestureDetector(
                onTap: _history.isEmpty ? null : _clearAll,
                child: AnimatedOpacity(
                  opacity:  _history.isEmpty ? 0.3 : 1.0,
                  duration: AppDuration.fast,
                  child: Container(
                    width: 40, height: 40,
                    decoration: AppStyles.iconCircle,
                    child: const Icon(Icons.delete_sweep_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────
  Widget _buildStatsRow() {
    final total    = _history.length;
    final diseased = _history.where((r) => !r.isHealthy).length;
    final healthy  = _history.where((r) =>  r.isHealthy).length;
    final highRisk = _history
        .where((r) => r.severity.toLowerCase() == 'high')
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: AppStyles.card,
      child: Row(
        children: [
          _statItem('Total',    '$total',    Icons.history_rounded,
              Colors.white70),
          _divider(),
          _statItem('Diseased', '$diseased', Icons.coronavirus_rounded,
              AppColors.danger),
          _divider(),
          _statItem('Healthy',  '$healthy',  Icons.check_circle_rounded,
              AppColors.neonGreen),
          _divider(),
          _statItem('High Risk','$highRisk', Icons.warning_rounded,
              AppColors.warning),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                color:      color,
                fontSize:   18,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 2),
          Text(label, style: AppText.tip),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1, height: 40,
        color: Colors.white.withOpacity(0.08),
      );

  // ── Filter tabs ────────────────────────────
  // ── Search bar ────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        decoration: BoxDecoration(
          color:        AppColors.surfaceColor,
          borderRadius: AppRadius.mdBR,
          border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.3), width: 1),
        ),
        child: TextField(
          controller:   _searchCtrl,
          autofocus:    true,
          style:        const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText:      'Search disease name...',
            hintStyle:     TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon:    Icon(Icons.search_rounded,
                color: AppColors.neonGreen, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: Colors.white38, size: 18),
                  )
                : null,
            border:         InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
      ),
    );
  }

  // ── Filter tabs + sort button ──────────────
  Widget _buildFilterAndSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Filter tabs
          Expanded(
            child: Row(
              children: ['All', 'Disease', 'Healthy'].map((tab) {
                final isActive = _filter == tab;
                return GestureDetector(
                  onTap: () => setState(() => _filter = tab),
                  child: AnimatedContainer(
                    duration: AppDuration.fast,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.neonGreen.withOpacity(0.15)
                          : AppColors.surfaceColor,
                      borderRadius: AppRadius.pillBR,
                      border: Border.all(
                        color: isActive
                            ? AppColors.neonGreen.withOpacity(0.5)
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(tab,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.neonGreen
                              : Colors.white54,
                          fontSize:   13,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.normal,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),

          // Sort button
          GestureDetector(
            onTap: _showSortOptions,
            child: AnimatedContainer(
              duration: AppDuration.fast,
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _sortBy != 'Date'
                    ? AppColors.neonGreen.withOpacity(0.15)
                    : AppColors.surfaceColor,
                borderRadius: AppRadius.pillBR,
                border: Border.all(
                  color: _sortBy != 'Date'
                      ? AppColors.neonGreen.withOpacity(0.5)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      color: _sortBy != 'Date'
                          ? AppColors.neonGreen
                          : Colors.white54,
                      size: 16),
                  const SizedBox(width: 5),
                  Text(_sortBy,
                      style: TextStyle(
                        color: _sortBy != 'Date'
                            ? AppColors.neonGreen
                            : Colors.white54,
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sort bottom sheet ──────────────────────
  void _showSortOptions() {
    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: BoxDecoration(
          color:        AppColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24)),
          border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.2),
                  borderRadius: AppRadius.pillBR,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Sort By', style: AppText.subheading),
            const SizedBox(height: 16),

            ...['Date', 'Severity', 'Confidence'].map((option) {
              final isActive = _sortBy == option;
              final icon = switch (option) {
                'Severity'   => Icons.warning_amber_rounded,
                'Confidence' => Icons.percent_rounded,
                _            => Icons.calendar_today_rounded,
              };
              return GestureDetector(
                onTap: () {
                  setState(() => _sortBy = option);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.neonGreen.withOpacity(0.1)
                        : AppColors.bgColor,
                    borderRadius: AppRadius.mdBR,
                    border: Border.all(
                      color: isActive
                          ? AppColors.neonGreen.withOpacity(0.4)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          color: isActive
                              ? AppColors.neonGreen
                              : Colors.white54,
                          size: 20),
                      const SizedBox(width: 12),
                      Text(option,
                          style: TextStyle(
                            color: isActive
                                ? AppColors.neonGreen
                                : Colors.white70,
                            fontSize:   14,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.normal,
                          )),
                      const Spacer(),
                      if (isActive)
                        Icon(Icons.check_rounded,
                            color: AppColors.neonGreen, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: AppColors.neonGreen, strokeWidth: 2),
      );
    }

    if (_filtered.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _buildScanCard(_filtered[i], i),
      ),
    );
  }

  // ── Empty state ────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        AppColors.surfaceColor,
              shape:        BoxShape.circle,
              border: Border.all(
                  color: AppColors.neonGreen.withOpacity(0.2)),
            ),
            child: Icon(Icons.image_search_rounded,
                color: AppColors.neonGreen.withOpacity(0.5), size: 36),
          ),
          const SizedBox(height: 16),
          Text('No scans yet', style: AppText.subheading),
          const SizedBox(height: 6),
          Text('Tap "Scan Now" to analyze your first leaf',
              style: AppText.caption),
        ],
      ),
    );
  }

  // ── Scan card ──────────────────────────────
  Widget _buildScanCard(ScanRecord record, int index) {
    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 400)),
      curve:    Curves.easeOut,
      builder:  (_, value, child) => Opacity(
        opacity:  value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child:  child,
        ),
      ),
      child: Dismissible(
        key:       Key(record.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color:        AppColors.danger.withOpacity(0.2),
            borderRadius: AppRadius.mdBR,
            border: Border.all(
                color: AppColors.danger.withOpacity(0.3)),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_rounded,
              color: AppColors.danger, size: 24),
        ),
        onDismissed: (_) => ScanHistoryService.deleteScan(record.id)
            .then((_) => _loadHistory()),
        confirmDismiss: (_) async {
          // ✅ Vibrate on swipe to delete
          final hasVibrator = await Vibration.hasVibrator() ?? false;
          if (hasVibrator) Vibration.vibrate(duration: 60);
          await _deleteScan(record);
          return false;
        },
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DiseaseResultScreen(imagePath: record.imagePath),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: AppStyles.card,
            child: Row(
              children: [
                // ── Leaf photo thumbnail ───────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft:     Radius.circular(14),
                    bottomLeft:  Radius.circular(14),
                  ),
                  child: SizedBox(
                    width: 90, height: 90,
                    child: Image.file(
                      File(record.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceColor,
                        child: Icon(Icons.eco_rounded,
                            color: AppColors.neonGreen.withOpacity(0.4),
                            size: 32),
                      ),
                    ),
                  ),
                ),

                // ── Info ───────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disease name + healthy badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.diseaseName,
                                style: AppText.subheading
                                    .copyWith(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (record.isHealthy)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen
                                      .withOpacity(0.12),
                                  borderRadius: AppRadius.pillBR,
                                  border: Border.all(
                                    color: AppColors.neonGreen
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text('Healthy',
                                    style: TextStyle(
                                      color:      AppColors.neonGreen,
                                      fontSize:   10,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Confidence bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: AppRadius.pillBR,
                                child: LinearProgressIndicator(
                                  value:           record.confidence,
                                  minHeight:       4,
                                  backgroundColor: Colors.white
                                      .withOpacity(0.07),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    record.isHealthy
                                        ? AppColors.neonGreen
                                        : record.severityColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(record.confidence * 100).toInt()}%',
                              style: TextStyle(
                                color:      record.isHealthy
                                    ? AppColors.neonGreen
                                    : record.severityColor,
                                fontSize:   11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Date + severity chip
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            // Date
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    color: Colors.white38, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(record.scannedAt),
                                  style: AppText.tip.copyWith(
                                      color: Colors.white38),
                                ),
                              ],
                            ),

                            // Severity chip
                            if (!record.isHealthy)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: record.severityColor
                                      .withOpacity(0.12),
                                  borderRadius: AppRadius.pillBR,
                                  border: Border.all(
                                    color: record.severityColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  record.severity,
                                  style: TextStyle(
                                    color:      record.severityColor,
                                    fontSize:   10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Chevron
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right_rounded,
                      color: Colors.white24, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inHours   < 1)  return '${diff.inMinutes}m ago';
    if (diff.inDays    < 1)  return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    if (diff.inDays    < 7)  return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}