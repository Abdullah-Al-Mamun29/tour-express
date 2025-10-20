// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_drawer.dart';
import 'tour_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- CORRECTED Tour Data with matching image paths from your assets folder ---
  final List<Tour> _allTours = [
    Tour(
      id: 't1',
      title: 'Sundarbans ',
      location: 'Khulna, Bangladesh',
      price: 10000.00,
      duration: '3 Days',
      imageUrls: [
        // Using 'sundarban1.jpg' as the primary image
        'assets/images/sundarban1.jpg',
        'assets/images/sundarban5.jpg',
        'assets/images/sundarban3.jpg',
        'assets/images/sundarban4.jpg',
        'assets/images/sundarban2.jpg',
      ],
      shortDesc:
          'Explore the largest mangrove forest, home to the Royal Bengal Tiger. A journey into the wild heart of Bangladesh.',
      capacity: 15,
    ),
    Tour(
      id: 't2',
      title: "Cox's Bazar Sea Beach",
      location: 'Cox’s Bazar, Bangladesh',
      price: 12000.00,
      duration: '3 Days',
      imageUrls: [
        // Using 'cox3.jpg' as the primary image, as seen in the screenshot
        'assets/images/cox3.jpg',
        'assets/images/cox4.jpg',
        'assets/images/cox2.jpg',
        'assets/images/cox1.jpg',
        'assets/images/cox5.jpg',
      ],
      shortDesc:
          'Relax on the world\'s longest natural sea beach. Enjoy the sunset and vibrant local culture.',
      capacity: 10,
    ),
    Tour(
      id: 't3',
      title: "Saint Martin's Island ",
      location: 'Saint Martin, Bangladesh',
      price: 12500.00,
      duration: '4 Days',
      imageUrls: [
        // Using 'stmartin1.jpg' as the primary image (assuming 'stmartin.jpg' is a typo in your path)
        'assets/images/stmartin1.jpg',
        'assets/images/stmartin.jpg',
        'assets/images/stmartin2.jpg',
        'assets/images/stmartin4.jpg',
        'assets/images/stmartin3.jpg',
      ],
      shortDesc:
          'The only coral island in Bangladesh. Crystal clear water and pure tranquility await you.',
      capacity: 20,
    ),
    Tour(
      id: 't4',
      title: 'Sajek Valley',
      location: 'Rangamati, Bangladesh',
      price: 8500.00,
      duration: '3 Days',
      imageUrls: [
        // Using 'sajek.jpg' or 'sajek1.jpg' as the primary image
        'assets/images/sajek.jpg',
        'assets/images/sajek4.jpg',
        'assets/images/sajek3.jpg',
        'assets/images/sajek1.jpg',
        'assets/images/sajek2.jpg',
      ],
      shortDesc:
          'Witness the clouds rolling beneath your feet in the scenic hills of Sajek, a breathtaking escape in the Chittagong Hill Tracts.',
      capacity: 20,
    ),
    Tour(
      id: 't5',
      title: 'Kuakata Sea Beach',
      location: 'Patuakhali, Bangladesh',
      price: 7000.00,
      duration: '3 Days',
      imageUrls: [
        'assets/images/kuakata1.jpg',
        'assets/images/kuakata2.jpg',
        'assets/images/kuakata3.jpg',
        'assets/images/kuakata4.jpg',
        'assets/images/kuakata5.jpg',
      ],
      shortDesc:
          'The only place in Bangladesh where you can view both the sunrise and sunset over the Bay of Bengal from the same beach.',
      capacity: 30,
    ),
    Tour(
      id: 't6',
      title: 'Kaptai Lake',
      location: 'Rangamati, Bangladesh',
      price: 9500.00,
      duration: '2 Days',
      imageUrls: [
        'assets/images/kaptai1.jpg',
        'assets/images/kaptai2.jpg',
        'assets/images/kaptai3.jpg',
        'assets/images/kaptai4.jpg',
        'assets/images/kaptai5.jpg',
      ],
      shortDesc:
          'Cruise the largest man-made lake in Southeast Asia, surrounded by lush green hills and indigenous settlements.',
      capacity: 18,
    ),
    Tour(
      id: 't7',
      title: 'Nilgiri Mountains',
      location: 'Bandarban, Bangladesh',
      price: 12000.00,
      duration: '3 Days',
      imageUrls: [
        'assets/images/nilgiri1.jpg',
        'assets/images/nilgiri2.jpg',
        'assets/images/nilgiri3.jpg',
        'assets/images/nilgiri4.jpg',
        'assets/images/nilgiri5.jpg',
      ],
      shortDesc:
          'Stay above the clouds at Nilgiri, one of the highest and most popular peaks in the Bandarban region for stunning panoramic views.',
      capacity: 12,
    ),
    Tour(
      id: 't8',
      title: 'Tanguar Haor',
      location: 'Sunamganj, Bangladesh',
      price: 6500.00,
      duration: '2 Days',
      imageUrls: [
        'assets/images/tanguar1.jpg',
        'assets/images/tanguar2.jpg',
        'assets/images/tanguar3.jpg',
        'assets/images/tanguar4.jpg',
        'assets/images/tanguar5.jpg',
      ],
      shortDesc:
          'Explore a vast wetland ecosystem, a Ramsar site famous for its migratory birds and unique floating lifestyle.',
      capacity: 10,
    ),
    Tour(
      id: 't9',
      title: 'Sreemangal Tea Gardens',
      location: 'Moulvibazar, Bangladesh',
      price: 8000.00,
      duration: '2 Days',
      imageUrls: [
        'assets/images/sreemangal1.jpg',
        'assets/images/sreemangal2.jpg',
        'assets/images/sreemangal3.jpg',
        'assets/images/sreemangal4.jpg',
        'assets/images/sreemangal5.jpg',
      ],
      shortDesc:
          'The \'Tea Capital\' of Bangladesh. Wander through endless green tea plantations and experience the famous seven-layer tea.',
      capacity: 25,
    ),
    Tour(
      id: 't10',
      title: 'Panam Nagar',
      location: 'Sonargaon,Bangladesh',
      price: 4500.00,
      duration: '1 Day',
      imageUrls: [
        'assets/images/panam4.jpg',
        'assets/images/panam2.jpg',
        'assets/images/panam3.jpg',
        'assets/images/panam1.jpg',
        'assets/images/panam5.jpg',
      ],
      shortDesc:
          'Step back in time at this preserved city of ancient merchants, a ghost town showcasing rich historical architecture.',
      capacity: 20,
    ),
    Tour(
      id: 't11',
      title: 'Jaflong',
      location: 'Sylhet, Bangladesh',
      price: 7500.00,
      duration: '2 Days',
      imageUrls: [
        'assets/images/jaflong1.jpg',
        'assets/images/jaflong2.jpg',
        'assets/images/jaflong3.jpg',
        'assets/images/jaflong4.jpg',
        'assets/images/jaflong5.jpg',
      ],
      shortDesc:
          'Discover the scenic borderlands of Jaflong, famous for its stone collection from the river, and stunning views of the Meghalaya mountains.',
      capacity: 16,
    ),
  ];

  List<Tour> _filteredTours = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTours = _allTours;
    _searchController.addListener(_filterTours);
  }

  void _filterTours() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTours =
          _allTours.where((tour) {
            final titleMatches = tour.title.toLowerCase().contains(query);
            final locationMatches = tour.location.toLowerCase().contains(query);
            return titleMatches || locationMatches;
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tour BD'), centerTitle: true),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _filteredTours.length,
              itemBuilder: (ctx, index) {
                final tour = _filteredTours[index];
                return TourCard(tour: tour);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Redesigned Tour Card Widget ---
class TourCard extends StatelessWidget {
  const TourCard({super.key, required this.tour});

  final Tour tour;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TourDetailsScreen(tour: tour),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.asset(
              tour.imageUrls.first,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'BDT ${tour.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tour.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.location,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  cart.addToCart(tour);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tour.title} added to cart!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
