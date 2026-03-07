import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Garden/my_Garden.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;

  // Pulse animation 
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
    const bgColor = Color(0xFF07160F);
    const surfaceColor = Color(0xFF16201B);
    const neonGreen = Color(0xFF00E676);
    final bool scannerActive = _currentIndex == 2;

    final List<Widget> screens = [
      const Center(child: Text("Home Feed (Digital Pet)", style: TextStyle(color: Colors.white))),
      const MyGardenScreen(),
      const Center(child: Text("Global Leaf Health Scanner", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Marketplace", style: TextStyle(color: Colors.white))),
      const Center(child: Text("User Profile", style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      //LEAF SCAN FAB
      floatingActionButton: GestureDetector(
        onTap: () => setState(() => _currentIndex = 2),
        child: AnimatedBuilder(
          animation: _pulseAnim ?? const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            final scale = scannerActive ? 1.0 : (_pulseAnim?.value ?? 1.0);
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: scannerActive
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
                    ),
              color: scannerActive ? neonGreen : null,
              boxShadow: [
                BoxShadow(
                  color: neonGreen.withOpacity(scannerActive ? 0.7 : 0.4),
                  blurRadius: scannerActive ? 20 : 14,
                  spreadRadius: scannerActive ? 4 : 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.energy_savings_leaf_rounded,
                  color: Colors.black,
                  size: 26,
                ),
                Text(
                  "SCAN",
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BOTTOM APP BAR
      bottomNavigationBar: BottomAppBar(
        color: surfaceColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "Home", 0, neonGreen),
              _buildNavItem(Icons.yard_rounded, "Garden", 1, neonGreen),
              const SizedBox(width: 56), 
              _buildNavItem(Icons.storefront_rounded, "Market", 3, neonGreen),
              _buildNavItem(Icons.person_outline_rounded, "Profile", 4, neonGreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white30,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}