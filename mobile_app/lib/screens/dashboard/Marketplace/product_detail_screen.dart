// product_detail_screen.dart
//
// Displays the full details of a single product when a product card is tapped.
// Contains four sections:
//   1. Hero product image with a back button overlaid
//   2. Product name, category badge, and price
//   3. Product summary / description
//   4. Reviews section — displays existing reviews and a form to submit new ones
//
// Navigation: pushed from MarketplaceScreen1 via Navigator.push.
// The Product object is passed in as a constructor argument — no extra data fetching needed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'marketplace_screen.dart'; // Needed for the Product data class

// ─── Review ───────────────────────────────────────────────────────────────────
// A simple data class representing a single user review.
// In a real app these would come from an API; here they are held in local state.
class Review {
  final String author;   // Display name of the reviewer
  final int rating;      // 1–5 star rating
  final String comment;  // Written review body
  final String date;     // Display date string e.g. "Mar 2024"

  const Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// ─── ProductDetailScreen ───────────────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  // The product whose details are being shown.
  // Passed in from MarketplaceScreen1 when a card is tapped.
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ──────────────────────────────────────────────────────────────
  // AnimationController drives the slide-up + fade-in of the content panel.
  // SingleTickerProviderStateMixin provides the vsync needed by the controller.
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation; // Slides the panel up from below
  late final Animation<double> _fadeAnimation;  // Fades the panel in simultaneously

  // ── Review state ───────────────────────────────────────────────────────────
  // Seed reviews shown when the screen first opens.
  // In production, fetch these from your API in initState().
  final List<Review> _reviews = [
    const Review(
      author: 'Amal P.',
      rating: 5,
      comment: 'Germinated within a week! Very healthy plants.',
      date: 'Feb 2025',
    ),
    const Review(
      author: 'Dilini R.',
      rating: 4,
      comment: 'Great quality seeds. A few didn\'t sprout but most did.',
      date: 'Jan 2025',
    ),
  ];

  // ── Review form state ──────────────────────────────────────────────────────
  final _commentController = TextEditingController(); // Holds the typed comment
  int _selectedRating = 0; // 0 = no star selected yet; 1–5 = chosen rating
  bool _isSubmitting = false; // True while the simulated API call is running

  @override
  void initState() {
    super.initState();

    // Set up the animation: 400ms, decelerating curve (fast start, smooth finish)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Slide: starts at Offset(0, 0.12) — 12% below final position — slides to (0,0)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    // Fade: starts fully transparent (0.0), ends fully visible (1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    // Start the animation immediately when the screen opens
    _animController.forward();
  }

