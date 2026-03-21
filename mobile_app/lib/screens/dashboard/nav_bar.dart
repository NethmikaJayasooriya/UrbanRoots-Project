import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'Home.dart';
import 'Garden/my_Garden.dart';
import '../../leaf_disease_screen.dart';

// EXACT IMPORTS BASED ON YOUR PROJECT STRUCTURE
import 'Marketplace/marketplace_screen.dart'; 
import 'UserProfile/profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN NAVIGATION WRAPPER  
// ─────────────────────────────────────────────────────────────────────────────
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  AnimationController? _pulseController;
  Animation<double>? _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool scannerActive = _currentIndex == 2;

    // REAL SCREENS CONNECTED HERE
    final List<Widget> screens = [
      HomeScreen(key: HomeScreen.globalKey),
      const MyGardenScreen(),
      LeafScanScreen(
        isActive: scannerActive,
        onBackPressed: () => setState(() => _currentIndex = 0),
      ),
      const MarketplaceScreen1(), // Make sure this matches your class name in marketplace_screen.dart
      const ProfileScreen(),      // Make sure this matches your class name in profile_screen.dart
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutBack,
        offset: scannerActive ? const Offset(0, 1) : Offset.zero,
        child: _BioNavBar(
          currentIndex: _currentIndex,
          scannerActive: scannerActive,
          pulseAnim: _pulseAnim,
          pulseController: _pulseController,
          onScanTap: () => setState(() => _currentIndex = 2),
          onItemTapped: (index) {
            if (index == 0 && _currentIndex == 0) {
              HomeScreen.globalKey.currentState?.refresh();
            }
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BIO-LUMINESCENT NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
class _BioNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;
  final bool scannerActive;
  final Animation<double>? pulseAnim;
  final AnimationController? pulseController;
  final VoidCallback onScanTap;

  const _BioNavBar({
    required this.currentIndex,
    required this.onItemTapped,
    required this.scannerActive,
    required this.pulseAnim,
    required this.pulseController,
    required this.onScanTap,
  });

  @override
  State<_BioNavBar> createState() => _BioNavBarState();
}

class _BioNavBarState extends State<_BioNavBar> with TickerProviderStateMixin {
  late AnimationController _orbitA;
  late AnimationController _orbitB;
  late AnimationController _orbitC;
  late AnimationController _liquidBlob;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _orbitA = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
    _orbitB = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat();
    _orbitC = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))..repeat(reverse: true);
    _liquidBlob = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  }

  @override
  void dispose() {
    _orbitA.dispose();
    _orbitB.dispose();
    _orbitC.dispose();
    _liquidBlob.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  static const _navItems = [
    (icon: Icons.home_rounded,           label: 'Home',    index: 0, slot: 0),
    (icon: Icons.yard_rounded,           label: 'Garden',  index: 1, slot: 1),
    (icon: Icons.storefront_rounded,     label: 'Market',  index: 3, slot: 2),
    (icon: Icons.person_outline_rounded, label: 'Profile', index: 4, slot: 3),
  ];

  int get _activeSlot {
    for (final it in _navItems) {
      if (it.index == widget.currentIndex) return it.slot;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    const double barH      = 80.0;
    const double bottomPad = 16.0;
    const double sidePad   = 16.0;
    const double fabDiam   = 68.0;
    const double bloomDiam = 94.0;
    const double abovePill = (bloomDiam / 2) - (barH / 2);
    const double totalH    = abovePill + barH + bottomPad;

    return SizedBox(
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: sidePad, right: sidePad,
            bottom: bottomPad, height: barH,
            child: _buildBar(barH),
          ),
          if (!widget.scannerActive)
            Positioned(
              top: 0, left: 0, right: 0, height: bloomDiam,
              child: Center(
                child: AnimatedBuilder(
                  animation: widget.pulseAnim ?? const AlwaysStoppedAnimation(1.0),
                  builder: (_, child) => Transform.scale(
                    scale: widget.pulseAnim?.value ?? 1.0,
                    child: child,
                  ),
                  child: GestureDetector(
                    onTap: widget.onScanTap,
                    child: _buildFab(fabDiam, bloomDiam),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBar(double barH) {
    return ClipPath(
      clipper: _NavBarClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: CustomPaint(
          painter: _NavBarPainter(shimmer: _shimmerCtrl),
          child: Stack(
            children: [
              if (_activeSlot >= 0)
                _LiquidIndicator(
                  slot: _activeSlot,
                  totalSlots: 4,
                  barH: barH,
                  color: AppColors.primaryGreen,
                ),
              Row(
                children: [
                  ...[_navItems[0], _navItems[1]].map((it) => Expanded(
                    child: _BioNavItem(
                      icon: it.icon,
                      label: it.label,
                      selected: widget.currentIndex == it.index,
                      onTap: () => widget.onItemTapped(it.index),
                    ),
                  )),
                  const SizedBox(width: 72),
                  ...[_navItems[2], _navItems[3]].map((it) => Expanded(
                    child: _BioNavItem(
                      icon: it.icon,
                      label: it.label,
                      selected: widget.currentIndex == it.index,
                      onTap: () => widget.onItemTapped(it.index),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab(double fabDiam, double bloomDiam) {
    return SizedBox(
      width: bloomDiam,
      height: bloomDiam,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _orbitC,
            builder: (_, __) => Container(
              width: bloomDiam,
              height: bloomDiam,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.22 + _orbitC.value * 0.08),
                    AppColors.primaryGreen.withOpacity(0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbitA,
            builder: (_, __) => Transform.rotate(
              angle: _orbitA.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(82, 82),
                painter: _OrbitRingPainter(
                  radius: 40,
                  color: AppColors.primaryGreen.withOpacity(0.35),
                  dashCount: 12,
                  strokeWidth: 1.2,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbitB,
            builder: (_, __) => Transform.rotate(
              angle: -_orbitB.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(74, 74),
                painter: _OrbitRingPainter(
                  radius: 36,
                  color: const Color(0xFF6EEAA0).withOpacity(0.18),
                  dashCount: 8,
                  strokeWidth: 0.8,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbitA,
            builder: (_, __) {
              final angle = _orbitA.value * 2 * math.pi;
              return Transform.translate(
                offset: Offset(math.cos(angle) * 40, math.sin(angle) * 40),
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB0FFD8),
                    boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.9), blurRadius: 8, spreadRadius: 2)],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _orbitB,
            builder: (_, __) {
              final angle = -_orbitB.value * 2 * math.pi + math.pi;
              return Transform.translate(
                offset: Offset(math.cos(angle) * 36, math.sin(angle) * 36),
                child: Container(
                  width: 3.5, height: 3.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.7),
                    boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.6), blurRadius: 6)],
                  ),
                ),
              );
            },
          ),
          Container(
            width: fabDiam,
            height: fabDiam,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8DFFC4), Color(0xFF1DB954), Color(0xFF008C60)],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.65),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF00FFB2).withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 8, left: 10,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.white.withOpacity(0.35), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.energy_savings_leaf_rounded, color: Color(0xFF001A0F), size: 26),
                    Text(
                      'SCAN',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF001A0F),
                        letterSpacing: 2.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LIQUID BLOB INDICATOR 
// ─────────────────────────────────────────────────────────────────────────────
class _LiquidIndicator extends StatelessWidget {
  final int slot;
  final int totalSlots;
  final double barH;
  final Color color;

  const _LiquidIndicator({
    required this.slot,
    required this.totalSlots,
    required this.barH,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double barW = MediaQuery.of(context).size.width - 32; 
    final double itemW = (barW - 72) / 4;
    double left;
    if (slot < 2) {
      left = slot * itemW;
    } else {
      left = slot * itemW + 72;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      left: left + (itemW / 2) - 24, 
      top: 10, 
      child: Container(
        width: 48,
        height: 58, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.22),
              color.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: color.withOpacity(0.30), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BIO NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _BioNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BioNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: selected ? -5.0 : 0.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (_, dy, child) =>
                  Transform.translate(offset: Offset(0, dy), child: child),
              child: AnimatedScale(
                scale: selected ? 1.18 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: ShaderMask(
                  shaderCallback: (bounds) => selected
                      ? const LinearGradient(
                          colors: [Color(0xFF8DFFC4), Color(0xFF1DB954)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds)
                      : const LinearGradient(
                          colors: [Color(0x88FFFFFF), Color(0x88FFFFFF)], 
                        ).createShader(bounds),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.barlowCondensed(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected
                    ? AppColors.primaryGreen
                    : Colors.white.withOpacity(0.55), 
                letterSpacing: selected ? 1.2 : 0.4,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              width: selected ? 6 : 0,
              height: selected ? 6 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.9),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM CLIPPER 
// ─────────────────────────────────────────────────────────────────────────────
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 36.0;
    const archR  = 42.0;
    final cx = size.width / 2;
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(cx - archR - 14, 0)
      ..quadraticBezierTo(cx - archR, 0, cx - archR, -archR * 0.32)
      ..arcToPoint(
        Offset(cx + archR, -archR * 0.32),
        radius: const Radius.circular(archR),
        clockwise: false,
      )
      ..quadraticBezierTo(cx + archR, 0, cx + archR + 14, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius))
      ..lineTo(radius, size.height)
      ..arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius))
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius))
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM PAINTER 
// ─────────────────────────────────────────────────────────────────────────────
class _NavBarPainter extends CustomPainter {
  final AnimationController shimmer;

  _NavBarPainter({required this.shimmer}) : super(repaint: shimmer);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFF050E07)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawHexGrid(canvas, size);

    final shimX = shimmer.value * (size.width + 200) - 100;
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [
          Colors.transparent,
          const Color(0xFF2AFF8A).withOpacity(0.035),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(shimX - 60, 0, 120, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);

    final edgePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF1DB954).withOpacity(0.45),
          const Color(0xFF8DFFC4).withOpacity(0.6),
          const Color(0xFF1DB954).withOpacity(0.45),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 2))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, 0.5), Offset(size.width, 0.5), edgePaint);
  }

  void _drawHexGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1DB954).withOpacity(0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    const r = 10.0;
    final h = r * math.sqrt(3);
    for (double y = -h; y < size.height + h; y += h) {
      for (double x = -r * 1.5; x < size.width + r * 1.5; x += r * 3) {
        final offset = (((y / h).round()) % 2 == 0) ? 0.0 : r * 1.5;
        _drawHex(canvas, paint, Offset(x + offset, y), r);
      }
    }
  }

  void _drawHex(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  ORBIT RING PAINTER 
// ─────────────────────────────────────────────────────────────────────────────
class _OrbitRingPainter extends CustomPainter {
  final double radius;
  final Color color;
  final int dashCount;
  final double strokeWidth;

  const _OrbitRingPainter({
    required this.radius,
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.38;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}