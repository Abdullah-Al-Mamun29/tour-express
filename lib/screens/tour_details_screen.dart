import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
// Flutter Map Imports
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/tour_model.dart';
import '../models/weather_model.dart';
import '../models/weather_daily_model.dart';
import '../api/fetch_weather.dart';
import '../providers/cart_provider.dart';

class TourDetailsScreen extends StatefulWidget {
  final Tour tour;

  const TourDetailsScreen({super.key, required this.tour});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  late Future<Weather> _currentWeather;
  late Future<List<DailyWeather>> _forecast;

  // MapController for flutter_map
  final MapController mapController = MapController();

  // LatLng for location data
  LatLng? _userLocation;

  // Flag to know if the map is initialized and ready to be moved
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();

    // Weather API initialization
    _currentWeather = WeatherService.getCurrentWeather(
        widget.tour.latitude, widget.tour.longitude);
    _forecast = WeatherService.get7DayForecast(
        widget.tour.latitude, widget.tour.longitude);

    _getUserLocation();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage =
            (_pageController.page!.round() + 1) % widget.tour.imageUrls.length;

        if (mounted) {
          setState(() {
            _currentPage = nextPage;
          });
        }

        _pageController
            .animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        )
            .catchError((e) {
          if (mounted) {
            _pageController.jumpToPage(_currentPage);
          }
        });
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _getUserLocation() async {
    // Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update UI with new location
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);

      // FIX: Only try to move the map if the map widget has confirmed it is ready.
      if (_isMapReady) {
        mapController.move(_userLocation!, 12);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Widget to display the Open-Source Map (FlutterMap)
  Widget _buildFlutterMap() {
    // LatLng for the Tour location
    final tourLocation = LatLng(widget.tour.latitude, widget.tour.longitude);

    // Initial center point prioritizes user location if available
    final initialCenter = _userLocation ?? tourLocation;

    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 12,
            // NEW: Use onMapReady callback to set the flag and move the map
            onMapReady: () {
              // This is called when the map widget is fully built and ready to accept commands.
              _isMapReady = true;
              if (_userLocation != null) {
                mapController.move(_userLocation!, 12);
              }
            }),
        children: [
          // 1. Map Tiles (using free OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tour_express',
          ),

          // 2. Markers Layer
          MarkerLayer(
            markers: [
              // Tour Location Marker
              Marker(
                point: tourLocation,
                width: 80,
                height: 80,
                builder: (context) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
                rotate: true,
              ),

              // User Location Marker (if available)
              if (_userLocation != null)
                Marker(
                  point: _userLocation!,
                  width: 80,
                  height: 80,
                  builder: (context) => const Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40,
                  ),
                  rotate: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.tour.title,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is UserScrollNotification) {
                        if (notification.direction != ScrollDirection.idle) {
                          _autoScrollTimer?.cancel();
                        } else {
                          _startAutoScroll();
                        }
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.tour.imageUrls.length,
                      onPageChanged: _onPageChanged,
                      builder: (context, index) {
                        return Image.asset(
                          widget.tour.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.tour.imageUrls.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 22 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoChip(
                        icon: Icons.location_on,
                        text: widget.tour.location,
                      ),
                      InfoChip(icon: Icons.timer, text: widget.tour.duration),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About the trip',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.tour.shortDesc,
                    style: textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Price',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'BDT ${widget.tour.price.toStringAsFixed(2)} / person',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== Current Weather =====
                  FutureBuilder<Weather>(
                    future: _currentWeather,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final weather = snapshot.data!;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Image.network(
                                'http://openweathermap.org/img/wn/${weather.icon}@2x.png'),
                            title: Text(
                                '${weather.temp}°C - ${weather.description}'),
                            subtitle: Text(
                                'Humidity: ${weather.humidity}% | Wind: ${weather.windSpeed} m/s'),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text('Error loading weather');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // ===== 7 Day Forecast =====
                  SizedBox(
                    height: 120,
                    child: FutureBuilder<List<DailyWeather>>(
                      future: _forecast,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final forecast = snapshot.data!;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: forecast.length,
                            builder: (context, index) {
                              final day = forecast[index];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(day.day),
                                      Image.network(
                                        'http://openweathermap.org/img/wn/${day.icon}@2x.png',
                                        width: 50,
                                      ),
                                      Text(
                                          '${day.tempDay.toStringAsFixed(0)}° / ${day.tempNight.toStringAsFixed(0)}°'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== Open-Source Map (FlutterMap) =====
                  Text(
                    'Map Location',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFlutterMap(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            cart.addToCart(widget.tour);
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
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

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
