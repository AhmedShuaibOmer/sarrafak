import 'package:equatable/equatable.dart';

class ATM extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? website;
  final double latitude;
  final double longitude;
  final int rating;

  const ATM({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.website,
    this.rating = 0,
    required this.latitude,
    required this.longitude,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        longitude,
        latitude,
      ];
}
