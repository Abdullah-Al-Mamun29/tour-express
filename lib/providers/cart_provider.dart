import 'package:flutter/material.dart';
import '../models/tour_model.dart';

class CartProvider with ChangeNotifier {
  final List<Tour> _cartItems = [];

  List<Tour> get cartItems => _cartItems;

  // Adds a tour to the cart.
  void addToCart(Tour tour) {
    if (!_cartItems.any((item) => item.id == tour.id)) {
      _cartItems.add(tour);
      notifyListeners();
    }
  }

  // Removes a tour from the cart.
  void removeFromCart(Tour tour) {
    _cartItems.removeWhere((item) => item.id == tour.id);
    notifyListeners();
  }

  // Clears all items from the cart.
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double getCartTotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + item.price);
  }
}
