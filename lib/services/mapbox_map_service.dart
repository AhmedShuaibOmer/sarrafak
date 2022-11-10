/// TODO : In case of duplicate something crash... do paste the snippet
/// below in the build.gradle of the flutter nav plugin:
///     implementation ("com.mapbox.navigation:android:2.4.1", {
///        exclude group: 'com.mapbox.mapboxsdk', module:'mapbox-android-telemetry'
///    })
import 'package:flutter/services.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapboxMapService {
  final MapboxMapController _mapboxMapController;

  Symbol? _selectedSymbol;

  MapboxMapService(this._mapboxMapController);

  void addOnSymbolTappedListener(void Function(String id) onTapped) {
    _mapboxMapController.onSymbolTapped.add((symbol) {
      _onSymbolTapped(symbol, onTapped);
    });
  }

  Future<void> onStyleLoaded({
    required Function() onLoaded,
  }) async {
    await _addImageFromAsset(
        "sarrafakLogo", "assets/icons/sarrafak_432x432.png");
    print('Mapbox added image asset------------------------------------------');

    await _mapboxMapController.setSymbolIconAllowOverlap(true);
    await _mapboxMapController.setSymbolTextAllowOverlap(true);
    onLoaded();
  }

  Future<void> selectSymbol(String id) async {
    Symbol? selectedSymbol;

    selectedSymbol = _mapboxMapController.symbols
        .firstWhere((element) => element.data!['id'] == id);

    _mapboxMapController.symbolManager?.onTap?.call(selectedSymbol);
    LatLng latLng = await _mapboxMapController.getSymbolLatLng(selectedSymbol);
    await animateMapboxCamera(latLng.latitude, latLng.longitude);
  }

  Future<bool?>? animateMapboxCamera(double lat, double long) {
    return _mapboxMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(lat, long),
          tilt: 30.0,
          zoom: 15.0,
        ),
      ),
    );
  }

  /// Adds an asset image to the currently displayed style
  Future<void> _addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return _mapboxMapController!.addImage(name, list);
  }

  Future<void> addAllSymbols(List<Map<String, Object>> symbolsToAdd) async {
    for (var s in _mapboxMapController.symbols) {
      symbolsToAdd.removeWhere((i) => i['id'] == s.data!['id']);
    }

    if (symbolsToAdd.isNotEmpty) {
      final List<SymbolOptions> symbolOptionsList = symbolsToAdd
          .map((i) => _getSymbolOptions(
                i['lat'] as double,
                i['long'] as double,
                i['name'] as String,
              ))
          .toList();
      await _mapboxMapController.addSymbols(
          symbolOptionsList,
          symbolsToAdd
              .map((i) => {
                    'id': i['id'] as String,
                  })
              .toList());
    }
  }

  SymbolOptions _getSymbolOptions(
    double lat,
    double long,
    String name,
  ) {
    LatLng geometry = LatLng(
      lat,
      long,
    );
    return SymbolOptions(
      geometry: geometry,
      iconImage: 'sarrafakLogo',
      iconSize: 0.2,
      iconAnchor: 'bottom',
      fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
      textField: name,
      textSize: 12.5,
      textOffset: const Offset(0, 0.8),
      textAnchor: 'top',
      textColor: '#000000',
      textHaloBlur: 1,
      textHaloColor: '#ffffff',
      textHaloWidth: 0.8,
    );
  }

  void _onSymbolTapped(
    Symbol symbol,
    void Function(String id) onTapped,
  ) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 0.2),
      );
      if (_selectedSymbol?.data!['id'] == symbol.data!['id']) {
        _selectedSymbol = null;
        onTapped('-1');
        return;
      }
    }
    _selectedSymbol = symbol;
    onTapped(symbol.data!['id']);
    _updateSelectedSymbol(
      const SymbolOptions(
        iconSize: 0.4,
      ),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) async {
    await _mapboxMapController.updateSymbol(_selectedSymbol!, changes);
  }
}
