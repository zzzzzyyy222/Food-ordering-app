// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_item.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import 'food_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _crossAxisCount = 2;
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final List<String> _categories = [
    'All', 'Burgers', 'Pizza', 'Chicken', 'Salads', 'Sushi', 'Desserts', 'Drinks'
  ];

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Get 30% OFF',
      'subtitle': 'On your first order!',
      'tag': 'Special Offer 🎉',
      'colors': [Color(0xFFFF6B35), Color(0xFFFF8C42)],
      'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200',
    },
    {
      'title': 'Free Delivery',
      'subtitle': 'On orders above \$20!',
      'tag': 'Limited Time 🚀',
      'colors': [Color(0xFF6B35FF), Color(0xFF8C42FF)],
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200',
    },
    {
      'title': 'Buy 2 Get 1',
      'subtitle': 'On all burgers today!',
      'tag': 'Hot Deal 🔥',
      'colors': [Color(0xFF35AAFF), Color(0xFF42C8FF)],
      'image': 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_bannerController.hasClients) {
        final next = (_currentBanner + 1) % _banners.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  List<FoodItem> get _filteredFoods {
    return sampleFoods.where((food) {
      final matchesSearch = food.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || food.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showGridOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Display Options',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _gridOption(1, Icons.view_agenda_outlined, 'List'),
                _gridOption(2, Icons.grid_view, '2 Row'),
                _gridOption(3, Icons.view_module, '3 Row'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _gridOption(int count, IconData icon, String label) {
    final isSelected = _crossAxisCount == count;
    return GestureDetector(
      onTap: () {
        setState(() => _crossAxisCount = count);
        Navigator.pop(context);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalItems = ref.read(cartProvider.notifier).totalItems;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [

              // ── Header ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good day! 👋',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500)),
                          const Text('Order Your Favourite',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const Text('Meals Anytime 🍔',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          // Grid toggle
                          GestureDetector(
                            onTap: _showGridOptions,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 8)
                                ],
                              ),
                              child: const Icon(Icons.grid_view,
                                  size: 22),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Cart
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CartScreen())),
                                child: Container(
                                  padding:
                                      const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Colors.grey.shade200,
                                          blurRadius: 8)
                                    ],
                                  ),
                                  child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 22),
                                ),
                              ),
                              if (cartItems.isNotEmpty)
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.orange,
                                    child: Text('$totalItems',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // Logout
                          GestureDetector(
                            onTap: () async {
                              await AuthService().logout();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, '/');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 8)
                                ],
                              ),
                              child: const Icon(Icons.logout,
                                  size: 22),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Bar ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Search food...',
                        hintStyle:
                            TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.orange),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Sliding Banners ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: PageView.builder(
                          controller: _bannerController,
                          onPageChanged: (index) => setState(
                              () => _currentBanner = index),
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            final banner = _banners[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: List<Color>.from(
                                      banner['colors']),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      child: Image.network(
                                        banner['image'],
                                        height: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) =>
                                                const SizedBox(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: Text(
                                              banner['tag'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(banner['title'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        Text(banner['subtitle'],
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Dots indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _banners.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            width: _currentBanner == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentBanner == index
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Categories ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Categories',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected =
                                _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(
                                    () => _selectedCategory = cat);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 6)
                                  ],
                                ),
                                child: Text(cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Foods Header ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == 'All'
                            ? 'All Foods'
                            : _selectedCategory,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text('${_filteredFoods.length} items',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showGridOptions,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.tune,
                                  size: 16,
                                  color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Food Grid ─────────────────────────────────────
              _filteredFoods.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Column(
                            children: [
                              const Text('😔',
                                  style: TextStyle(fontSize: 50)),
                              const SizedBox(height: 12),
                              Text('No food found',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: _crossAxisCount == 1
                              ? 3.5
                              : _crossAxisCount == 2
                                  ? 0.72
                                  : 0.65,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => FoodCard(
                            food: _filteredFoods[index],
                            crossAxisCount: _crossAxisCount,
                          ),
                          childCount: _filteredFoods.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Food Card ────────────────────────────────────────────────────
class FoodCard extends ConsumerWidget {
  final FoodItem food;
  final int crossAxisCount;
  const FoodCard(
      {super.key, required this.food, required this.crossAxisCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // List view
    if (crossAxisCount == 1) {
      return GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FoodDetailScreen(food: food))),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  spreadRadius: 1)
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
                child: Image.network(
                  food.imageUrl,
                  width: 100,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.fastfood,
                        color: Colors.orange),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(food.category,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700)),
                      ),
                      const SizedBox(height: 4),
                      Text(food.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(food.description,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                            5,
                            (i) => Icon(Icons.star,
                                size: 12,
                                color: i < 4
                                    ? Colors.amber
                                    : Colors.grey.shade300)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$${food.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 15)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .addItem(food);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${food.name} added! 🛒'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Grid view
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => FoodDetailScreen(food: food))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                spreadRadius: 1)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: Image.network(
                food.imageUrl,
                height: crossAxisCount == 2 ? 110 : 80,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: crossAxisCount == 2 ? 110 : 80,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.orange, strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: crossAxisCount == 2 ? 110 : 80,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.fastfood,
                      color: Colors.orange, size: 30),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.all(crossAxisCount == 2 ? 10 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(food.category,
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.orange.shade700)),
                  ),
                  const SizedBox(height: 4),
                  Text(food.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: crossAxisCount == 2 ? 13 : 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: List.generate(
                        5,
                        (i) => Icon(Icons.star,
                            size: crossAxisCount == 2 ? 11 : 9,
                            color: i < 4
                                ? Colors.amber
                                : Colors.grey.shade300)),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${food.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize:
                                  crossAxisCount == 2 ? 13 : 11)),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(cartProvider.notifier)
                              .addItem(food);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content:
                                  Text('${food.name} added! 🛒'),
                              duration:
                                  const Duration(seconds: 1),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                              crossAxisCount == 2 ? 5 : 3),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.add,
                              color: Colors.white,
                              size: crossAxisCount == 2 ? 15 : 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}