// lib/screens/tour_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_model.dart';
import '../providers/cart_provider.dart';

class TourDetailsScreen extends StatelessWidget {
  final Tour tour;

  const TourDetailsScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tour.title,
                style: const TextStyle(shadows: [
                  Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(1, 1))
                ]),
              ),
              background: PageView.builder(
                itemCount: tour.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    tour.imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Duration Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoChip(icon: Icons.location_on, text: tour.location),
                      InfoChip(icon: Icons.timer, text: tour.duration),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text('About the trip', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(tour.shortDesc, style: textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 24),
                  
                  // Price
                  Text('Price', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'BDT ${tour.price.toStringAsFixed(2)} / person',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            cart.addToCart(tour);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tour added to your cart!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Add to Cart'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for info chips
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    );
  }
}
