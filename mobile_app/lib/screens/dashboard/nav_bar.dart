import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

// Your local imports based on the screenshot
import 'Home.dart'; 
import 'garden/myGarden_firstLogin.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with SingleTickerProviderStateMixin {
  
  // CHANGED: Default to 0 so the user lands on the Digital Pet Home Screen first!
  int _currentIndex = 0;

  // Animation controller for the scanner button pulse effect
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

    // CHANGED: Plugged in the real HomeScreen() at index 0
    final List<Widget> screens = [
      const HomeScreen(), // The Digital Pet screen!
      const MyGardenScreen(),
      const Center(child: Text("Global Leaf Health Scanner", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Marketplace", style: TextStyle(color: Colors.white))),
      const Center(child: Text("User Profile", style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      // Floating Action Button for the Global Leaf Scanner
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
                      colors: [AppColors.primaryGreen, Color(0xFF00BFA5)],
                    ),
              color: scannerActive ? AppColors.primaryGreen : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(scannerActive ? 0.7 : 0.4),
                  blurRadius: scannerActive ? 20 : 14,
                  spreadRadius: scannerActive ? 4 : 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
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

      // The Bottom Navigation Bar with the central notch
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surfaceColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "Home", 0),
              _buildNavItem(Icons.yard_rounded, "Garden", 1),
              const SizedBox(width: 56), // Gap for the scanner button
              _buildNavItem(Icons.storefront_rounded, "Market", 3),
              _buildNavItem(Icons.person_outline_rounded, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build individual navigation tabs
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGreen : Colors.white30,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primaryGreen : Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}