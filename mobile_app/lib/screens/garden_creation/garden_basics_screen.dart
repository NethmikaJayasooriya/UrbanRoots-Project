import 'package:flutter/material.dart';

class GardenBasicsScreen extends StatefulWidget {
  const GardenBasicsScreen({super.key});

  @override
  State<GardenBasicsScreen> createState() => _GardenBasicsScreenState();
}

class _GardenBasicsScreenState extends State<GardenBasicsScreen> {
  //Controller to capture the text input
  final TextEditingController _nameController = TextEditingController();

  // 2. State variables to store user choices
  String _selectedSpace = ''; // Stores 'Indoor', 'Balcony', etc.
  bool _isLocating = false; // For the location loading animation
  String _locationText = "📍 Colombo, Sri Lanka"; // Default/Fetched location

  // 3. The list of Space Options
  final List<Map<String, dynamic>> _spaceOptions = [
    {'label': 'Indoor', 'icon': Icons.home},
    {'label': 'Balcony', 'icon': Icons.apartment},
    {'label': 'Rooftop', 'icon': Icons.wb_sunny},
    {'label': 'Outdoor', 'icon': Icons.park},
  ];

  // 4. Function to Simulate getting GPS Location
  void _fetchLocation() async {
    setState(() => _isLocating = true);
    
    // Simulate API delay (Replace this with Geolocator logic later)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLocating = false;
      _locationText = "📍 Battaramulla, Sri Lanka"; // Mock result
    });
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color kBgColor = Color(0xFF121413);
    const Color kPrimaryGreen = Color(0xFF2ECC71);
    const Color kCardColor = Color(0xFF2C2F2E);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //HEADER
              const Text(
                "Let's setup\nyour space.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              //NAME
              const Text("Give your garden a name", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "e.g., Balcony Oasis",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: kCardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              //LOCATION
              const Text("Location", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location Text
                    Text(
                      _locationText,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    // Loading or Refresh Icon
                    _isLocating
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGreen),
                          )
                        : TextButton(
                            onPressed: _fetchLocation,
                            child: const Text("Update", style: TextStyle(color: kPrimaryGreen)),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              //SPACE TYPE (GRID) ---
              const Text("What kind of space is it?", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true, //Lets GridView sit inside a Column
                physics: const NeverScrollableScrollPhysics(), // Disables Grid's own scrolling
                itemCount: _spaceOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Columns
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.3, // Shape of the card 
                ),
                itemBuilder: (context, index) {
                  final option = _spaceOptions[index];
                  final isSelected = _selectedSpace == option['label'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpace = option['label'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryGreen.withOpacity(0.2) : kCardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? kPrimaryGreen : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'],
                            size: 30,
                            color: isSelected ? kPrimaryGreen : Colors.white54,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            option['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              //NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    //Ensure they picked a space before moving
                    if (_selectedSpace.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a space type!")),
                      );
                      return;
                    }
                    //Navigate to Screen 2
                    print("Name: ${_nameController.text}, Space: $_selectedSpace");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Next  ➔", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}