import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sarrafak/presentation/ui/screens/splash_screen.dart';
import 'package:sarrafak/services/here_map_service.dart';

import '../../../app_constants.dart';
import '../../../data/models/atm.dart';
import '../../../services/mapbox_map_service.dart';
import '../widgets/day_night_reveal.dart';
import '../widgets/my_location.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MapboxMapService? _mapboxMapService;
  HereMapService? _hereMapService;

  bool _isEverythingIsReady = false;
  bool _isHereMapIsReady = false;
  bool _isMapboxMapIsReady = false;

  bool _isHereMapOn = true;

  bool _myLocationEnabled = false;

  bool _isSatellite = true;

  ATM _selectedSymbolDetails = atms.first;

  late PageController _pageController;
  int prevPage = 0;
  bool isReviews = false;
  bool isPhotos = true;
  bool _isPressedATM = false;

  @override
  void initState() {
    HereMapService.initializeHERESDK();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
      ..addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    HereMapService.disposeHERESDK();
    super.dispose();
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
                      ? MapboxStyles.LIGHT
                      : MapboxStyles.DARK,
              accessToken: AppConstants.kMapboxMapAccessToken,
              onMapCreated: _onMapboxMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(AppConstants.kInitialLocation[0],
                    AppConstants.kInitialLocation[1]),
                zoom: 11.0,
              ),
              onStyleLoadedCallback: _onMapboxStyleLoaded,
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
          _isPressedATM
              ? Positioned(
                  bottom: 20.0,
                  child: Container(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    child: PageView.builder(
                        controller: _pageController,
                        itemCount: atms.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _nearbyATMsList(index);
                        }),
                  ))
              : Container(),
          _isPressedATM
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
          PositionedDirectional(
            bottom: 20,
            end: 20,
            child: MyLocationButton(
              onResult: (isLocationEnabled, locationValue) {
                setState(() {
                  _myLocationEnabled = isLocationEnabled;
                  if (isLocationEnabled && locationValue != null) {
                    _mapboxMapService?.animateMapboxCamera(
                      locationValue.latitude!,
                      locationValue.longitude!,
                    );
                    if (_isHereMapOn) {
                      _hereMapService?.flyTo(
                          GeoCoordinates(
                            locationValue.latitude!,
                            locationValue.longitude!,
                          ),
                          () => setState(() {
                                _isHereMapOn = false;
                              }));
                    }
                  }
                });
              },
            ),
          ),
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

  AnimatedBuilder _nearbyATMsList(index) => AnimatedBuilder(
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
            ATM atm = atms[index];
            _mapboxMapService?.selectSymbol(atm.id);
            setState(() {});
            //moveCameraSlightly();
          },
          child: Stack(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 20.0,
                  ),
                  height: 125.0,
                  width: 275.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
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
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                        ),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                'https://pic.onlinewebfonts.com/svg/img_546302.png'),
                                            fit: BoxFit.cover)),
                                  )
                                : Container(
                                    height: 90.0,
                                    width: 20.0,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                        ),
                                        color: Colors.blue),
                                  )
                            : Container(),
                        const SizedBox(width: 5.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 170.0,
                              child: Text(atms[index].name,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontFamily: 'WorkSans',
                                      fontWeight: FontWeight.bold)),
                            ),
                            /*RatingStars(
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
                          ),*/
                            Container(
                              width: 170.0,
                              child: Text(
                                atms[index].address ?? 'none',
                                style: const TextStyle(
                                    color: Colors.green,
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

  void _onHereMapCreated(HereMapController hereMapController) {
    _hereMapService = HereMapService(hereMapController);
    _hereMapService?.loadFirstScene(onLoaded: (isLoaded) {
      setState(() {
        _isHereMapIsReady = true;
        _isEverythingIsReady = _isMapboxMapIsReady;
      });
    });
  }

  _onMapboxMapCreated(MapboxMapController controller) {
    _mapboxMapService = MapboxMapService(controller);
    _mapboxMapService?.addOnSymbolTappedListener(_onATMTapped);
  }

  void _onMapboxStyleLoaded() {
    _mapboxMapService?.onStyleLoaded(
        symbolsToAdd: atms
            .map(
              (e) => {
                'id': e.id,
                'name': e.name,
                'lat': e.latitude,
                'long': e.longitude,
              },
            )
            .toList(),
        onLoaded: () {
          setState(() {
            _isMapboxMapIsReady = true;
            _isEverythingIsReady = _isHereMapIsReady;
          });
        });
  }

  Future<void> _onScroll() async {
    if (_pageController.page!.toInt() != prevPage) {
      prevPage = _pageController.page!.toInt();
      _isPressedATM = false;
      ATM atm = atms[_pageController.page?.toInt() ?? 0];
      await _mapboxMapService?.selectSymbol(atm.id);
    }
  }

  void _onATMTapped(String id) {
    setState(() {
      _isPressedATM = true;
      _selectedSymbolDetails = atms.firstWhere((element) => element.id == id);
    });
  }
}
