import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/order.dart';
import '../orders/order_tracking_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Map<String, dynamic>? _appliedVoucher;
  bool _isCheckingOut = false;

  static const double _deliveryFee = 2.00;

  double get _discountRate {
    final discount = _appliedVoucher?['discount'];
    if (discount == null) return 0;

    final match = RegExp(r'(\d+)').firstMatch(discount.toString());
    final percent = double.tryParse(match?.group(1) ?? '') ?? 0;
    return percent / 100;
  }

  double _discountAmount(double subtotal) => subtotal * _discountRate;

  double _total(double subtotal) =>
      max(0, subtotal - _discountAmount(subtotal)) + _deliveryFee;

  Future<void> _chooseVoucher() async {
    final userData = await FirestoreService().getUserData().first;
    if (!mounted) return;

    final vouchers =
        List<Map<String, dynamic>>.from(userData['vouchers'] ?? []);

    if (vouchers.isEmpty) {
      _showSnackBar('You do not have any vouchers yet.', Colors.orange);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Voucher',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...vouchers.map((voucher) {
              final isSelected = _appliedVoucher?['code'] == voucher['code'];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _appliedVoucher = voucher);
                  _showSnackBar(
                    '${voucher['discount']} voucher applied!',
                    Colors.green,
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.orange
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.local_offer,
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${voucher['discount']} Voucher',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              voucher['code'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _removeVoucher() {
    setState(() => _appliedVoucher = null);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _checkout(List<CartItem> cartItems, CartNotifier cartNotifier) async {
    setState(() => _isCheckingOut = true);

    try {
      final items = cartItems
          .map((e) => {
                'name': e.foodItem.name,
                'quantity': e.quantity,
                'price': e.foodItem.price,
              })
          .toList();

      final subtotal = cartNotifier.totalPrice;
      final discountAmount = _discountAmount(subtotal);
      final total = _total(subtotal);
      final voucher = _appliedVoucher;

      if (voucher != null) {
        final wasUsed = await FirestoreService().useVoucher(voucher['code']);
        if (!wasUsed) {
          if (mounted) {
            _showSnackBar(
              'This voucher is no longer available.',
              Colors.red,
            );
            setState(() {
              _appliedVoucher = null;
              _isCheckingOut = false;
            });
          }
          return;
        }
      }

      final orderId = await FirestoreService().saveOrder(
        items,
        total,
        voucher: voucher,
        discountAmount: discountAmount,
      );

      cartNotifier.clearCart();

      if (mounted) {
        setState(() => _isCheckingOut = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(
              order: Order(
                id: orderId,
                items: items,
                totalAmount: total,
                status: OrderStatus.pending,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingOut = false);
        _showSnackBar('Error: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final subtotal = cartNotifier.totalPrice;
    final discountAmount = _discountAmount(subtotal);
    final total = _total(subtotal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                cartNotifier.clearCart();
                _removeVoucher();
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 70,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some delicious food!',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.foodItem.imageUrl,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 75,
                                    height: 75,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.fastfood,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.foodItem.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.foodItem.category,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${item.foodItem.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => cartNotifier.removeItem(
                                        item.foodItem.id,
                                      ),
                                      icon: const Icon(Icons.remove, size: 18),
                                      color: Colors.orange,
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => cartNotifier.addItem(
                                        item.foodItem,
                                      ),
                                      icon: const Icon(Icons.add, size: 18),
                                      color: Colors.orange,
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _chooseVoucher,
                          icon: const Icon(Icons.local_offer_outlined),
                          label: Text(
                            _appliedVoucher == null
                                ? 'Choose Voucher'
                                : '${_appliedVoucher!['discount']} applied',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (_appliedVoucher != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_appliedVoucher!['code']}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _removeVoucher,
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${cartNotifier.totalItems})',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Fee',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const Text(
                            '\$2.00',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (_appliedVoucher != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Voucher Discount',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              '-\$${discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCheckingOut
                              ? null
                              : () => _checkout(cartItems, cartNotifier),
                          icon: _isCheckingOut
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isCheckingOut ? 'Checking out...' : 'Checkout',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            disabledBackgroundColor: Colors.orange.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
