import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plant_detail_screen.dart';
import 'ai_recommendations_screen.dart';
import 'package:mobile_app/screens/garden_creation/garden_intro_screen.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen>
    with TickerProviderStateMixin {
  bool _gardenCreated = false;
  Map<String, dynamic>? _gardenData;
  final List<Map<String, dynamic>> _plants = [];
  final List<Map<String, dynamic>> _userGardens = [];
  String? _selectedGardenId;
  String? _assignedPlantId;

  late AnimationController _glowController;
  late AnimationController _staggerController;
  late Animation<double> _glowAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _openGardenCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GardenIntroScreen(
          onGardenCreated: (gardenData) {
            setState(() {
              _gardenCreated = true;
              _gardenData = gardenData;
              final newGarden = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': gardenData['garden_name'] ?? 'My Garden',
              };
              _userGardens.add(newGarden);
              _selectedGardenId = newGarden['id'];
            });
          },
        ),
      ),
    );
  }

  Future<void> _openAiRecommendations() async {
    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AiRecommendationsScreen(gardenData: _gardenData ?? {}),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _plants.clear();
        _plants.addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = 24 + MediaQuery.of(context).padding.bottom;
    final String dynamicTitle = _userGardens.isNotEmpty
        ? _userGardens.firstWhere((g) => g['id'] == _selectedGardenId,
            orElse: () => {'name': 'My Garden'})['name']
        : 'My Garden';

    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: !_gardenCreated
            ? _buildEmptyState(bottomPadding)
            : _plants.isEmpty
                ? _buildGardenReadyState(dynamicTitle, bottomPadding)
                : _buildPlantGrid(dynamicTitle, bottomPadding),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EMPTY STATE — fits entirely on screen, no scroll needed
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState(double bottomPadding) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Garden",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      fontSize: 26,
                    ),
                  ),
                  _statusBadge(),
                ],
              ),

              const SizedBox(height: 28),

              // ── Hero: icon badge + headline side by side ─────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Glowing icon badge
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, _) => Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1C12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryGreen
                              .withOpacity(0.25 + _glowAnim.value * 0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen
                                .withOpacity(_glowAnim.value * 0.22),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.eco_rounded,
                            color: AppColors.primaryGreen, size: 34),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // Headline text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your garden\nawaits.",
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Let AI pick the perfect crops\nfor your environment.",
                          style: GoogleFonts.poppins(
                            color: AppColors.textDim,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── 2×2 compact benefit tiles ────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: _compactTile(Icons.psychology_rounded,
                          "AI Advisor", "Crops matched\nto your space", 0)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _compactTile(Icons.sensors_rounded, "IoT Ready",
                          "Live soil & light\ntracking", 1)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _compactTile(Icons.calendar_today_rounded,
                          "Smart Schedule", "Auto watering\nreminders", 2)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _compactTile(Icons.location_on_rounded,
                          "GPS Aware", "Climate-based\nsuggestions", 3)),
                ],
              ),

              // Spacer pushes CTA to the bottom — always visible
              const Spacer(),

              // ── CTA button ───────────────────────────────────────────────
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, _) => GestureDetector(
                  onTap: _openGardenCreation,
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen
                              .withOpacity(0.25 + _glowAnim.value * 0.2),
                          blurRadius: 22,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Colors.black, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          "Create My Garden",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  "Takes less than 2 minutes · Free",
                  style:
                      GoogleFonts.poppins(color: Colors.white24, fontSize: 12),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Compact 2-column tile ─────────────────────────────────────────────────
  Widget _compactTile(IconData icon, String title, String sub, int idx) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + idx * 80),
      curve: Curves.easeOut,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1C12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              style: GoogleFonts.poppins(
                color: AppColors.textDim,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: AppColors.primaryGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            "Not active",
            style: GoogleFonts.poppins(
              color: AppColors.primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GARDEN READY (garden created, no plants yet)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGardenReadyState(String title, double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGardenHeader(title),
          _buildGardenSelectorStrip(),
          const SizedBox(height: 30),
          Text("Active Crops",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textDim)),
          const SizedBox(height: 15),
          _buildAiRecommendationPromo(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PLANT GRID
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPlantGrid(String title, double bottomPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGardenHeader(title),
          _buildGardenSelectorStrip(),
          const SizedBox(height: 30),
          Text("Active Crops",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textDim)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: _plants.length + 1,
            itemBuilder: (context, index) {
              if (index == _plants.length) return _buildAddCard();
              return _buildPlantCard(_plants[index]);
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Shared header: garden name + "+ New Garden" button ──────────────────
  Widget _buildGardenHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
              fontSize: 24,
            ),
          ),
          GestureDetector(
            onTap: _openGardenCreation,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      color: AppColors.primaryGreen, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    "New Garden",
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenSelectorStrip() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // +1 for the "Add" pill at the end
        itemCount: _userGardens.length + 1,
        itemBuilder: (context, index) {
          // Last item = add new garden pill
          if (index == _userGardens.length) {
            return GestureDetector(
              onTap: _openGardenCreation,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.primaryGreen, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      "Add",
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final garden = _userGardens[index];
          final bool isSelected = _selectedGardenId == garden['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedGardenId = garden['id']),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  garden['name'],
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.black : AppColors.textDim,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiRecommendationPromo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology,
                color: AppColors.primaryGreen, size: 30),
          ),
          const SizedBox(height: 12),
          Text("Your Garden is Ready!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Let our AI analyze your environment to recommend the perfect crops.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppColors.textDim, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _openAiRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text("GET RECOMMENDATION",
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    final bool isAssigned = _assignedPlantId == plant['id'];
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plant: plant))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isAssigned ? AppColors.primaryGreen : Colors.white10,
              width: isAssigned ? 2 : 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              plant['imageIsAsset'] == true
                  ? Image.asset(plant['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceColor,
                          child: const Center(
                              child: Icon(Icons.yard_rounded,
                                  color: AppColors.primaryGreen, size: 40))))
                  : Image.network(plant['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceColor,
                          child: const Center(
                              child: Icon(Icons.yard_rounded,
                                  color: AppColors.primaryGreen, size: 40)))),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAssigned)
                      const Align(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.pets,
                              color: AppColors.primaryGreen, size: 18)),
                    const Spacer(),
                    Text(plant['name'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                            fontSize: 18)),
                    Text(plant['status'],
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 12),
                    _buildLinkToggle(plant['id'], isAssigned),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkToggle(String id, bool isAssigned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Link Pet",
              style:
                  GoogleFonts.poppins(color: AppColors.textMain, fontSize: 10)),
          Transform.scale(
            scale: 0.65,
            child: Switch(
              value: isAssigned,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) =>
                  setState(() => _assignedPlantId = val ? id : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard() {
    return GestureDetector(
      onTap: _openAiRecommendations,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Icon(Icons.add_circle_outline,
              color: AppColors.primaryGreen, size: 40),
        ),
      ),
    );
  }
}