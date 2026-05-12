// lib/models/order.dart

enum OrderStatus { pending, confirmed, preparing, onTheWay, delivered }

class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}

// Sample order to test with
final sampleOrder = Order(
  id: 'ORD-001',
  items: [
    {'name': 'Cheese Burger', 'quantity': 2, 'price': 12.99},
    {'name': 'Pepperoni Pizza', 'quantity': 1, 'price': 15.99},
  ],
  totalAmount: 41.97,
  status: OrderStatus.preparing,
  createdAt: DateTime.now(),
);