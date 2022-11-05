// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'app_constants.dart';
import 'helpers/animate_camera.dart';
import 'helpers/annotation_order_maps.dart';
import 'helpers/click_annotations.dart';
import 'helpers/custom_marker.dart';
import 'helpers/layer.dart';
import 'helpers/line.dart';
import 'helpers/local_style.dart';
import 'helpers/map_ui.dart';
import 'helpers/move_camera.dart';
import 'helpers/offline_regions.dart';
import 'helpers/page.dart';
import 'helpers/place_batch.dart';
import 'helpers/place_circle.dart';
import 'helpers/place_fill.dart';
import 'helpers/place_source.dart';
import 'helpers/place_symbol.dart';
import 'helpers/scrolling_map.dart';
import 'presentation/sarrafak_app.dart';
import 'presentation/ui/screens/here_home.dart';
import 'presentation/ui/screens/home.dart';
import 'presentation/ui/screens/navigation.dart';
import 'presentation/ui/widgets/day_night_reveal.dart';

final List<ExamplePage> _allPages = <ExamplePage>[
  MapUiPage(),
  HomePage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PlaceSymbolPage(),
  PlaceSourcePage(),
  LinePage(),
  LocalStylePage(),
  LayerPage(),
  PlaceCirclePage(),
  PlaceFillPage(),
  ScrollingMapPage(),
  OfflineRegionsPage(),
  AnnotationOrderPage(),
  CustomMarkerPage(),
  BatchAddPage(),
  ClickAnnotationPage(),
  NavigationPage(),
  const DayNightRevealPage(),
  const HereHomePage(),
];

class MapsDemo extends StatefulWidget {
  // FIXME: You need to pass in your access token via the command line argument
  // --dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE
  // It is also possible to pass it in while running the app via an IDE by
  // passing the same args there.
  //
  // Alternatively you can replace `String.fromEnvironment("ACCESS_TOKEN")`
  // in the following line with your access token directly.
  static const String ACCESS_TOKEN = AppConstants.mapBoxAccessToken;

  @override
  State<MapsDemo> createState() => _MapsDemoState();
}

class _MapsDemoState extends State<MapsDemo> {
  @override
  void initState() {
    super.initState();
  }

  /// TODO : In case of duplicate something crash... do paste the snippet
  /// below in the build.gradle of the flutter nav plugin:
  ///     implementation ("com.mapbox.navigation:android:2.4.1", {
  ///        exclude group: 'com.mapbox.mapboxsdk', module:'mapbox-android-telemetry'
  ///    })

  /// Determine the android version of the phone and turn off HybridComposition
  /// on older sdk versions to improve performance for these
  ///
  /// !!! Hybrid composition is currently broken do no use !!!
  Future<void> initHybridComposition() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;
      if (sdkVersion != null && sdkVersion >= 29) {
        MapboxMap.useHybridComposition = true;
      } else {
        MapboxMap.useHybridComposition = false;
      }
    }
  }

  void _pushPage(BuildContext context, ExamplePage page) async {
/*    if (!kIsWeb) {
      final location = l.Location();
      final hasPermissions = await location.hasPermission();
      if (hasPermissions != l.PermissionStatus.granted) {
        await location.requestPermission();
      }
    }*/
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapsDemo.ACCESS_TOKEN.isEmpty ||
              MapsDemo.ACCESS_TOKEN.contains("YOUR_TOKEN")
          ? buildAccessTokenWarning()
          : ListView.separated(
              itemCount: _allPages.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (_, int index) => ListTile(
                leading: _allPages[index].leading,
                title: Text(_allPages[index].title),
                onTap: () => _pushPage(context, _allPages[index]),
              ),
            ),
    );
  }

  Widget buildAccessTokenWarning() {
    return Container(
      color: Colors.red[900],
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Please pass in your access token with",
            "--dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE",
            "passed into flutter run or add it to args in vscode's launch.json",
          ]
              .map((text) => Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

void main() {
  _initializeHERESDK();
  runApp(const SarrafakApp());
}

void _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.
  String accessKeyId = "mtYG8t5TrKzO3Lm-ifqDZg";
  String accessKeySecret =
      "ekFeQZfZK1p61Chy_-fxkcEl8gwT2t1MtHbMCVowRK-RFWEkWRgZpxBfC-dFfl30P7djhabIGuojCvR_NdpX1A";
  SDKOptions sdkOptions =
      SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}
