// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // ── Voucher Tiers ────────────────────────────────────────────
  static const Map<String, int> voucherTiers = {
    'LITE':  50,
    'PLUS':  70,
    'MEGA':  100,
    'ULTRA': 150,
    'ELITE': 200,
  };

  static const Map<String, String> voucherDiscounts = {
    'LITE':  '10% OFF',
    'PLUS':  '15% OFF',
    'MEGA':  '20% OFF',
    'ULTRA': '30% OFF',
    'ELITE': '50% OFF',
  };

  // ── Orders ───────────────────────────────────────────────────
  Future<String> saveOrder(
    List<Map<String, dynamic>> items,
    double total, {
    Map<String, dynamic>? voucher,
    double discountAmount = 0,
  }) async {
    final orderId =
        'ORD-${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('orders').doc(orderId).set({
      'orderId': orderId,
      'userId': userId,
      'items': items,
      'totalAmount': total,
      'voucher': voucher,
      'discountAmount': discountAmount,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _addPoints(total.toInt());
    return orderId;
  }

  Stream<List<Map<String, dynamic>>> getOrderHistory() {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => doc.data()).toList());
  }

  // ── Reviews ──────────────────────────────────────────────────
  Future<void> saveReview(String foodId, String foodName,
      double rating, String comment) async {
    await _db.collection('reviews').add({
      'foodId': foodId,
      'foodName': foodName,
      'userId': userId,
      'userEmail':
          FirebaseAuth.instance.currentUser?.email,
      'rating': rating,
      'comment': comment,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getReviews(
      String foodId) {
    return _db
        .collection('reviews')
        .where('foodId', isEqualTo: foodId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => doc.data()).toList());
  }

  // ── Points & Vouchers ────────────────────────────────────────
  Future<void> _addPoints(int points) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      final currentPoints = doc.data()?['points'] ?? 0;
      await userRef
          .update({'points': currentPoints + points});
    } else {
      await userRef
          .set({'points': points, 'vouchers': []});
    }
  }

  Stream<Map<String, dynamic>> getUserData() {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) =>
            doc.data() ?? {'points': 0, 'vouchers': []});
  }

  Future<String?> claimVoucher(String tier) async {
    final cost = voucherTiers[tier] ?? 100;
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    final points = doc.data()?['points'] ?? 0;

    if (points < cost) {
      return 'You need $cost points to claim this voucher!';
    }

    final voucherCode =
        'BITE$tier${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final vouchers = List<Map<String, dynamic>>.from(
        doc.data()?['vouchers'] ?? []);
    vouchers.add({
      'code': voucherCode,
      'tier': tier,
      'discount': voucherDiscounts[tier],
    });

    await userRef.update({
      'points': points - cost,
      'vouchers': vouchers,
    });

    return null;
  }

  Future<bool> useVoucher(String code) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    final vouchers = List<Map<String, dynamic>>.from(
        doc.data()?['vouchers'] ?? []);

    final index =
        vouchers.indexWhere((v) => v['code'] == code);
    if (index >= 0) {
      vouchers.removeAt(index);
      await userRef.update({'vouchers': vouchers});
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> findVoucher(String code) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    final vouchers = List<Map<String, dynamic>>.from(
        doc.data()?['vouchers'] ?? []);

    final normalizedCode = code.trim().toUpperCase();
    final index = vouchers.indexWhere(
      (v) => '${v['code']}'.toUpperCase() == normalizedCode,
    );

    if (index < 0) return null;
    return vouchers[index];
  }
}
