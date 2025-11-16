import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Your Cart is Empty',
                      style: TextStyle(fontSize: 22, color: Colors.grey)),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final tour = cart.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(tour.imageUrls.first,
                              width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        title: Text(tour.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('BDT ${tour.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            cart.removeFromCart(tour);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total and Checkout Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('BDT ${cart.getCartTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const OrderConfirmationScreen()),
                          );
                          cart.clearCart();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Confirm Order',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
