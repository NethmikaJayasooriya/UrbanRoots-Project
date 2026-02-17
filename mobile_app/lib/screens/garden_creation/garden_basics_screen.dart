import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'iot_connection_screen.dart';

class GardenBasicsScreen extends StatefulWidget {
  const GardenBasicsScreen({super.key});

  @override
  State<GardenBasicsScreen> createState() => _GardenBasicsScreenState();
}

class _GardenBasicsScreenState extends State<GardenBasicsScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  // selection state
  int _selectedSpaceIndex = -1;
  bool _isLocating = false;
  String _locationText = "Colombo, Sri Lanka";

  final List<Map<String, dynamic>> _spaceOptions = [
    {'label': 'Indoor', 'image': 'assets/images/indoor.jpg'},
    {'label': 'Balcony', 'image': 'assets/images/balcony.jpg'},
    {'label': 'Rooftop', 'image': 'assets/images/rooftop.jpg'},
    {'label': 'Outdoor', 'image': 'assets/images/outdoor.jpg'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // load images early to prevent flashing
    for (var option in _spaceOptions) {
      precacheImage(AssetImage(option['image']), context);
    }
  }

  void _fetchLocation() async {
    setState(() => _isLocating = true);
    // simulate api call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLocating = false;
        _locationText = "Battaramulla, Sri Lanka";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF07160F);
    const surfaceColor = Color(0xFF16201B);
    const neonGreen = Color(0xFF00E676);
    bool isSelectionValid = _selectedSpaceIndex != -1;

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
              Text("Let's setup\nyour space.",
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
              const SizedBox(height: 30),

              // name input
              Text("Give your garden a name", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: surfaceColor,
                  hintText: "e.g., Balcony Oasis",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: neonGreen)),
                ),
              ),
              const SizedBox(height: 25),

              // location section
              Text("Location", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: _isLocating
                          ? const LinearProgressIndicator(color: neonGreen, minHeight: 2)
                          : Text(_locationText, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _fetchLocation,
                      child: Text("Update", style: GoogleFonts.poppins(color: neonGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // space type grid
              Text("What kind of space is it?", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.1),
                itemCount: _spaceOptions.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedSpaceIndex == index;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpaceIndex = index),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // background image
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: surfaceColor, 
                            image: DecorationImage(
                              image: AssetImage(_spaceOptions[index]['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        // dark overlay (animates opacity)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(isSelected ? 0.2 : 0.5),
                          ),
                        ),

                        // green border (animates)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? neonGreen : Colors.transparent, 
                              width: 3
                            ),
                          ),
                        ),

                        // label text
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _spaceOptions[index]['label'],
                              style: GoogleFonts.poppins(
                                color: Colors.white, 
                                fontSize: 16, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                              )
                            ),
                          ),
                        ),
                        
                        // checkmark icon
                        if (isSelected)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: neonGreen),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.check, size: 16, color: Colors.black),
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
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IoTConnectionScreen()))
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    disabledBackgroundColor: surfaceColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Next", style: GoogleFonts.poppins(color: isSelectionValid ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: isSelectionValid ? Colors.black : Colors.grey),
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