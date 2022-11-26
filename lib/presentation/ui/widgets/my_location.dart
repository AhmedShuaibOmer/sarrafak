import 'package:flutter/material.dart';
import 'package:location/location.dart';

class MyLocationButton extends StatefulWidget {
  final Function(bool isLocationEnabled, LocationData? locationData)? onResult;
  const MyLocationButton({
    Key? key,
    this.onResult,
  }) : super(key: key);

  @override
  State<MyLocationButton> createState() => _MyLocationButtonState();
}

class _MyLocationButtonState extends State<MyLocationButton>
    with TickerProviderStateMixin {
  bool _isLoadingLocation = false;
  bool _isLocationExists = false;

  late AnimationController _controller;
  final Tween<double> turnsTween = Tween<double>(
    begin: 0,
    end: 1,
  );

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.repeat();
//
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "btn2",
      onPressed: _getUserLocation,
      child: _isLoadingLocation
          ? RotationTransition(
              turns: turnsTween.animate(_controller),
              child: const Icon(Icons.location_searching),
            )
          : !_isLocationExists
              ? const Icon(Icons.location_disabled)
              : const Icon(Icons.my_location_outlined),
    );
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _isLocationExists = false;
          widget.onResult!(false, null);
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isLoadingLocation = false;
          _isLocationExists = false;
          widget.onResult!(false, null);
        });
        return;
      }
    }

    location.getLocation().then((value) {
      setState(() {
        widget.onResult!(true, value);
        _isLoadingLocation = false;
        _isLocationExists = true;
      });
    });
  }
}
