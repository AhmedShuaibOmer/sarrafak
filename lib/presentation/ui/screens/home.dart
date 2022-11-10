import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sarrafak/presentation/ui/screens/splash_screen.dart';
import 'package:sarrafak/presentation/ui/widgets/atm_details_card.dart';
import 'package:sarrafak/services/here_map_service.dart';

import '../../../app_constants.dart';
import '../../../data/models/atm.dart';
import '../../../services/mapbox_map_service.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/theme_bloc.dart';
import '../widgets/atms_list.dart';
import '../widgets/my_location.dart';
import '../widgets/search_atms_button.dart';
import 'navigation.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  MapboxMapService? _mapboxMapService;
  HereMapService? _hereMapService;

  bool _isHereMapOn = true;

  bool _myLocationEnabled = false;

  bool _isSatellite = true;

  ATM? _selectedATM;

  bool _isInfoPressed = false;

  bool _isShowATMsList = false;

  List<ATM> _atmsList = [];

  bool _isShowDirectionsFab = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return Scaffold(
        body: Builder(builder: (context) {
          bool isLight = context.watch<ThemeBloc>().state.isLight;
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
            AnimatedPositionedDirectional(
              duration: const Duration(
                milliseconds: 500,
              ),
              start: _isShowATMsList ? 1 : screenWidth,
              bottom: 60.0,
              child: ATMsList(
                atms: _atmsList,
                isInfoPressed: _isInfoPressed,
                onScroll: (atm) async {
                  setState(() {
                    _selectedATM = atm;
                  });
                },
                onTap: (atm) async {
                  setState(() {
                    _selectedATM = atm;
                  });
                  await _mapboxMapService?.selectSymbol(atm.id);
                },
                onDirectionsPressed: (atm) {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => Navigation(),
                  ));
                },
                onInfoPressed: (atm) {
                  setState(() {
                    _selectedATM = atm;
                    _isInfoPressed = !_isInfoPressed;
                  });
                },
              ),
            ),
            AnimatedPositionedDirectional(
              top: 120.0,
              end: _isInfoPressed ? screenWidth - 225 : screenWidth,
              curve: Curves.easeInOut,
              duration: const Duration(
                milliseconds: 500,
              ),
              child: ATMDetailsCard(
                atm: _selectedATM,
              ),
            ),
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
            AnimatedPositionedDirectional(
              curve: Curves.easeInOut,
              duration: const Duration(
                milliseconds: 500,
              ),
              bottom: _isHereMapOn ? screenHeight : 20,
              start: 20,
              child: SearchATMsButton(
                onATMsResult: (atms) async {
                  await _mapboxMapService?.addAllSymbols(
                    atms
                        .map(
                          (e) => {
                            'id': e.id,
                            'name': e.name,
                            'lat': e.latitude,
                            'long': e.longitude,
                          },
                        )
                        .toList(),
                  );
                  setState(() {
                    _atmsList = [];
                    _atmsList.addAll(atms);
                    if (_isShowDirectionsFab) _isShowDirectionsFab = false;
                    _isShowATMsList = true;
                  });
                  return true;
                },
                onCloseTapped: () {
                  setState(() {
                    if (_selectedATM != null) _isShowDirectionsFab = true;
                    _isShowATMsList = false;
                    _isInfoPressed = false;
                  });
                },
              ),
            ),
            AnimatedPositionedDirectional(
              curve: Curves.easeInOut,
              duration: const Duration(
                milliseconds: 500,
              ),
              end: _isShowDirectionsFab ? screenWidth - 76 : screenWidth,
              bottom: 96,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {},
                child: Icon(
                  Icons.directions_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            AnimatedPositionedDirectional(
              curve: Curves.easeInOut,
              duration: const Duration(
                milliseconds: 500,
              ), //screenHeight - 168
              bottom: _isHereMapOn
                  ? screenHeight
                  : _isShowATMsList
                      ? 260
                      : _isShowDirectionsFab
                          ? 168
                          : 96,
              start: 20,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _isSatellite = !_isSatellite;
                  });
                },
                child: const Icon(Icons.layers),
              ),
            ),
            AnimatedPositionedDirectional(
              curve: Curves.easeInOut,
              duration: const Duration(
                milliseconds: 500,
              ), //screenHeight - 168
              bottom: _isHereMapOn
                  ? screenHeight
                  : _isShowATMsList
                      ? 318
                      : _isShowDirectionsFab
                          ? 226
                          : 154,
              end: _isSatellite ? screenWidth : screenWidth - 68,
              child: FloatingActionButton.small(
                onPressed: () {
                  context.read<ThemeBloc>().add(const AddToggleTheme());
                },
                child: isLight
                    ? const Icon(Icons.dark_mode_outlined)
                    : const Icon(Icons.sunny),
              ),
            ),
            AnimatedPositioned(
                top: state is MapsLoadedState ? screenHeight : 0,
                curve: Curves.easeInOut,
                duration: const Duration(
                  milliseconds: 500,
                ),
                child: const SplashScreen()),
          ]);
        }),
        /*floatingActionButton: !_isHereMapOn
            ? MenuButton(
                onLayersPressed: () => setState(() {}),
                onNavigatePressed: () => setState(() {
                  _isSatellite = !_isSatellite;
                }),
              )
            : null,*/
      );
    });
  }

  void _onHereMapCreated(HereMapController hereMapController) {
    _hereMapService = HereMapService(hereMapController);
    _hereMapService?.loadFirstScene(onLoaded: (isLoaded) {
      context.read<HomeBloc>().add(AddHereMapIsReady());
    });
  }

  void _onMapboxMapCreated(MapboxMapController controller) {
    _mapboxMapService = MapboxMapService(controller);
    _mapboxMapService?.addOnSymbolTappedListener(_onATMTapped);
  }

  Future<void> _onMapboxStyleLoaded() async {
    print('Mapbox Style Loaded------------------------------------------');

    await _mapboxMapService?.onStyleLoaded(onLoaded: () {
      context.read<HomeBloc>().add(AddMapboxMapIsReady());
    });
  }

  void _onATMTapped(String id) {
    if (id != '-1') {
      setState(() {
        if (!_isShowATMsList) {
          _isShowDirectionsFab = true;
        }
        _selectedATM = atms.firstWhere((element) => element.id == id);
      });
    } else {
      setState(() {
        _isShowDirectionsFab = false;
      });
      _selectedATM = null;
    }
  }
}
