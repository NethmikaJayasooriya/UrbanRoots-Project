import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GardenBasicsScreen extends StatefulWidget {
  const GardenBasicsScreen({super.key});

  @override
  State<GardenBasicsScreen> createState() => _GardenBasicsScreenState();
}

class _GardenBasicsScreenState extends State<GardenBasicsScreen> {
  // text controller for garden name
  final TextEditingController _nameController = TextEditingController();

  // selection variables
  int _selectedSpaceIndex = -1;
  bool _isLocating = false;
  String _locationText = "Colombo, Sri Lanka";

  // space options data
  final List<Map<String, dynamic>> _spaceOptions = [
    {
      'label': 'Indoor',
      'image': 'assets/images/indoor.jpg',
      'id': 'indoor'
    },
    {
      'label': 'Balcony',
      'image': 'assets/images/balcony.jpg',
      'id': 'balcony'
    },
    {
      'label': 'Rooftop',
      'image': 'assets/images/rooftop.jpg',
      'id': 'rooftop'
    },
    {
      'label': 'Outdoor',
      'image': 'assets/images/outdoor.jpg',
      'id': 'outdoor'
    },
  ];

  // mock gps function
  void _fetchLocation() async {
    setState(() => _isLocating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLocating = false;
      _locationText = "Battaramulla, Sri Lanka";
    });
  }

  @override
  Widget build(BuildContext context) {
    // colors
    const bgColor = Color(0xFF121413);
    const surfaceColor = Color(0xFF1E2220);
    const neonGreen = Color(0xFF00E676);

    // check if user has selected a space
    bool isSelectionValid = _selectedSpaceIndex != -1;

    // gesture detector hides keyboard when tapping background
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              Text(
                "Let's setup\nyour space.",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              // name input
              Text(
                "Give your garden a name",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceColor,
                  hintText: "e.g., Balcony Oasis",
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: neonGreen),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // location
              Text(
                "Location",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _isLocating
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 150, 
                                child: const LinearProgressIndicator(
                                  color: neonGreen,
                                  minHeight: 4,
                                ),
                              ),
                            )
                          : Text(
                              _locationText,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 15),
                            ),
                    ),
                    GestureDetector(
                      onTap: _fetchLocation,
                      child: Text(
                        "Update",
                        style: GoogleFonts.poppins(
                          color: neonGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // space selection grid
              Text(
                "What kind of space is it?",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: _spaceOptions.length,
                itemBuilder: (context, index) {
                  final option = _spaceOptions[index];
                  final isSelected = _selectedSpaceIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSpaceIndex = index);
                    },
                    // using stack to fix image flickering
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // static image background
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(option['image']),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.4),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                        
                        // label text
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              option['label'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // animated border overlay
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: neonGreen, width: 3)
                                : Border.all(color: Colors.transparent, width: 0),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: neonGreen.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // next button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                 onPressed: isSelectionValid
    ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IoTConnectionScreen(),
          ),
        );
      }
    : null,// disable button if nothing selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelectionValid ? neonGreen : surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isSelectionValid ? 5 : 0,
                    shadowColor: neonGreen.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Next",
                        style: GoogleFonts.poppins(
                          color: isSelectionValid ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: isSelectionValid ? Colors.black : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}