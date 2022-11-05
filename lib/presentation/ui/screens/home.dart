import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:sarrafak/presentation/ui/widgets/day_night_reveal.dart';

import '../../../app_constants.dart';
import '../../../helpers/page.dart';

class HomePage extends ExamplePage {
  HomePage() : super(const Icon(Icons.map), 'Home');

  @override
  Widget build(BuildContext context) {
    return const Home();
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => HomeState();
}

class HomeState extends State<Home> {
  MapboxMapController? mapController;

  final CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(
        AppConstants.kInitialLocation[0], AppConstants.kInitialLocation[1]),
    zoom: 11.0,
  );
  LatLng _userLocation = LatLng(
      AppConstants.kInitialLocation[0], AppConstants.kInitialLocation[1]);

  bool _myLocationEnabled = false;
  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.None;

  int _symbolCount = 0;
  Symbol? _selectedSymbol;

  bool _isCardTapped = false;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  _onStyleLoadedCallback() {
    addImageFromAsset("assetImage", "assets/symbols/custom-icon.png");
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return mapController!.addImage(name, list);
  }

  @override
  void dispose() {
    mapController?.onSymbolTapped.remove(_onSymbolTapped);
    super.dispose();
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSelectedSymbol(
      SymbolOptions(
        iconSize: 1.4,
      ),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) async {
    await mapController!.updateSymbol(_selectedSymbol!, changes);
  }

  void _add() {
    LatLng geometry = const LatLng(
      15.5108627,
      32.5794388,
    );
    mapController!.addSymbol(
        SymbolOptions(
          geometry: geometry,
          textField: 'GH6H%2BGQ3 Bank of Khartoum',
          textOffset: const Offset(0, 0.8),
          iconImage: "assets/symbols/custom-icon.png",
          fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
          textSize: 12.5,
          textAnchor: 'top',
          textColor: '#000000',
          textHaloBlur: 1,
          textHaloColor: '#ffffff',
          textHaloWidth: 0.8,
        ),
        {'id': 'GH6H%2BGQ3 Bank of Khartoum'});
    setState(() {
      _symbolCount += 1;
      _isCardTapped = false;
    });
  }

  void _remove() {
    mapController!.removeSymbol(_selectedSymbol!);
    setState(() {
      _selectedSymbol = null;
      _symbolCount -= 1;
    });
  }

  void _removeAll() {
    mapController!.removeSymbols(mapController!.symbols);
    setState(() {
      _selectedSymbol = null;
      _symbolCount = 0;
    });
  }

  Future<void> _changeAlpha() async {
    double? current = _selectedSymbol!.options.iconOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }
    _updateSelectedSymbol(
      SymbolOptions(iconOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  void _getLatLng() async {
    LatLng latLng = await mapController!.getSymbolLatLng(_selectedSymbol!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(latLng.toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: DayNightReveal(
        child: (isLight) {
          return Stack(
            children: [
              SizedBox(
                height: screenHeight,
                width: screenWidth,
                child: MapboxMap(
                  styleString: MapboxStyles.SATELLITE,
                  /*isLight
                      ? AppConstants.mapBoxStyleId
                      : AppConstants.mapBoxDarkStyleId,*/
                  accessToken: AppConstants.mapBoxAccessToken,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: _kInitialPosition,
                  onStyleLoadedCallback: _onStyleLoadedCallback,
                  trackCameraPosition: true,
                  myLocationEnabled: _myLocationEnabled,
                  myLocationTrackingMode: _myLocationTrackingMode,
                ),
              ),
              /* PositionedDirectional(
                bottom: 20,
                end: 20,
                child: MyLocationButton(
                  mapController: mapController,
                  onResult: (isLocationEnabled) {
                    setState(() {
                      _myLocationEnabled = isLocationEnabled;
                    });
                  },
                ),
              )*/
            ],
          );
        },
      ),
      floatingActionButton: FabCircularMenu(
          alignment: Alignment.bottomLeft,
          fabColor: Theme.of(context).primaryColor.withOpacity(0.5),
          fabOpenColor:
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ringDiameter: 250.0,
          ringWidth: 60.0,
          ringColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          fabSize: 60.0,
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _isCardTapped = false;
                  });
                },
                icon: const Icon(Icons.navigation)),
            IconButton(
              onPressed: () {
                setState(() {
                  _isCardTapped = false;
                });
              },
              icon: const Icon(Icons.layers),
            ),
          ]),
    );
  }
}
