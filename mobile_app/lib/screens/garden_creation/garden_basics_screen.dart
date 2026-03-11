import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart'; 
import 'iot_connection_screen.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class GardenBasicsScreen extends StatefulWidget {
  const GardenBasicsScreen({super.key});

  @override
  State<GardenBasicsScreen> createState() => _GardenBasicsScreenState();
}

class _GardenBasicsScreenState extends State<GardenBasicsScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  int _selectedSpaceIndex = -1;
  bool _isLocating = false;
  String _locationText = "Location not set";
  
  double? _latitude;
  double? _longitude;

  final List<Map<String, dynamic>> _spaceOptions = [
    {'label': 'Indoor', 'image': 'assets/images/indoor.webp'},
    {'label': 'Balcony', 'image': 'assets/images/balcony.webp'},
    {'label': 'Rooftop', 'image': 'assets/images/rooftop.webp'},
    {'label': 'Outdoor', 'image': 'assets/images/outdoor.webp'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var option in _spaceOptions) {
      precacheImage(AssetImage(option['image']), context);
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocating = false;
          _locationText = "Location services disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocating = false;
            _locationText = "Permission denied";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      if (mounted) {
        setState(() {
          _isLocating = false;
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationText = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        });
      }
    } catch (e) {
      setState(() {
        _isLocating = false;
        _locationText = "Error fetching location";
      });
    }
  }

  // Instead of saving to the DB here, we bundle the data and pass it to the next screen!
  void _goToNextScreen() {
    final Map<String, dynamic> gardenData = {
      "user_id": "test-user-123", // Replace this later when you add Auth
      "garden_name": _nameController.text,
      "location": _locationText,
      "latitude": _latitude,
      "longitude": _longitude,
      "environment": _spaceOptions[_selectedSpaceIndex]['label'],
    };

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => IoTConnectionScreen(gardenData: gardenData)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSelectionValid = _selectedSpaceIndex != -1 && 
                            _nameController.text.isNotEmpty && 
                            _latitude != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Let's setup\nyour space.",
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.2)),
              const SizedBox(height: 30),

              Text("Give your garden a name", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                onChanged: (value) => setState(() {}),
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                  hintText: "e.g., Balcony Oasis",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen)),
                ),
              ),
              const SizedBox(height: 25),

              Text("Location (GPS)", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: _latitude != null ? AppColors.primaryGreen : Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isLocating
                          ? const LinearProgressIndicator(color: AppColors.primaryGreen, minHeight: 2)
                          : Text(_locationText, style: GoogleFonts.poppins(color: AppColors.textMain, fontSize: 15)),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _fetchLocation,
                      child: Text(_isLocating ? "Waiting..." : "Get GPS", style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.surfaceColor, 
                            image: DecorationImage(
                              image: AssetImage(_spaceOptions[index]['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(isSelected ? 0.2 : 0.5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryGreen : Colors.transparent, 
                              width: 3
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _spaceOptions[index]['label'],
                              style: GoogleFonts.poppins(
                                color: AppColors.textMain, 
                                fontSize: 16, 
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                              )
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryGreen),
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

              // Button just passes data forward now
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSelectionValid ? _goToNextScreen : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.surfaceColor,
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