  @override
  void dispose() {
    // Always dispose AnimationController and TextEditingController to free memory
    _animController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // ── Computed average rating ────────────────────────────────────────────────
  // Returns 0.0 if there are no reviews yet, otherwise the mean of all ratings.
  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true lets the hero image bleed up behind the app bar,
      // giving a full-bleed image effect with the back button floating on top.
      extendBodyBehindAppBar: true,

      // Transparent app bar so only the back button is visible over the image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Custom back button with a white circle background for contrast over any image
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // ── Section 1: Hero Image ────────────────────────────────────────
          _buildHeroImage(),

          // ── Sections 2, 3, 4: Scrollable content panel ──────────────────
          // FadeTransition + SlideTransition animate the panel on screen entry.
          // Expanded makes this column fill the remaining vertical space.
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  // White card panel with rounded top corners
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  // SingleChildScrollView lets the content scroll independently
                  // of the fixed hero image above
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(),    // Section 2
                        const SizedBox(height: 20),
                        _buildProductSummary(),   // Section 3
                        const SizedBox(height: 28),
                        _buildReviewForm(),       // Review submission form
                        const SizedBox(height: 16),
                        _buildReviewsSection(),   // Section 4
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Floating Add to Cart Button ──────────────────────────────────────
      // floatingActionButton positions this above the keyboard and content.
      // Using floatingActionButtonLocation.centerFloat centres it horizontally.
      floatingActionButton: _buildAddToCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── _buildHeroImage ────────────────────────────────────────────────────────
  // Renders the product image area at the top of the screen.
  // Currently uses a placeholder icon; swap Container for Image.network() when
  // your Product model has an imageUrl field.
  Widget _buildHeroImage() {
    return Container(
      height: 300, // Fixed height — adjust to taste
      width: double.infinity,
      decoration: BoxDecoration(
        // Gradient from deep green to light green for a natural / plant feel
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade700,
            Colors.green.shade200,
          ],
        ),
      ),
      child: Center(
        // Replace this with Image.network(widget.product.imageUrl) once
        // your Product model and backend support image URLs
        child: Icon(
          Icons.eco,
          size: 100,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  // ── _buildProductHeader ────────────────────────────────────────────────────
  // Section 2: product name, category chip, star rating summary, and price.
  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle pill — visual affordance that the panel is scrollable
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Product name — large, bold
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Category badge + star rating in a row
        Row(
          children: [
            // Category chip — green pill label
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                widget.product.category,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Average star rating (filled gold star icon)
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              _reviews.isEmpty
                  ? 'No ratings yet'
                  : '${_averageRating.toStringAsFixed(1)} (${_reviews.length} review${_reviews.length == 1 ? '' : 's'})',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price — prominent, green
        Text(
          'Rs. ${widget.product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  // ── _buildProductSummary ───────────────────────────────────────────────────
  // Section 3: a written description of the product.
  // In production, add a `description` field to the Product class and populate
  // it from your product API. The static map below is a temporary stand-in.
  Widget _buildProductSummary() {
    // Temporary product descriptions keyed by product name.
    // Replace with widget.product.description once the field exists.
    const descriptions = {
      'Green Chilli Seeds':
          'High-yield green chilli seeds suited for container and garden growing. '
          'These seeds produce medium-hot chillis in 70–80 days. '
          'Perfect for Sri Lankan cuisine — ideal for growing on apartment balconies.',
      'Basil Plant':
          'Fresh Genovese basil in a 4-inch nursery pot. Aromatic and bushy, '
          'this variety thrives indoors with 6+ hours of indirect sunlight. '
          'Pinch the flowers to keep leaves producing all season.',
      'Spinach Seeds':
          'Fast-germinating spinach seeds — harvest baby leaves in as little as '
          '25 days. High in iron and vitamins. Grows well in partial shade, '
          'making it ideal for balcony vegetable patches.',
      'Garden Trowel':
          'Heavy-duty stainless steel trowel with an ergonomic non-slip grip. '
          'Rust-resistant blade with depth markings for precise planting. '
          'Suitable for potting, transplanting, and weeding.',
    };

    // Fall back to a generic description if the product isn't in the map
    final description = descriptions[widget.product.name] ??
        'A quality product from UrbanRoots. Perfect for urban gardening enthusiasts.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        const Text(
          'About this product',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        // Description body text
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6, // Line height — improves readability for paragraph text
          ),
        ),
      ],
    );
  }

  // ── _buildReviewsSection ───────────────────────────────────────────────────
  // Section 4a: heading and list of existing review cards.
  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading row with review count badge
        Row(
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            // Count badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_reviews.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Empty state when no reviews exist yet
        if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('No reviews yet — be the first!',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),

        // Review cards — one per review in the list
        // ListView.builder would be more efficient for long lists, but since
        // reviews are nested inside a SingleChildScrollView with shrinkWrap,
        // Column + map is simpler and avoids nested scroll conflicts.
        ..._reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  // ── _buildReviewCard ───────────────────────────────────────────────────────
  // Renders a single review card with avatar, name, date, stars, and comment.
  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + author name + date
          Row(
            children: [
              // Avatar circle with the reviewer's first letter
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green.shade100,
                child: Text(
                  review.author[0], // First character of the name
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Author name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.author,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(review.date,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),

              // Star rating — renders filled stars up to the review's rating,
              // and outlined stars for the remainder up to 5
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Review comment body
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── _buildReviewForm ───────────────────────────────────────────────────────
  // Section 4b: form for submitting a new review.
  // Includes an interactive star rating row and a text field for the comment.
  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Light green tint to visually separate the form from the review list
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave a Review',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // ── Star picker ──────────────────────────────────────────────────
          // Tapping a star sets _selectedRating to that star's index (1-based).
          // The row re-renders with filled stars up to the selected rating.
          const Text('Your Rating',
              style: TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                // i is 0-based; we store 1-based rating so add 1
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    // Fill the star if its 1-based index ≤ selected rating
                    i < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // ── Comment text field ───────────────────────────────────────────
          TextField(
            controller: _commentController,
            maxLines: 3,    // Allows multi-line input
            maxLength: 300, // Prevents excessively long comments
            decoration: InputDecoration(
              hintText: 'Share your experience with this product...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Submit button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              // Disabled while submitting to prevent duplicate submissions
              onPressed: _isSubmitting ? null : _submitReview,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Submit Review',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── _buildAddToCartButton ──────────────────────────────────────────────────
  // A wide floating action button pinned above the bottom edge.
  // Uses context.read() because it's inside a callback, not build().
  Widget _buildAddToCartButton() {
    return Padding(
      // Horizontal padding so the button doesn't touch the screen edges
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          onPressed: () {
            // Add this product to the cart using CartModel via Provider
            context.read<CartModel>().addItem(
                  CartItem(
                    name:     widget.product.name,
                    category: widget.product.category,
                    price:    widget.product.price,
                  ),
                );
            // Brief confirmation snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.product.name} added to cart'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          label: const Text(
            'Add to Cart',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ),
      ),
    );
  }

  // ── _submitReview ──────────────────────────────────────────────────────────
  // Validates the form inputs, then adds the new review to the list.
  // In production: POST the review to your API before updating local state.
  Future<void> _submitReview() async {
    // ── Validation ──────────────────────────────────────────────────────────
    if (_selectedRating == 0) {
      // User hasn't tapped a star yet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a comment before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ── Submit ───────────────────────────────────────────────────────────────
    setState(() => _isSubmitting = true); // Show spinner on the button

    // Simulated API delay — replace with your actual API call:
    // await ReviewService.postReview(productId, rating, comment);
    await Future.delayed(const Duration(seconds: 1));

    // Build the new Review object from the current form state
    final newReview = Review(
      author: 'You',               // Replace with the logged-in user's name
      rating: _selectedRating,
      comment: comment,
      // Format today's date as "Mon YYYY" for the display string
      date: _formatDate(DateTime.now()),
    );

    setState(() {
      _reviews.insert(0, newReview); // Prepend so the newest review appears first
      _selectedRating = 0;           // Reset star picker
      _commentController.clear();    // Clear the text field
      _isSubmitting = false;         // Hide spinner
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review submitted — thank you!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── _formatDate ────────────────────────────────────────────────────────────
  // Converts a DateTime to a short display string like "Mar 2025".
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}