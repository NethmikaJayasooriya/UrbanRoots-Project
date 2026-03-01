import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your actual screen files here
// import 'home_screen.dart';
// import 'my_garden_screen.dart';
// import 'marketplace_screen.dart';
// import 'profile_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  // tracks the current active tab
  int _currentIndex = 0;

  // list of the main screens
  final List<Widget> _screens = [
    const Center(child: Text("Home Screen with Pet", style: TextStyle(color: Colors.white))), 
    const Center(child: Text("My Garden List", style: TextStyle(color: Colors.white))),    
    const Center(child: Text("Marketplace", style: TextStyle(color: Colors.white))),       
    const Center(child: Text("Profile Settings", style: TextStyle(color: Colors.white))),   
  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const surfaceColor = Color(0xFF16201B);
    const neonGreen = Color(0xFF00E676);

    return Scaffold(
      backgroundColor: bgColor,
      // the body changes based on the selected index
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed, // ensures labels always show
          backgroundColor: surfaceColor,
          selectedItemColor: neonGreen,
          unselectedItemColor: Colors.white30,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.yard_rounded),
              label: 'My Garden',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}