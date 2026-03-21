import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'marketplace_theme.dart';
import 'marketplace_api.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneSingle = prefs.getString('user_phone');
      List<String> userPhones = prefs.getStringList('user_phones') ?? [];
      
      // Migrate old single phone tracking
      if (phoneSingle != null && phoneSingle.isNotEmpty && !userPhones.contains(phoneSingle)) {
        userPhones.add(phoneSingle);
        await prefs.setStringList('user_phones', userPhones);
      }

      if (userPhones.isNotEmpty) {
        List<dynamic> allOrders = [];
        for (String p in userPhones) {
          try {
            final data = await MarketplaceApi.fetchOrders(p);
            allOrders.addAll(data);
          } catch(e) {
            print('Error fetching orders for $p: $e');
          }
        }
        
        // Sort explicitly by createdAt DESC since we merged separate phone queries
        allOrders.sort((a, b) {
          final d1 = a['createdAt'] != null ? DateTime.parse(a['createdAt']) : DateTime.now();
          final d2 = b['createdAt'] != null ? DateTime.parse(b['createdAt']) : DateTime.now();
          return d2.compareTo(d1);
        });

        if (!mounted) return;
        setState(() {
          _orders = allOrders;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching generalized orders: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarketplaceTheme.background,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
        backgroundColor: MarketplaceTheme.cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: MarketplaceTheme.primaryGreen),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MarketplaceTheme.primaryGreen))
          : _orders.isEmpty
              ? _buildEmptyState('No Orders Found', 'You have not successfully placed any orders yet from this device.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_orders[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(shape: BoxShape.circle, color: MarketplaceTheme.cardColor.withOpacity(0.5)),
              child: const Icon(Icons.history_rounded, size: 80, color: MarketplaceTheme.textGray),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
            const SizedBox(height: 12),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: MarketplaceTheme.textGray, fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final status = order['status'] ?? 'PENDING';
    final isPaid = status == 'PAID';
    final date = order['createdAt'] != null ? DateTime.parse(order['createdAt']) : DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
    final items = order['items'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: MarketplaceTheme.glassBox(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID & Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPaid ? MarketplaceTheme.primaryGreen.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: MarketplaceTheme.primaryGreen.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['orderId'] ?? 'Order', style: const TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite)),
                    const SizedBox(height: 4),
                    Text(formattedDate, style: const TextStyle(color: MarketplaceTheme.textGray, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? MarketplaceTheme.primaryGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isPaid ? MarketplaceTheme.primaryGreen : Colors.orange),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isPaid ? MarketplaceTheme.lightGreen : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
          // Items List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['quantity']}x ${item['name']}', style: const TextStyle(color: MarketplaceTheme.textWhite)),
                          Text('Rs. ${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(0)}', style: const TextStyle(color: MarketplaceTheme.textGray)),
                        ],
                      ),
                    )),
                const Divider(color: Colors.white12, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.textWhite, fontSize: 16)),
                    Text(
                      'Rs. ${(order['totalAmount'] as num).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: MarketplaceTheme.primaryGreen, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
