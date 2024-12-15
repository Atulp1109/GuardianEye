import 'status.dart';

class Case {
  final String id;
  final String name;
  final String age;
  final String phoneNumber;
  final String address;
  final Status status;
  final String imageUrl; // Add imageUrl property

  Case({
    required this.id,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.address,
    required this.status,
    required this.imageUrl, // Initialize imageUrl
  });

  // Convert Case object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'phone': phoneNumber,
      'address': address,
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl, // Include imageUrl in the map
    };
  }
}
