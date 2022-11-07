import 'package:here_sdk/animation.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';

import '../app_constants.dart';

class HereMapService {
  final HereMapController _hereMapController;

  HereMapService(this._hereMapController);

  static void initializeHERESDK() async {
    // Needs to be called before accessing SDKOptions to load necessary libraries.
    SdkContext.init(IsolateOrigin.main);

    // Set your credentials for the HERE SDK.
    String accessKeyId = AppConstants.kHereMapAccessKeyId;
    String accessKeySecret = AppConstants.kHereMapAccessSecretId;
    SDKOptions sdkOptions =
        SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

    try {
      await SDKNativeEngine.makeSharedInstance(sdkOptions);
    } on InstantiationException {
      throw Exception("Failed to initialize the HERE SDK.");
    }
  }

  void loadFirstScene({required Function(bool) onLoaded}) {
    _hereMapController.mapScene.loadSceneForMapScheme(MapScheme.satellite,
        (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        onLoaded(false);
        return;
      }

      const double distanceToEarthInMeters = 100000000;
      MapMeasure mapMeasureZoom =
          MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
      _hereMapController.camera
          .lookAtPointWithMeasure(GeoCoordinates(0, 0), mapMeasureZoom);
      onLoaded(true);
    });
  }

  void flyTo(GeoCoordinates geoCoordinates, Function() onAnimCompleted) {
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
    _hereMapController.camera.startAnimationWithListener(
      animation,
      AnimationListener(
        (state) {
          switch (state) {
            case AnimationState.started:
              break;
            case AnimationState.completed:
              {
                onAnimCompleted;
                //_disposeHERESDK();
                break;
              }
            case AnimationState.cancelled:
              break;
          }
        },
      ),
    );
  }

  static void disposeHERESDK() async {
    // Free HERE SDK resources before the application shuts down.
    await SDKNativeEngine.sharedInstance?.dispose();
    SdkContext.release();
  }
}
