import 'package:flutter/material.dart';
import 'user_3.dart';

class UserProfile2 extends StatefulWidget {
  const UserProfile2({super.key});

  @override
  State<UserProfile2> createState() => _UserProfile2State();
}

class _UserProfile2State extends State<UserProfile2> {
  final Color glowRed = Colors.redAccent;
  final Color glowGreen = const Color(0xFF00FF9D);

  bool _submitted = false;

  // Multi-select: Shopping Preferences
  final List<String> _shoppingOptions = [
    "Eco-friendly products",
    "Organic products",
    "Sustainable home items",
    "Recycled products",
    "Green technology",
    "Local handmade products",
  ];
  final Set<String> _selectedShopping = {};

  // Single-selects
  final List<String> _priceOptions = [
    "Budget-friendly",
    "Mid-range",
    "Premium products",
    "No preference"
  ];
  String _selectedPrice = "";

  final List<String> _discoveryOptions = [
    "Trending products",
    "New arrivals",
    "Best rated",
    "Nearby products",
    "Personalized recommendations"
  ];
  String _selectedDiscovery = "";

  final List<String> _deliveryOptions = [
    "Local pickup",
    "Standard delivery",
    "Express delivery",
    "No preference"
  ];
  String _selectedDelivery = "";

  final List<String> _offersOptions = [
    "Notify me about discounts",
    "Only major sales",
    "No promotional notifications"
  ];
  String _selectedOffers = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: glowGreen),
        title: const Text(
          "Customize Your Marketplace Experience",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (Step 2 of 3)
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= 1 ? glowGreen : Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 25),

              // Header
              const Text(
                "Tell us your preferences to personalize your shopping experience.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Shopping Preferences (Multi-select)
              const Text(
                "🛍 Shopping Preferences (Select all that apply)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildMultiSelect(_shoppingOptions, _selectedShopping),
              const SizedBox(height: 30),

              // Price Preference (Single-select)
              const Text(
                "💰 Price Preference (Select one)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(
                _priceOptions,
                _selectedPrice,
                    (val) => _selectedPrice = val,
                requiredField: true,
              ),
              const SizedBox(height: 30),

              // Product Discovery Preference (Single-select)
              const Text(
                "🔍 Product Discovery Preference (Select one)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(
                _discoveryOptions,
                _selectedDiscovery,
                    (val) => _selectedDiscovery = val,
                requiredField: true,
              ),
              const SizedBox(height: 30),

              // Delivery Preference (Single-select)
              const Text(
                "🚚 Delivery Preference (Select one)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(
                _deliveryOptions,
                _selectedDelivery,
                    (val) => _selectedDelivery = val,
                requiredField: true,
              ),
              const SizedBox(height: 30),

              // Offers & Discounts (Single-select)
              const Text(
                "🎁 Offers & Discounts (Select one)",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
              _buildSingleSelect(
                _offersOptions,
                _selectedOffers,
                    (val) => _selectedOffers = val,
                requiredField: true,
              ),
              const SizedBox(height: 40),

              // Next Step Button (scrolls with content)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _submitted = true);

                    bool valid = _selectedShopping.isNotEmpty &&
                        _selectedPrice.isNotEmpty &&
                        _selectedDiscovery.isNotEmpty &&
                        _selectedDelivery.isNotEmpty &&
                        _selectedOffers.isNotEmpty;

                    if (!valid) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profile3Screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: glowGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Next Step",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

  // Multi-select
  Widget _buildMultiSelect(List<String> options, Set<String> selectedValues) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final bool isSelected = selectedValues.contains(option);
        final bool showRed = _submitted && selectedValues.isEmpty;

        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              selectedValues.remove(option);
            } else {
              selectedValues.add(option);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: showRed ? glowRed : (isSelected ? glowGreen : Colors.white12),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: glowGreen, blurRadius: 15, spreadRadius: 2)]
                  : [],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Single-select
  Widget _buildSingleSelect(
      List<String> options, String selectedValue, ValueChanged<String> onSelected,
      {bool requiredField = false}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final bool isSelected = option == selectedValue;
        final bool showRed = _submitted && requiredField && selectedValue.isEmpty;

        return GestureDetector(
          onTap: () => setState(() => onSelected(option)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: showRed ? glowRed : (isSelected ? glowGreen : Colors.white12),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: glowGreen, blurRadius: 15, spreadRadius: 2)]
                  : [],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
