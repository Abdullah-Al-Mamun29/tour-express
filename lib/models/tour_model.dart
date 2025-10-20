// lib/models/tour_model.dart

class Tour {
  final String id;
  final String title;
  final String location;
  final double price;
  final String duration;
  final List<String> imageUrls;
  final String shortDesc;
  final int capacity;

  Tour({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.duration,
    required this.imageUrls,
    required this.shortDesc,
    required this.capacity,
  });
}