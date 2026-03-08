import 'package:flutter/material.dart';
import 'app_styles.dart';

// ═══════════════════════════════════════════════
// Disease Info Model
// ═══════════════════════════════════════════════
class DiseaseInfo {
  final String       name;
  final String       scientificName;
  final String       category;       // Viral | Fungal | Bacterial | Pest
  final Color        categoryColor;
  final String       severity;       // Low | Medium | High
  final String       overview;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> prevention;
  final List<String> treatments;
  final String       spreadRate;     // Slow | Moderate | Fast
  final String       affectedParts;  // Leaves | Stem | Root | All
  final List<RemedyInfo> remedies;

  const DiseaseInfo({
    required this.name,
    required this.scientificName,
    required this.category,
    required this.categoryColor,
    required this.severity,
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.prevention,
    required this.treatments,
    required this.spreadRate,
    required this.affectedParts,
    required this.remedies,
  });
}

class RemedyInfo {
  final String name;
  final String type;        // Organic | Chemical
  final String description;
  final String frequency;

  const RemedyInfo({
    required this.name,
    required this.type,
    required this.description,
    required this.frequency,
  });
}

// ── Disease database (replace with real API later) ──
const _diseaseDatabase = {
  'Leaf Curl Disease': DiseaseInfo(
    name:           'Leaf Curl Disease',
    scientificName: 'Tomato Yellow Leaf Curl Virus (TYLCV)',
    category:       'Viral',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:
        'Leaf Curl Disease is a viral infection spread primarily by whiteflies. '
        'It causes leaves to curl upward and inward, turn yellow, and stunt plant growth. '
        'Early detection and isolation are critical to prevent it spreading to nearby plants.',
    symptoms: [
      'Leaves curl upward and inward',
      'Yellowing of leaf edges (chlorosis)',
      'Stunted and bushy plant growth',
      'Flowers drop before fruit sets',
      'Fruits are small and deformed',
      'New growth appears pale and distorted',
    ],
    causes: [
      'Whitefly (Bemisia tabaci) feeding and transmitting the virus',
      'Infected transplants or seedlings',
      'Proximity to already infected plants',
      'Warm and humid weather conditions',
      'Poor garden sanitation',
    ],
    prevention: [
      'Use reflective mulch to repel whiteflies',
      'Install yellow sticky traps around plants',
      'Inspect new plants before introducing to garden',
      'Keep garden free of weeds that harbor whiteflies',
      'Use insect-proof netting on seedlings',
      'Grow resistant varieties when possible',
    ],
    treatments: [
      'Isolate infected plant immediately',
      'Remove and destroy all visibly infected leaves',
      'Apply neem oil spray every 5–7 days',
      'Introduce beneficial insects like ladybugs',
      'Use insecticidal soap on leaf undersides',
      'Remove severely infected plants entirely',
    ],
    spreadRate:    'Fast',
    affectedParts: 'Leaves, Flowers, Fruit',
    remedies: [
      RemedyInfo(
        name:        'Organic Neem Oil',
        type:        'Organic',
        description: 'Natural pesticide that disrupts whitefly life cycle',
        frequency:   'Every 7 days',
      ),
      RemedyInfo(
        name:        'Insecticidal Soap',
        type:        'Organic',
        description: 'Kills soft-bodied insects on contact',
        frequency:   'Every 5 days',
      ),
      RemedyInfo(
        name:        'Imidacloprid',
        type:        'Chemical',
        description: 'Systemic insecticide for severe infestations',
        frequency:   'Once per season',
      ),
    ],
  ),

  'Powdery Mildew': DiseaseInfo(
    name:           'Powdery Mildew',
    scientificName: 'Erysiphales (multiple species)',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:
        'Powdery Mildew is a common fungal disease that appears as a white '
        'powdery coating on leaf surfaces. It thrives in warm dry days with '
        'cool humid nights. While rarely fatal, it weakens plants over time.',
    symptoms: [
      'White or grey powdery spots on leaves',
      'Spots spread to cover entire leaf surface',
      'Leaves turn yellow and eventually brown',
      'Distorted or stunted new growth',
      'Premature leaf drop',
    ],
    causes: [
      'Fungal spores spread by wind',
      'Overcrowded plants with poor air circulation',
      'High humidity with warm temperatures',
      'Excessive nitrogen fertilization',
      'Overwatering or inconsistent watering',
    ],
    prevention: [
      'Space plants for good air circulation',
      'Avoid overhead watering — water at base',
      'Remove and dispose of infected leaves early',
      'Choose mildew-resistant plant varieties',
      'Avoid excessive nitrogen fertilizers',
    ],
    treatments: [
      'Remove affected leaves immediately',
      'Apply baking soda solution (1 tbsp per litre)',
      'Spray diluted neem oil on affected areas',
      'Use potassium bicarbonate fungicide',
      'Apply sulfur-based fungicide in severe cases',
    ],
    spreadRate:    'Moderate',
    affectedParts: 'Leaves, Stems',
    remedies: [
      RemedyInfo(
        name:        'Baking Soda Spray',
        type:        'Organic',
        description: 'Changes pH on leaf surface to inhibit fungal growth',
        frequency:   'Every 3 days',
      ),
      RemedyInfo(
        name:        'Sulfur Fungicide',
        type:        'Chemical',
        description: 'Prevents spore germination on leaf surfaces',
        frequency:   'Every 7–10 days',
      ),
    ],
  ),
};

