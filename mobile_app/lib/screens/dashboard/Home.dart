import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isThirsty = false;
  bool _isTapped = false;

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  // Animation controllers for the Digital Pet and UI elements
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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _bubbleController.forward();
    _fetchLiveDashboardData();
  }

  // Fetches live data from the backend to determine pet mood and dashboard stats
  Future<void> _fetchLiveDashboardData() async {
    final int? storedId = await ApiService.getStoredGardenId();
    
    if (storedId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dashboardData = {
            'garden_name': "Welcome to UrbanRoots",
            'pet_status': {
              'message': "Create a garden to hatch me! 🌱",
              'is_thirsty': false
            },
            'priority_notification': "Head to the 'My Garden' tab below to setup your first environment.",
            'linked_plant_name': "None"
          };
        });
      }
      return; 
    }

    final data = await ApiService.getGardenStatus(storedId); 
    
    if (mounted && data != null) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;
        
        if (data['pet_status'] != null) {
          _isThirsty = data['pet_status']['is_thirsty'] == true;
          
          if (data['pet_status']['mood'] == 'super_happy' && !_isThirsty) {
             _triggerHappyJump();
          }
        }
      });
      _triggerBubbleAnimation(); 
    }
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

  // Triggers the happy animation when the user taps on the Digital Pet
  void _handlePetTap() async {
    if (_isTapped) return;
    _triggerHappyJump();
  }

  void _triggerHappyJump() async {
    if (_isTapped || _isThirsty) return;
    setState(() => _isTapped = true);
    _triggerBubbleAnimation();

    if (_petController != null) {
      const double jumpSeekPosition = 0.06;
      _petController!.value = jumpSeekPosition;
      _petController!.forward();
    }

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _isTapped = false);
  }

  void _triggerBubbleAnimation() {
    _bubbleController.reset();
    _bubbleController.forward();
  }

  // Determines which Lottie animation to play based on the pet's current state
  String _getPetAnimation() {
    if (_isThirsty) return 'assets/animations/pet_sad.json';
    if (_isTapped) return 'assets/animations/pet_happy.json';
    return 'assets/animations/pet_idle.json';
  }

  String _getPetDialogue() {
    if (_isLoading) return "Checking the environment... ☁️";
    if (_isTapped && _isThirsty) return "I'm too thirsty to play... 💧";
    
    if (_dashboardData != null && _dashboardData!['pet_status'] != null) {
      return _dashboardData!['pet_status']['message'];
    }
    
    return "We're thriving! ✨";
  }

  String _getPetSubtext() {
    if (_isLoading) return "connecting to satellites...";
    if (_isTapped && _isThirsty) return "needs water badly";
    if (_isTapped) return "you're the best 🥰";
    
    if (_dashboardData != null && _dashboardData!['live_weather'] != null) {
      return "Live from ${_dashboardData!['live_weather']['city']}";
    }
    
    return "keep it up, Nethmika";
  }

  Color get _accentColor => _isThirsty ? Colors.redAccent : AppColors.primaryGreen;

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
    const double sadYOffset = 28.0;

    bool isHappyState = !_isThirsty && _isTapped;
    double petScale = isHappyState ? 1.15 : 1.05;

    double yOffset = isHappyState ? happyYOffset : (_isThirsty ? sadYOffset : idleYOffset);

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
                        scale: petScale,
                        alignment: Alignment.bottomCenter,
                        child: Lottie.asset(
                          _getPetAnimation(),
                          key: ValueKey(_isTapped ? 'tapped' : _getPetAnimation()),
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          controller: _isTapped && !_isThirsty ? _petController : null,
                          onLoaded: (composition) {
                            if (_isTapped && !_isThirsty) {
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    BoxShadow(
                      color: _accentColor.withOpacity(_glowPulse.value * 0.45),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment(_shimmerAnim.value - 1, 0),
                            end: Alignment(_shimmerAnim.value, 0),
                            colors: const [
                              Colors.transparent,
                              Colors.white10,
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
                            Expanded(
                              child: Text(
                                _getPetDialogue(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                setState(() => _isLoading = true);
                _fetchLiveDashboardData();
              },
              child: Icon(
                Icons.refresh, 
                color: _isLoading ? AppColors.primaryGreen : Colors.white24,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded ensures long garden names wrap instead of causing striped overflow
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, Nethmika!",
                style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 14),
              ),
              Text(
                _dashboardData?['garden_name'] ?? "My Garden",
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.textMain,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
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
    if (_isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    final weather = _dashboardData?['live_weather'];
    final temp = weather != null ? "${weather['temperature']}°C" : "--";
    final humidity = weather != null ? "${weather['humidity']}%" : "--";
    final condition = weather != null ? "${weather['condition']}" : "--";
    
    String city = weather != null ? "${weather['city']}" : "Unknown";
    if (city.length > 8) city = "${city.substring(0, 7)}..";

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
          _compactStatItem("Temp", temp, Icons.thermostat, Colors.amber),
          _compactStatItem("Humidity", humidity, Icons.water_drop, Colors.lightBlue),
          _compactStatItem("Weather", condition, Icons.cloud, Colors.tealAccent),
          _compactStatItem("City", city, Icons.location_city, AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _compactStatItem(String title, String value, IconData icon, Color color) {
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
    // Now displays the AI-generated Quick Tip or Task Reminder
    String notificationText = _dashboardData?['priority_notification'] ?? 
        "Your garden conditions are currently stable.";
    
    // Determine if it's a tip or a priority task based on an emoji or keyword we set
    bool isTip = notificationText.contains("💡") || notificationText.contains("Great job") || !notificationText.contains("Reminder:");
    String headerText = isTip ? "GARDEN INSIGHT" : "PRIORITY TASK";
    Color headerColor = isTip ? Colors.amberAccent : AppColors.primaryGreen;
    IconData headerIcon = isTip ? Icons.lightbulb_outline : Icons.auto_awesome;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: headerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(headerIcon, color: headerColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerText,
                  style: GoogleFonts.poppins(
                    color: headerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notificationText,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchLiveDashboardData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                "REFRESH STATUS",
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

class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  const _BubbleTailPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height * 0.3)
      ..close();

    canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
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