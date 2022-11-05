import 'dart:typed_data';

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
import '../../../helpers/page.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: [
        SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: MapboxMap(
            styleString: MapboxStyles.SATELLITE,
            /*isLight
                      ? AppConstants.mapBoxStyleId
                      : AppConstants.mapBoxDarkStyleId,*/
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
      ]),
    );
  }

  _onMapboxMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  _onStyleLoadedCallback() {
    addImageFromAsset("sarrafakLogo", "assets/icons/sarrafak_432x432.png");
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
}