// ═══════════════════════════════════════════════
// DISEASE DETAIL SCREEN
// ═══════════════════════════════════════════════
class DiseaseDetailScreen extends StatefulWidget {
  final String diseaseName;
  const DiseaseDetailScreen({super.key, required this.diseaseName});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _diseaseDatabase[widget.diseaseName];

    // If disease not in database yet
    if (info == null) return _buildNotFound();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          _buildTopBar(info),
          _buildHeroCard(info),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildOverviewTab(info),
                _buildSymptomsTab(info),
                _buildTreatmentTab(info),
                _buildRemediesTab(info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ────────────────────────────────
  Widget _buildTopBar(DiseaseInfo info) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top:    statusBarHeight + 8,
        left:   14,
        right:  14,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color:  AppColors.bgColor,
        border: Border(
          bottom: BorderSide(
              color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: AppStyles.iconCircle,
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Disease Info', style: AppText.title),
                Text(info.scientificName,
                    style: AppText.tip.copyWith(
                        color: Colors.white38,
                        fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero card ──────────────────────────────
  Widget _buildHeroCard(DiseaseInfo info) {
    // ✅ Using AppSeverity helper — single source of truth
    final severityColor = AppSeverity.color(info.severity);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            info.categoryColor.withOpacity(0.15),
            AppColors.surfaceColor,
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgBR,
        border: Border.all(
            color: info.categoryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        info.categoryColor.withOpacity(0.15),
                  borderRadius: AppRadius.pillBR,
                  border: Border.all(
                      color: info.categoryColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_categoryIcon(info.category),
                        color: info.categoryColor, size: 12),
                    const SizedBox(width: 5),
                    Text(info.category,
                        style: TextStyle(
                          color:      info.categoryColor,
                          fontSize:   11,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
              const Spacer(),
              // Severity badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        severityColor.withOpacity(0.12),
                  borderRadius: AppRadius.pillBR,
                  border: Border.all(
                      color: severityColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: severityColor, size: 12),
                    const SizedBox(width: 4),
                    Text('${info.severity} Risk',
                        style: TextStyle(
                          color:      severityColor,
                          fontSize:   11,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(info.name,
              style: AppText.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _statChip(Icons.speed_rounded,       'Spread',   info.spreadRate),
              const SizedBox(width: 8),
              _statChip(Icons.eco_rounded,          'Affects',  info.affectedParts),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:        AppColors.surfaceColor,
        borderRadius: AppRadius.mdBR,
      ),
      child: TabBar(
        controller:          _tabCtrl,
        indicatorSize:       TabBarIndicatorSize.tab,
        dividerColor:        Colors.transparent,
        indicator: BoxDecoration(
          color:        AppColors.neonGreen.withOpacity(0.15),
          borderRadius: AppRadius.mdBR,
          border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.4), width: 1),
        ),
        labelColor:          AppColors.neonGreen,
        unselectedLabelColor: Colors.white38,
        labelStyle:   const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Symptoms'),
          Tab(text: 'Treatment'),
          Tab(text: 'Remedies'),
        ],
      ),
    );
  }

  // ── Overview tab ───────────────────────────
  Widget _buildOverviewTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // What is it
        _sectionHeader(Icons.info_outline_rounded, 'What is it?'),
        const SizedBox(height: 10),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: AppStyles.card,
          child: Text(info.overview, style: AppText.body),
        ),
        const SizedBox(height: 20),

        // Causes
        _sectionHeader(Icons.search_rounded, 'Causes'),
        const SizedBox(height: 10),
        ...info.causes.map((c) => _bulletCard(c, AppColors.warning)),

        const SizedBox(height: 20),

        // Prevention
        _sectionHeader(Icons.shield_outlined, 'Prevention'),
        const SizedBox(height: 10),
        ...info.prevention.map((p) => _bulletCard(p, AppColors.neonGreen)),

        const SizedBox(height: 80),
      ],
    );
  }

  // ── Symptoms tab ───────────────────────────
  Widget _buildSymptomsTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.sick_rounded, 'What to look for'),
        const SizedBox(height: 10),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: AppStyles.card,
          child: Column(
            children: info.symptoms.asMap().entries.map((e) {
              final isLast = e.key == info.symptoms.length - 1;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color:        AppColors.danger.withOpacity(0.12),
                          shape:        BoxShape.circle,
                          border: Border.all(
                              color: AppColors.danger.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(
                              color:      AppColors.danger,
                              fontSize:   11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(e.value, style: AppText.body),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 10),
                    Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 1),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── Treatment tab ──────────────────────────
  Widget _buildTreatmentTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.medical_services_rounded, 'Step-by-Step Treatment'),
        const SizedBox(height: 10),
        ...info.treatments.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: AppStyles.card,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color:        AppColors.neonGreen.withOpacity(0.12),
                    borderRadius: AppRadius.smBR,
                    border: Border.all(
                        color: AppColors.neonGreen.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        color:      AppColors.neonGreen,
                        fontSize:   13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(e.value, style: AppText.body),
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── Remedies tab ───────────────────────────
  Widget _buildRemediesTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.eco_rounded, 'Recommended Remedies'),
        const SizedBox(height: 10),
        ...info.remedies.map((r) {
          final isOrganic = r.type == 'Organic';
          final typeColor = isOrganic ? AppColors.neonGreen : AppColors.warning;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: AppStyles.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color:        typeColor.withOpacity(0.12),
                          borderRadius: AppRadius.smBR,
                          border: Border.all(
                              color: typeColor.withOpacity(0.3)),
                        ),
                        child: Icon(
                          isOrganic
                              ? Icons.eco_rounded
                              : Icons.science_rounded,
                          color: typeColor, size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: AppText.subheading
                                    .copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color:        typeColor.withOpacity(0.1),
                                borderRadius: AppRadius.pillBR,
                                border: Border.all(
                                    color: typeColor.withOpacity(0.3)),
                              ),
                              child: Text(r.type,
                                  style: TextStyle(
                                    color:      typeColor,
                                    fontSize:   10,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                      color: Colors.white.withOpacity(0.06), height: 1),
                  const SizedBox(height: 10),
                  Text(r.description, style: AppText.body),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 5),
                      Text('Apply: ${r.frequency}',
                          style: AppText.tip.copyWith(
                              color: Colors.white38)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── Not found state ────────────────────────
  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: AppStyles.iconCircle,
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.search_off_rounded,
                color: AppColors.neonGreen.withOpacity(0.4), size: 60),
            const SizedBox(height: 16),
            Text('No Info Available', style: AppText.subheading),
            const SizedBox(height: 6),
            Text('Details for "${widget.diseaseName}" not found',
                style: AppText.caption),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────
  IconData _categoryIcon(String category) => switch (category) {
        'Viral'     => Icons.coronavirus_rounded,
        'Fungal'    => Icons.grass_rounded,
        'Bacterial' => Icons.biotech_rounded,
        _           => Icons.bug_report_rounded,
      };

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonGreen, size: 18),
        const SizedBox(width: 8),
        Text(title, style: AppText.subheading),
      ],
    );
  }

  Widget _bulletCard(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: AppStyles.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8, height: 8,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color:  color,
                shape:  BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppText.body)),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:        AppColors.bgColor.withOpacity(0.5),
          borderRadius: AppRadius.smBR,
          border: Border.all(
              color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 14),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppText.tip.copyWith(color: Colors.white30)),
                Text(value,
                    style: const TextStyle(
                      color:      Colors.white70,
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}