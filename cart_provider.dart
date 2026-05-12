import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item.dart';

class CartItem {
  final FoodItem foodItem;
  final int quantity;

  CartItem({required this.foodItem, this.quantity = 1});

  CartItem copyWith({int? quantity}) {
    return CartItem(foodItem: foodItem, quantity: quantity ?? this.quantity);
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(FoodItem item) {
    final index = state.indexWhere((e) => e.foodItem.id == item.id);
    if (index >= 0) {
      state = [
        for (final e in state)
          if (e.foodItem.id == item.id)
            e.copyWith(quantity: e.quantity + 1)
          else
            e
      ];
    } else {
      state = [...state, CartItem(foodItem: item)];
    }
  }

  void removeItem(String itemId) {
    final index = state.indexWhere((e) => e.foodItem.id == itemId);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity > 1) {
        state = [
          for (final e in state)
            if (e.foodItem.id == itemId)
              e.copyWith(quantity: e.quantity - 1)
            else
              e
        ];
      } else {
        state = state.where((e) => e.foodItem.id != itemId).toList();
      }
    }
  }

  void clearCart() => state = [];

  double get totalPrice =>
      state.fold(0, (sum, e) => sum + e.foodItem.price * e.quantity);

  int get totalItems =>
      state.fold(0, (sum, e) => sum + e.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);
