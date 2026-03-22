import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/api/api_service.dart';
import 'Home.dart';
import 'Garden/my_Garden.dart';
import '../../leaf_disease_screen.dart';

// EXACT IMPORTS BASED ON YOUR PROJECT STRUCTURE
import 'Marketplace/marketplace_screen.dart';
import 'UserProfile/profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN NAVIGATION WRAPPER  (logic unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _triggerAutomatedStreak();
  }

  Future<void> _triggerAutomatedStreak() async {
    try {
      await ApiService.completeTodayStreak();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool scannerActive = _currentIndex == 2;

    final List<Widget> screens = [
      HomeScreen(key: HomeScreen.globalKey),
      const MyGardenScreen(),
      LeafScanScreen(
        isActive: scannerActive,
        onBackPressed: () => setState(() => _currentIndex = 0),
      ),
      const MarketplaceScreen1(),
      ProfileScreen(key: ProfileScreen.globalKey),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: scannerActive
          ? null
          : _FloatingGlassNavBar(
              currentIndex: _currentIndex,
              onItemTapped: (index) {
                if (index == 0 && _currentIndex == 0) {
                  HomeScreen.globalKey.currentState?.refresh();
                }
                if (index == 4) {
                  ProfileScreen.globalKey.currentState?.refresh();
                }
                setState(() => _currentIndex = index);
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  NAV BAR  —  Luminous Forest Capsule  ✦  redesigned visuals, logic intact
// ─────────────────────────────────────────────────────────────────────────────

// Shared palette tokens
const _kMint = Color(0xFF00FFA3);
const _kEmerald = Color(0xFF00C97B);
const _kDeepGreen = Color(0xFF003D22);
const _kSurface = Color(0xFF0A100D);
const _kBorder = Color(0xFF1E3328);

class _FloatingGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _FloatingGlassNavBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Left items: indices 0,1   Right items: 3,4
    const leftItems = [
      _ItemDef(Icons.home_rounded, 'Home', 0),
      _ItemDef(Icons.yard_rounded, 'Garden', 1),
    ];
    const rightItems = [
      _ItemDef(Icons.storefront_rounded, 'Market', 3),
      _ItemDef(Icons.person_outline_rounded, 'Profile', 4),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
        child: SizedBox(
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── glass pill ──────────────────────────────────────────────
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        color: _kSurface.withOpacity(0.92),
                        border: Border.all(
                          color: _kBorder,
                          width: 1.2,
                        ),
                        // Subtle top-edge aurora line
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _kMint.withOpacity(0.06),
                            _kSurface.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.35],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: _kMint.withOpacity(0.08),
                            blurRadius: 40,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── nav items ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left pair
                    ...leftItems.map((d) => _NavItem(
                          def: d,
                          isSelected: currentIndex == d.index,
                          onTap: () => onItemTapped(d.index),
                        )),

                    // Centre FAB — wider placeholder so spacing stays even
                    const SizedBox(width: 72),

                    // Right pair
                    ...rightItems.map((d) => _NavItem(
                          def: d,
                          isSelected: currentIndex == d.index,
                          onTap: () => onItemTapped(d.index),
                        )),
                  ],
                ),
              ),

              // ── centre scan button (floats above pill) ───────────────────
              Positioned(
                top: -14,
                child: _ScanCapsule(onTap: () => onItemTapped(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── tiny data holder ────────────────────────────────────────────────────────
class _ItemDef {
  final IconData icon;
  final String label;
  final int index;
  const _ItemDef(this.icon, this.label, this.index);
}

// ── individual nav tab ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final _ItemDef def;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.def,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with animated pill highlight
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: isSelected ? 46 : 36,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isSelected
                    ? _kMint.withOpacity(0.13)
                    : Colors.transparent,
                border: isSelected
                    ? Border.all(color: _kMint.withOpacity(0.22), width: 1)
                    : null,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    def.icon,
                    key: ValueKey(isSelected),
                    size: isSelected ? 22 : 20,
                    color: isSelected ? _kMint : const Color(0xFF4A6B58),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              style: GoogleFonts.spaceGrotesk(
                fontSize: isSelected ? 9.5 : 9,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: isSelected ? 0.8 : 0.4,
                color: isSelected ? _kMint : const Color(0xFF3D5E4A),
              ),
              child: Text(def.label),
            ),
            // Active dot
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kMint,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: _kMint.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── centre scan FAB ──────────────────────────────────────────────────────────
class _ScanCapsule extends StatefulWidget {
  final VoidCallback onTap;
  const _ScanCapsule({required this.onTap});

  @override
  State<_ScanCapsule> createState() => _ScanCapsuleState();
}

class _ScanCapsuleState extends State<_ScanCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: false);

    _pulse = Tween<double>(begin: 0.85, end: 1.08).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutSine),
      ),
    );

    _ring = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding ring
                Opacity(
                  opacity: (1.0 - _ring.value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.8 + _ring.value * 0.65,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _kMint.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Main button with scale pulse
                Transform.scale(
                  scale: _pulse.value,
                  child: child,
                ),
              ],
            ),
          );
        },
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_kMint, _kEmerald, _kDeepGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _kMint.withOpacity(0.55),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: _kEmerald.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated horizontal scan line sweeping through the leaf
              _ScanLineOverlay(),
              // Custom AI Plant Disease Detection icon
              CustomPaint(
                size: const Size(34, 34),
                painter: _AiLeafScanPainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated scan-line sweep over the FAB ────────────────────────────────────
class _ScanLineOverlay extends StatefulWidget {
  const _ScanLineOverlay();

  @override
  State<_ScanLineOverlay> createState() => _ScanLineOverlayState();
}

class _ScanLineOverlayState extends State<_ScanLineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _sweep = Tween<double>(begin: -14, end: 14).animate(
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
      animation: _sweep,
      builder: (_, __) {
        final opacity = (_ctrl.value < 0.15 || _ctrl.value > 0.85) ? 0.0 : 1.0;
        return Transform.translate(
          offset: Offset(0, _sweep.value),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 30,
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF001810).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Custom icon: leaf silhouette + AI scan brackets + disease dot ─────────────
class _AiLeafScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── colours ──────────────────────────────────────────────────────────────
    const bg     = Color(0xFF001810);
    const mint   = _kMint;       // #00FFA3
    const mintD  = Color(0xFF00FFA3);

    // ── leaf body ────────────────────────────────────────────────────────────
    final leafPaint = Paint()
      ..color = bg.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final leafPath = Path()
      ..moveTo(cx, size.height - 3)
      ..cubicTo(cx - 10, cy + 4, cx - 11, cy - 4, cx - 9, cy - 8)
      ..cubicTo(cx - 6, cy - 14, cx - 1, cy - 15, cx, cy - 15)
      ..cubicTo(cx + 1, cy - 15, cx + 6, cy - 14, cx + 9, cy - 8)
      ..cubicTo(cx + 11, cy - 4, cx + 10, cy + 4, cx, size.height - 3)
      ..close();
    canvas.drawPath(leafPath, leafPaint);

    // ── veins ────────────────────────────────────────────────────────────────
    final veinPaint = Paint()
      ..color = mint.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    // center vein
    canvas.drawLine(Offset(cx, size.height - 4), Offset(cx, cy - 12), veinPaint);

    // side veins (left)
    veinPaint.color = mint.withOpacity(0.4);
    veinPaint.strokeWidth = 0.85;
    canvas.drawLine(Offset(cx, cy + 2), Offset(cx - 7, cy - 3), veinPaint);
    canvas.drawLine(Offset(cx, cy - 4), Offset(cx - 6, cy - 9), veinPaint);
    // side veins (right)
    canvas.drawLine(Offset(cx, cy + 2), Offset(cx + 7, cy - 3), veinPaint);
    canvas.drawLine(Offset(cx, cy - 4), Offset(cx + 6, cy - 9), veinPaint);

    // ── AI scan corner brackets ───────────────────────────────────────────────
    final bPaint = Paint()
      ..color = mintD
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const bLen = 4.5;
    // top-left
    canvas.drawLine(Offset(cx - 13, cy - 13), Offset(cx - 13, cy - 13 + bLen), bPaint);
    canvas.drawLine(Offset(cx - 13, cy - 13), Offset(cx - 13 + bLen, cy - 13), bPaint);
    // top-right
    canvas.drawLine(Offset(cx + 13, cy - 13), Offset(cx + 13, cy - 13 + bLen), bPaint);
    canvas.drawLine(Offset(cx + 13, cy - 13), Offset(cx + 13 - bLen, cy - 13), bPaint);
    // bottom-left
    canvas.drawLine(Offset(cx - 13, cy + 10), Offset(cx - 13, cy + 10 - bLen), bPaint);
    canvas.drawLine(Offset(cx - 13, cy + 10), Offset(cx - 13 + bLen, cy + 10), bPaint);
    // bottom-right
    canvas.drawLine(Offset(cx + 13, cy + 10), Offset(cx + 13, cy + 10 - bLen), bPaint);
    canvas.drawLine(Offset(cx + 13, cy + 10), Offset(cx + 13 - bLen, cy + 10), bPaint);

    // ── disease detection dot (ring + filled centre) ──────────────────────────
    final ringPaint = Paint()
      ..color = mint.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(Offset(cx + 5, cy - 1), 2.6, ringPaint);

    final dotPaint = Paint()..color = mint.withOpacity(0.9);
    canvas.drawCircle(Offset(cx + 5, cy - 1), 0.9, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}