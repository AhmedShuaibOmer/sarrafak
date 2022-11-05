import 'package:equatable/equatable.dart';

class ATM extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? website;
  final double lat;
  final double long;

  ATM({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.website,
    required this.lat,
    required this.long,
  });

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
