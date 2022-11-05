import 'dart:typed_data';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flip_card/flip_card.dart';
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

  Symbol? _selectedSymbol;

  ATM _selectedSymbolDetails = atms.first;

  late PageController _pageController;
  int prevPage = 0;
  bool isReviews = false;
  bool isPhotos = true;
  bool _isCardTapped = false;
  bool _isPressedATM = false;

  @override
  void initState() {
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
      ..addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_pageController.page!.toInt() != prevPage) {
      prevPage = _pageController.page!.toInt();
      _isCardTapped = false;
      goToTappedPlace();
    }
  }

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
          _isPressedATM
              ? Positioned(
                  bottom: 20.0,
                  child: Container(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    child: PageView.builder(
                        controller: _pageController,
                        itemCount: allFavoritePlaces.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _nearbyPlacesList(index);
                        }),
                  ))
              : Container(),
          _isCardTapped
              ? Positioned(
                  top: 100.0,
                  left: 15.0,
                  child: FlipCard(
                    front: Container(
                      height: 250.0,
                      width: 175.0,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Container(
                            height: 150.0,
                            width: 175.0,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        'https://pic.onlinewebfonts.com/svg/img_546302.png'),
                                    fit: BoxFit.cover)),
                          ),
                          Container(
                            padding: const EdgeInsets.all(7.0),
                            width: 175.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Address: ',
                                  style: TextStyle(
                                      fontFamily: 'WorkSans',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                    width: 105.0,
                                    child: Text(
                                      _selectedSymbolDetails.address,
                                      style: const TextStyle(
                                          fontFamily: 'WorkSans',
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w400),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
                            width: 175.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Contact: ',
                                  style: TextStyle(
                                      fontFamily: 'WorkSans',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                    width: 105.0,
                                    child: Text(
                                      _selectedSymbolDetails.phoneNumber ??
                                          'none given',
                                      style: const TextStyle(
                                          fontFamily: 'WorkSans',
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w400),
                                    ))
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                    back: Container(
                      height: 300.0,
                      width: 225.0,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isReviews = true;
                                      isPhotos = false;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 700),
                                    curve: Curves.easeIn,
                                    padding: const EdgeInsets.fromLTRB(
                                        7.0, 4.0, 7.0, 4.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(11.0),
                                        color: isReviews
                                            ? Colors.green.shade300
                                            : Colors.white),
                                    child: Text(
                                      'Reviews',
                                      style: TextStyle(
                                          color: isReviews
                                              ? Colors.white
                                              : Colors.black87,
                                          fontFamily: 'WorkSans',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isReviews = false;
                                      isPhotos = true;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 700),
                                    curve: Curves.easeIn,
                                    padding:
                                        EdgeInsets.fromLTRB(7.0, 4.0, 7.0, 4.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(11.0),
                                        color: isPhotos
                                            ? Colors.green.shade300
                                            : Colors.white),
                                    child: Text(
                                      'Photos',
                                      style: TextStyle(
                                          color: isPhotos
                                              ? Colors.white
                                              : Colors.black87,
                                          fontFamily: 'WorkSans',
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 250.0,
                            child: isReviews
                                ? ListView(
                                    children: [
                                      /*
                            if (isReviews &&
                                tappedPlaceDetail['reviews'] !=
                                    null)
                              ...tappedPlaceDetail['reviews']!
                                  .map((e) {
                                return _buildReviewItem(e);
                              })*/
                                    ],
                                  )
                                : Container() /*_buildPhotoGallery(
                            tappedPlaceDetail['photos'] ?? [])*/
                            ,
                          )
                        ],
                      ),
                    ),
                  ))
              : Container(),
          _isEverythingIsReady ? Container() : const SplashScreen(),
        ]);
      }),
      floatingActionButton: !_isHereMapOn
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

  _nearbyATMList(index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget? widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page! - index);
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 125.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: InkWell(
        onTap: () async {
          cardTapped = !cardTapped;
          if (cardTapped) {
            tappedPlaceDetail = await MapServices()
                .getPlace(allFavoritePlaces[index]['place_id']);
            setState(() {});
          }
          moveCameraSlightly();
        },
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20.0,
                ),
                height: 125.0,
                width: 275.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          offset: Offset(0.0, 4.0),
                          blurRadius: 10.0)
                    ]),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  child: Row(
                    children: [
                      _pageController.position.haveDimensions
                          ? _pageController.page!.toInt() == index
                              ? Container(
                                  height: 90.0,
                                  width: 90.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                        topLeft: Radius.circular(10.0),
                                      ),
                                      image: DecorationImage(
                                          image: NetworkImage(placeImg != ''
                                              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$placeImg&key=$key'
                                              : 'https://pic.onlinewebfonts.com/svg/img_546302.png'),
                                          fit: BoxFit.cover)),
                                )
                              : Container(
                                  height: 90.0,
                                  width: 20.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                        topLeft: Radius.circular(10.0),
                                      ),
                                      color: Colors.blue),
                                )
                          : Container(),
                      SizedBox(width: 5.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 170.0,
                            child: Text(allFavoritePlaces[index]['name'],
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.bold)),
                          ),
                          RatingStars(
                            value: allFavoritePlaces[index]['rating']
                                        .runtimeType ==
                                    int
                                ? allFavoritePlaces[index]['rating'] * 1.0
                                : allFavoritePlaces[index]['rating'] ?? 0.0,
                            starCount: 5,
                            starSize: 10,
                            valueLabelColor: const Color(0xff9b9b9b),
                            valueLabelTextStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'WorkSans',
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0),
                            valueLabelRadius: 10,
                            maxValue: 5,
                            starSpacing: 2,
                            maxValueVisibility: false,
                            valueLabelVisibility: true,
                            animationDuration: Duration(milliseconds: 1000),
                            valueLabelPadding: const EdgeInsets.symmetric(
                                vertical: 1, horizontal: 8),
                            valueLabelMargin: const EdgeInsets.only(right: 8),
                            starOffColor: const Color(0xffe7e8ea),
                            starColor: Colors.yellow,
                          ),
                          Container(
                            width: 170.0,
                            child: Text(
                              allFavoritePlaces[index]['business_status'] ??
                                  'none',
                              style: TextStyle(
                                  color: allFavoritePlaces[index]
                                              ['business_status'] ==
                                          'OPERATIONAL'
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _onMapboxMapCreated(MapboxMapController controller) {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _isPressedATM = !_isPressedATM;
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 0.2),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
      _isPressedATM = true;
      _selectedSymbolDetails =
          atms.firstWhere((element) => element.id == symbol.data!['id']);
    });
    _updateSelectedSymbol(
      const SymbolOptions(
        iconSize: 0.4,
      ),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) async {
    await _mapController!.updateSymbol(_selectedSymbol!, changes);
  }

  _onStyleLoadedCallback() async {
    await addImageFromAsset(
        "sarrafakLogo", "assets/icons/sarrafak_432x432.png");
    await _addAll();
    await _mapController!.setSymbolIconAllowOverlap(true);
    await _mapController!.setSymbolTextAllowOverlap(true);
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
      iconSize: 0.2,
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
