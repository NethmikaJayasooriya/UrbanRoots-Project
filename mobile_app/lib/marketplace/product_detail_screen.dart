import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';
import 'marketplace_screen.dart';
import 'marketplace_theme.dart';
import 'marketplace_api.dart';


class Review {
  final String author;
  final int rating;
  final String comment;
  final String date;

  const Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  List<Review> _reviews = [];
  bool _isLoadingReviews = true;


  final _commentController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviewData = await MarketplaceApi.fetchReviews(widget.product.name);
      if (!mounted) return;
      setState(() {
        _reviews = (reviewData as List).map((r) => Review(
          author: r['originalName'] ?? 'User',
          rating: r['rating'] ?? 5,
          comment: r['comment'] ?? '',
          date: 'Recently',
        )).toList();
        _reviews = _reviews.reversed.toList();
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReviews = false;
      });
      print('Error loading reviews: $e');
    }
  }


  @override
  void dispose() {
    _animController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    return _reviews.fold(0, (sum, r) => sum + r.rating) / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: MarketplaceTheme.background.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: MarketplaceTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: MarketplaceTheme.textWhite, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeroImage(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: MarketplaceTheme.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: MarketplaceTheme.primaryGreen.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ]
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(),
                        const SizedBox(height: 24),
                        _buildProductSummary(),
                        const SizedBox(height: 32),
                        _buildReviewForm(),
                        const SizedBox(height: 24),
                        _buildReviewsSection(),
                        const SizedBox(height: 80), // Fab spacing
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddToCartButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            MarketplaceTheme.primaryGreen.withOpacity(0.25),
            MarketplaceTheme.background,
          ],
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [MarketplaceTheme.lightGreen, MarketplaceTheme.primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(widget.product.placeholderIcon, size: 140, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: MarketplaceTheme.primaryGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Text(
          widget.product.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite, letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MarketplaceTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MarketplaceTheme.primaryGreen.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: MarketplaceTheme.primaryGreen.withOpacity(0.2), blurRadius: 8)
                ]
              ),
              child: Text(
                widget.product.category,
                style: const TextStyle(fontSize: 12, color: MarketplaceTheme.lightGreen, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              _reviews.isEmpty ? 'No ratings yet' : '${_averageRating.toStringAsFixed(1)} (${_reviews.length} reviews)',
              style: const TextStyle(fontSize: 14, color: MarketplaceTheme.textGray),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Rs. ${widget.product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: MarketplaceTheme.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildProductSummary() {
    final defaultDesc = 'Premium eco-friendly product from UrbanRoots. Ideal for modern sustainable homes and gardens.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About this product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
        const SizedBox(height: 12),
        Text(
          widget.product.description ?? defaultDesc,
          style: const TextStyle(fontSize: 15, color: MarketplaceTheme.textGray, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: MarketplaceTheme.primaryGreen, borderRadius: BorderRadius.circular(12)),
              child: Text('${_reviews.length}', style: const TextStyle(color: MarketplaceTheme.darkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingReviews)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: MarketplaceTheme.primaryGreen)))
        else if (_reviews.isEmpty)

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 54, color: MarketplaceTheme.primaryGreen.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No reviews yet — be the first!', style: TextStyle(color: MarketplaceTheme.primaryGreen.withOpacity(0.6), fontSize: 15)),
                ],
              ),
            ),
          )
        else
          ..._reviews.map((r) => _buildReviewCard(r)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: MarketplaceTheme.glassBox(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: MarketplaceTheme.primaryGreen.withOpacity(0.2),
                child: Text(review.author[0], style: const TextStyle(color: MarketplaceTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MarketplaceTheme.textWhite)),
                    Text(review.date, style: const TextStyle(color: MarketplaceTheme.textGray, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 14, color: MarketplaceTheme.textGray, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MarketplaceTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MarketplaceTheme.primaryGreen.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: MarketplaceTheme.primaryGreen.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Leave a Review', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
          const SizedBox(height: 16),
          const Text('Your Rating', style: TextStyle(fontSize: 13, color: MarketplaceTheme.textGray)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(i < _selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: const TextStyle(color: MarketplaceTheme.textWhite),
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: const TextStyle(color: MarketplaceTheme.textGray),
              filled: true,
              fillColor: MarketplaceTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MarketplaceTheme.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MarketplaceTheme.primaryGreen.withOpacity(0.2),
                foregroundColor: MarketplaceTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.5))),
              ),
              onPressed: _isSubmitting ? null : _submitReview,
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: MarketplaceTheme.primaryGreen, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Review', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: MarketplaceTheme.primaryGreen.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: FloatingActionButton.extended(
            backgroundColor: MarketplaceTheme.primaryGreen,
            elevation: 0,
            onPressed: () {
              context.read<CartModel>().addItem(CartItem(name: widget.product.name, category: widget.product.category, price: widget.product.price));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.product.name} added to cart', style: const TextStyle(color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.bold)),
                  backgroundColor: MarketplaceTheme.lightGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            label: const Text('Add to Cart', style: TextStyle(color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
            icon: const Icon(Icons.shopping_cart_rounded, color: MarketplaceTheme.darkGreen),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please provide a rating and a comment.'), backgroundColor: Colors.orange.shade800, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    
    try {
      final reviewData = {
        'rating': _selectedRating,
        'comment': _commentController.text.trim()
      };
      await MarketplaceApi.submitReview(widget.product.name, reviewData);
      
      final newReview = Review(
        author: 'You',
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        date: 'Right now',
      );
      
      if (!mounted) return;
      setState(() {
        _reviews.insert(0, newReview); // inject instantly for responsive UI
        _selectedRating = 0;
        _commentController.clear();
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Review submitted!', style: TextStyle(color: MarketplaceTheme.darkGreen, fontWeight: FontWeight.bold)), backgroundColor: MarketplaceTheme.lightGreen, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

}