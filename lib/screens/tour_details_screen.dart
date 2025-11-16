import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  GoogleMapController? mapController;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();

    // Weather API
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
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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
                      itemBuilder: (context, index) {
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
                            itemBuilder: (context, index) {
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
                  // ===== Google Map =====
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target:
                            LatLng(widget.tour.latitude, widget.tour.longitude),
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('tour'),
                          position: LatLng(
                              widget.tour.latitude, widget.tour.longitude),
                          infoWindow: InfoWindow(title: widget.tour.title),
                        ),
                        if (_userLocation != null)
                          Marker(
                            markerId: const MarkerId('user'),
                            position: _userLocation!,
                            infoWindow: const InfoWindow(title: 'You'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue),
                          ),
                      },
                      myLocationEnabled: true,
                      onMapCreated: (controller) => mapController = controller,
                    ),
                  ),
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
