import 'dart:typed_data';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/animation.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/mapview.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sarrafak/presentation/ui/screens/splash_screen.dart';

import '../../../app_constants.dart';
import '../../../data/models/atm.dart';
import '../../../helpers/page.dart';
import '../widgets/day_night_reveal.dart';
import '../widgets/my_location.dart';

class HereHomePage extends ExamplePage {
  const HereHomePage() : super(const Icon(Icons.home), 'Here Home');

  @override
  Widget build(BuildContext context) {
    return HereHome();
  }
}

class HereHome extends StatefulWidget {
  const HereHome({Key? key}) : super(key: key);

  @override
  State<HereHome> createState() => _HereHomeState();
}

class _HereHomeState extends State<HereHome> {
  MapboxMapController? _mapController;
  HereMapController? _hereMapController;

  bool _isEverythingIsReady = false;
  bool _isHereMapIsReady = false;
  bool _isMapboxMapIsReady = false;

  bool _isHereMapOn = true;

  bool _myLocationEnabled = false;

  bool _isSatellite = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: DayNightReveal(child: (isLight) {
        return Stack(children: [
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: MapboxMap(
              styleString: _isSatellite
                  ? MapboxStyles.SATELLITE
                  : isLight
                      ? AppConstants.mapBoxStyleId
                      : AppConstants.mapBoxDarkStyleId,
              accessToken: AppConstants.mapBoxAccessToken,
              onMapCreated: _onMapboxMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(AppConstants.kInitialLocation[0],
                    AppConstants.kInitialLocation[1]),
                zoom: 11.0,
              ),
              onStyleLoadedCallback: _onStyleLoadedCallback,
              trackCameraPosition: true,
              myLocationEnabled: _myLocationEnabled,
              myLocationTrackingMode: MyLocationTrackingMode.None,
            ),
          ),
          _isHereMapOn
              ? SizedBox(
                  height: screenHeight,
                  width: screenWidth,
                  child: HereMap(
                    onMapCreated: _onHereMapCreated,
                  ),
                )
              : Container(),
          PositionedDirectional(
            bottom: 20,
            end: 20,
            child: MyLocationButton(
              onResult: (isLocationEnabled, locationValue) {
                setState(() {
                  _myLocationEnabled = isLocationEnabled;
                  if (isLocationEnabled) {
                    _mapboxToMyLocation(locationValue!);
                    if (_isHereMapOn) {
                      _flyTo(GeoCoordinates(
                        locationValue.latitude!,
                        locationValue.longitude!,
                      ));
                    }
                  }
                });
              },
            ),
          ),
          _isEverythingIsReady ? Container() : const SplashScreen(),
        ]);
      }),
      floatingActionButton: _isEverythingIsReady
          ? FabCircularMenu(
              alignment: Alignment.bottomLeft,
              fabColor: Theme.of(context).primaryColor.withOpacity(0.5),
              fabOpenColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ringDiameter: 250.0,
              ringWidth: 60.0,
              ringColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              fabSize: 60.0,
              children: [
                  IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.navigation)),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSatellite = !_isSatellite;
                      });
                    },
                    icon: const Icon(Icons.layers),
                  ),
                ])
          : null,
    );
  }

  _onMapboxMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  _onStyleLoadedCallback() async {
    await addImageFromAsset(
        "sarrafakLogo", "assets/icons/sarrafak_432x432.png");
    await _addAll();
    setState(() {
      _isMapboxMapIsReady = true;
      _isEverythingIsReady = _isHereMapIsReady;
    });
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return _mapController!.addImage(name, list);
  }

  void _onHereMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.satellite,
        (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      const double distanceToEarthInMeters = 100000000;
      MapMeasure mapMeasureZoom =
          MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
      hereMapController.camera
          .lookAtPointWithMeasure(GeoCoordinates(0, 0), mapMeasureZoom);
      setState(() {
        _isHereMapIsReady = true;
        _isEverythingIsReady = _isMapboxMapIsReady;
      });
    });
  }

  void _flyTo(GeoCoordinates geoCoordinates) {
    GeoCoordinatesUpdate geoCoordinatesUpdate =
        GeoCoordinatesUpdate.fromGeoCoordinates(geoCoordinates);
    double bowFactor = 1;
    const double distanceToEarthInMeters = 15;
    MapMeasure mapMeasureZoom =
        MapMeasure(MapMeasureKind.zoomLevel, distanceToEarthInMeters);
    GeoOrientationUpdate orientationUpdate = GeoOrientationUpdate(0, 30);
    MapCameraAnimation animation =
        MapCameraAnimationFactory.flyToWithOrientationAndZoom(
      geoCoordinatesUpdate,
      orientationUpdate,
      mapMeasureZoom,
      bowFactor,
      const Duration(seconds: 3),
    );
    _hereMapController?.camera.startAnimationWithListener(
      animation,
      AnimationListener(
        (state) {
          switch (state) {
            case AnimationState.started:
              break;
            case AnimationState.completed:
              {
                setState(() {
                  _isHereMapOn = false;
                });
                _disposeHERESDK();
                break;
              }
            case AnimationState.cancelled:
              break;
          }
        },
      ),
    );
  }

  void _mapboxToMyLocation(LocationData value) {
    _mapController
        ?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(value.latitude ?? AppConstants.kInitialLocation[0],
              value.longitude ?? AppConstants.kInitialLocation[1]),
          tilt: 30.0,
          zoom: 15.0,
        ),
      ),
    )
        .then((result) {
      print("mapController.animateCamera() returned $result");
    });
  }

  void _disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    SdkContext.release();
  }

  SymbolOptions _getSymbolOptions(ATM atm) {
    LatLng geometry = LatLng(
      atm.latitude,
      atm.longitude,
    );
    return SymbolOptions(
      geometry: geometry,
      iconImage: 'sarrafakLogo',
      iconSize: 0.1,
      iconAnchor: 'bottom',
      fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
      textField: atm.name,
      textSize: 12.5,
      textOffset: const Offset(0, 0.8),
      textAnchor: 'top',
      textColor: '#000000',
      textHaloBlur: 1,
      textHaloColor: '#ffffff',
      textHaloWidth: 0.8,
    );
  }

  Future<void> _addAll() async {
    List<ATM> symbolsToAdd = atms;
    for (var s in _mapController!.symbols) {
      symbolsToAdd.removeWhere((i) => i.id == s.data!['id']);
    }

    if (symbolsToAdd.isNotEmpty) {
      final List<SymbolOptions> symbolOptionsList =
          symbolsToAdd.map((i) => _getSymbolOptions(i)).toList();
      _mapController!.addSymbols(
          symbolOptionsList, symbolsToAdd.map((i) => {'id': i.id}).toList());
    }
  }
}
