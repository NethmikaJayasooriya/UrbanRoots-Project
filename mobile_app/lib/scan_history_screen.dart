import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
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

  // Severity color
  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'high':   return AppColors.danger;
      case 'medium': return AppColors.warning;
      case 'low':    return const Color(0xFF69F0AE);
      default:       return AppColors.neonGreen;
    }
  }
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
  List<ScanRecord> _history   = [];
  bool             _isLoading = true;
  String           _filter    = 'All'; // All | Disease | Healthy

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

  // Filtered list based on selected tab
  List<ScanRecord> get _filtered {
    switch (_filter) {
      case 'Disease': return _history.where((r) => !r.isHealthy).toList();
      case 'Healthy': return _history.where((r) =>  r.isHealthy).toList();
      default:        return _history;
    }
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
          _buildFilterTabs(),
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
  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: ['All', 'Disease', 'Healthy'].map((tab) {
          final isActive = _filter == tab;
          return GestureDetector(
            onTap: () => setState(() => _filter = tab),
            child: AnimatedContainer(
              duration: AppDuration.fast,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
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
              child: Text(
                tab,
                style: TextStyle(
                  color: isActive
                      ? AppColors.neonGreen
                      : Colors.white54,
                  fontSize:   13,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
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
          await _deleteScan(record);
          return false; // we handle reload ourselves
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
