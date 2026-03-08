import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? _activePlant;
  bool _isThirsty = false;
  bool _isTapped = false;

  AnimationController? _petController;
  late AnimationController _bubbleController;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late AnimationController _shimmerController;

  late Animation<double> _bubbleFade;
  late Animation<Offset> _bubbleSlide;
  late Animation<double> _glowPulse;
  late Animation<double> _bounceAnim;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    // fade + slide for when bubble first appears
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bubbleFade = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOut,
    );
    _bubbleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bubbleController, curve: Curves.easeOut));

    // slow breathe glow around the bubble border
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // tiny vertical bounce so bubble feels alive when it sits there
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // shimmer sweep across the bubble text area
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _bubbleController.forward();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    _petController?.dispose();
    super.dispose();
  }

  void _handlePetTap() async {
    if (_isTapped) return;
    setState(() => _isTapped = true);
    _triggerBubbleAnimation();

    const double jumpSeekPosition = 0.08;
    _petController?.value = jumpSeekPosition;

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _isTapped = false);
  }

  void _triggerBubbleAnimation() {
    _bubbleController.reset();
    _bubbleController.forward();
  }

  String _getPetAnimation() {
    if (_isThirsty) return 'assets/animations/pet_sad.json';
    if (_isTapped) return 'assets/animations/pet_happy.json';
    if (_activePlant == null) return 'assets/animations/pet_idle.json';
    return 'assets/animations/pet_happy.json';
  }

  // short sentences — the emoji carries the feeling
  String _getPetDialogue() {
    if (_isThirsty) return "So thirsty… help! 😢";
    if (_isTapped) return "Hehe, stop it! 🌿";
    if (_activePlant == null) return "Pick a crop! 🌱";
    return "We're thriving! ✨";
  }

  // second line adds personality without crowding
  String _getPetSubtext() {
    if (_isThirsty) return "moisture critically low";
    if (_isTapped) return "you're the best 🥰";
    if (_activePlant == null) return "I'll help you grow it";
    return "keep it up, Nethmika";
  }

  Color get _accentColor =>
      _isThirsty ? Colors.redAccent : AppColors.primaryGreen;

  // bubble bg gradient shifts based on mood
  List<Color> get _bubbleGradient => _isThirsty
      ? [const Color(0xFF2D1515), const Color(0xFF1A0C0C)]
      : _isTapped
          ? [const Color(0xFF1E2D1A), const Color(0xFF0F1A0C)]
          : [const Color(0xFF162214), const Color(0xFF0D180B)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              Expanded(child: _buildPetArea()),
              _buildDashboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetArea() {
    const double idleYOffset = 28.0;
    const double happyYOffset = 0.0;
    const double jumpYOffset = 0.0;
    const double sadYOffset = 28.0;

    double yOffset;
    if (_isTapped)
      yOffset = jumpYOffset;
    else if (_isThirsty)
      yOffset = sadYOffset;
    else if (_activePlant != null)
      yOffset = happyYOffset;
    else
      yOffset = idleYOffset;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: _handlePetTap,
                    child: Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: 1.05,
                        alignment: Alignment.bottomCenter,
                        child: Lottie.asset(
                          _getPetAnimation(),
                          key: ValueKey(
                              _isTapped ? 'tapped' : _getPetAnimation()),
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          controller: _isTapped ? _petController : null,
                          onLoaded: (composition) {
                            if (_isTapped) {
                              _petController?.dispose();
                              _petController = AnimationController(
                                vsync: this,
                                duration: composition.duration,
                              );
                              _petController!.value = 0.06;
                              _petController!.forward();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // bubble floats top-right, bounces gently, glows with pet's mood
              Positioned(
                top: 40,
                right: 0,
                child: FadeTransition(
                  opacity: _bubbleFade,
                  child: SlideTransition(
                    position: _bubbleSlide,
                    child: AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _bounceAnim.value),
                        child: child,
                      ),
                      child: _buildSpeechBubble(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180, minWidth: 140),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_glowPulse, _shimmerAnim]),
            builder: (_, child) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _bubbleGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _accentColor.withOpacity(_glowPulse.value),
                    width: 1.8,
                  ),
                  boxShadow: [
                    // outer glow — breathes with the pet
                    BoxShadow(
                      color: _accentColor
                          .withOpacity(_glowPulse.value * 0.45),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                    // hard drop shadow so it pops off the bg
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // shimmer layer sits on top of text like a light sweep
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment(_shimmerAnim.value - 1, 0),
                            end: Alignment(_shimmerAnim.value, 0),
                            colors: [
                              Colors.transparent,
                              _accentColor.withOpacity(0.07),
                              Colors.transparent,
                            ],
                          ).createShader(bounds),
                          child: Container(color: Colors.white),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _StatusDot(color: _accentColor),
                            const SizedBox(width: 8),
                            Text(
                              _getPetDialogue(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        // subtext — personal, quiet, fits in one line
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 2),
                          child: Text(
                            _getPetSubtext(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: GoogleFonts.poppins(
                              color: _accentColor.withOpacity(0.75),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // tail points toward the pet below-left
          Align(
            alignment: Alignment.bottomLeft,
            child: CustomPaint(
              size: const Size(22, 14),
              painter: _BubbleTailPainter(
                fillColor: _bubbleGradient.last,
                borderColor: _accentColor.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader("Live Status"),
            GestureDetector(
              onTap: () {
                setState(() => _isThirsty = !_isThirsty);
                _triggerBubbleAnimation();
              },
              child: Icon(
                Icons.opacity,
                color: _isThirsty ? Colors.redAccent : Colors.white24,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCompactStatusRow(),
        const SizedBox(height: 16),
        _buildAiInsightCard(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, Nethmika!",
              style: GoogleFonts.poppins(
                  color: AppColors.textDim, fontSize: 14),
            ),
            Text(
              "Bat Cave",
              style: GoogleFonts.poppins(
                color: AppColors.textMain,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceColor,
            child: Icon(Icons.person, color: Colors.white70, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatusRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _compactStatItem("Sunlight", "85%", Icons.wb_sunny, Colors.amber),
          _compactStatItem(
            "Moisture",
            _isThirsty ? "12%" : "42%",
            Icons.water_drop,
            _isThirsty ? Colors.redAccent : Colors.lightBlue,
          ),
          _compactStatItem("Wind", "12km", Icons.air, Colors.tealAccent),
          _compactStatItem(
            "Health",
            _isThirsty ? "Bad" : "Good",
            Icons.monitor_heart,
            _isThirsty ? Colors.redAccent : AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _compactStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white30,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsightCard() {
    bool hasPlant = _activePlant != null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: AppColors.primaryGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                hasPlant ? "DIRECTIVE" : "RECOMMENDATION",
                style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasPlant
                ? "Humidity is high. Adjust irrigation to prevent root decay."
                : "Environmental conditions suggest Spinach will yield 15% more today.",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _activePlant = hasPlant ? null : "Spinach");
                _triggerBubbleAnimation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                hasPlant ? "RESET" : "OPTIMIZE NOW",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.poppins(
        color: AppColors.textDim,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }
}

// pulsing dot — the heartbeat of the bubble
class _StatusDot extends StatefulWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_pulse.value),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_pulse.value * 0.6),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// triangle pointing bottom-left toward the pet
class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  const _BubbleTailPainter(
      {required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height * 0.3)
      ..close();

    canvas.drawPath(path,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill);

    canvas.drawPath(path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) =>
      old.fillColor != fillColor || old.borderColor != borderColor;
}