import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'Home.dart'; 
import 'garden/my_Garden.dart';
import '../../leaf_disease_screen.dart'; 

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

    final List<Widget> screens = [
      const HomeScreen(), 
      const MyGardenScreen(), 
      
      // Update: Pass onBackPressed to handle IndexedStack navigation
      LeafScanScreen(
        isActive: scannerActive,
        onBackPressed: () => setState(() => _currentIndex = 0),
      ), 
      
      const Center(child: Text("Marketplace", style: TextStyle(color: Colors.white))),
      const Center(child: Text("User Profile", style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: false,
      // Update: Prevent ViewInsets assertion crash on Flutter Web
      resizeToAvoidBottomInset: false, 
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      // Update: Hide the FAB completely when the scanner is active
      floatingActionButton: scannerActive 
        ? null 
        : GestureDetector(
            onTap: () => setState(() => _currentIndex = 2),
            child: AnimatedBuilder(
              animation: _pulseAnim ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnim?.value ?? 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreen, Color(0xFF00BFA5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.4),
                      blurRadius: 14,
                      spreadRadius: 1,
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
              const SizedBox(width: 56), 
              _buildNavItem(Icons.storefront_rounded, "Market", 3),
              _buildNavItem(Icons.person_outline_rounded, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

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