import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../orders/order_history_screen.dart';
import '../reviews/review_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showVoucherOptions(
      BuildContext context, int points) {
    final tiers = [
      {
        'tier': 'LITE',
        'cost': 50,
        'discount': '10% OFF',
        'color': Colors.blue,
        'icon': '🎫',
      },
      {
        'tier': 'PLUS',
        'cost': 70,
        'discount': '15% OFF',
        'color': Colors.green,
        'icon': '🎟️',
      },
      {
        'tier': 'MEGA',
        'cost': 100,
        'discount': '20% OFF',
        'color': Colors.orange,
        'icon': '🏷️',
      },
      {
        'tier': 'ULTRA',
        'cost': 150,
        'discount': '30% OFF',
        'color': Colors.purple,
        'icon': '💎',
      },
      {
        'tier': 'ELITE',
        'cost': 200,
        'discount': '50% OFF',
        'color': Colors.red,
        'icon': '👑',
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎁 Claim Voucher',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('You have $points points',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 16),
            ...tiers.map((t) {
              final cost = t['cost'] as int;
              final canClaim = points >= cost;
              return GestureDetector(
                onTap: canClaim
                    ? () async {
                        Navigator.pop(context);
                        final error =
                            await FirestoreService()
                                .claimVoucher(t['tier'] as String);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(error ??
                                  '🎉 ${t['discount']} Voucher claimed!'),
                              backgroundColor: error != null
                                  ? Colors.red
                                  : Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                          );
                        }
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: canClaim
                        ? (t['color'] as Color).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: canClaim
                          ? (t['color'] as Color).withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(t['icon'] as String,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${t['discount']} Voucher',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: canClaim
                                    ? t['color'] as Color
                                    : Colors.grey,
                              ),
                            ),
                            Text('${t['cost']} points',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: canClaim
                              ? t['color'] as Color
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          canClaim ? 'Claim' : 'Need more',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: FirestoreService().getUserData(),
        builder: (context, snapshot) {
          final points = snapshot.data?['points'] ?? 0;
          final vouchers = List<Map<String, dynamic>>.from(
              snapshot.data?['vouchers'] ?? []);
          final progress = (points % 50) / 50;

          return CustomScrollView(
            slivers: [

              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF6B35),
                        Color(0xFFFF8C42)
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                      20, 60, 20, 30),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Colors.white.withOpacity(0.3),
                        child: Text(
                          (user?.email ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.email ?? 'User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🏆 Reward Points',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text('$points pts',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight:
                                          FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor:
                                Colors.grey.shade200,
                            valueColor:
                                const AlwaysStoppedAnimation(
                                    Colors.orange),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          points >= 50
                              ? '🎉 You can claim a voucher!'
                              : '${50 - (points % 50)} more points to next voucher',
                          style: TextStyle(
                              color: points >= 50
                                  ? Colors.green
                                  : Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: points >= 50
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: points >= 50
                                ? () => _showVoucherOptions(
                                    context, points)
                                : null,
                            icon: const Icon(
                                Icons.card_giftcard,
                                color: Colors.white),
                            label: Text(
                              points >= 50
                                  ? 'Claim Voucher!'
                                  : 'Need ${50 - (points % 50)} more points',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: points >= 50
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Vouchers ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text('🎟️ My Vouchers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 12),
                        vouchers.isEmpty
                            ? Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 12),
                                  child: Text(
                                    'No vouchers yet. Earn 50 points to get one!',
                                    style: TextStyle(
                                        color:
                                            Colors.grey.shade400,
                                        fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Column(
                                children: vouchers.map((v) {
                                  final tier = v['tier'] ?? 'MEGA';
                                  final discount =
                                      v['discount'] ?? '20% OFF';
                                  final code = v['code'] ?? '';
                                  Color tileColor = Colors.orange;
                                  if (tier == 'LITE')
                                    tileColor = Colors.blue;
                                  if (tier == 'PLUS')
                                    tileColor = Colors.green;
                                  if (tier == 'ULTRA')
                                    tileColor = Colors.purple;
                                  if (tier == 'ELITE')
                                    tileColor = Colors.red;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10),
                                    padding:
                                        const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: tileColor
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(
                                              12),
                                      border: Border.all(
                                          color: tileColor
                                              .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              '$discount Voucher',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  color:
                                                      tileColor),
                                            ),
                                            Text(code,
                                                style: TextStyle(
                                                    color: tileColor
                                                        .withOpacity(
                                                            0.7),
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                        Icon(Icons.local_offer,
                                            color: tileColor),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuItem(
                          context,
                          icon: Icons.star_outline,
                          label: 'My Reviews',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ReviewHistoryScreen()),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _menuItem(
                          context,
                          icon: Icons.history,
                          label: 'Order History',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const OrderHistoryScreen()),
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _menuItem(
                          context,
                          icon: Icons.logout,
                          label: 'Logout',
                          color: Colors.red,
                          onTap: () async {
                            await FirebaseAuth.instance
                                .signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(
                                  context, '/');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w500)),
      trailing:
          const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
