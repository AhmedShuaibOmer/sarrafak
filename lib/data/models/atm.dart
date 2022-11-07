import 'package:equatable/equatable.dart';

class ATM extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? website;
  final double latitude;
  final double longitude;

  ATM({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.website,
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
