import 'package:flutter/material.dart';

import '../../../app_constants.dart';
import '../../../data/models/atm.dart';

class SearchATMsButton extends StatefulWidget {
  final Future<bool> Function(List<ATM>) onATMsResult;
  final Function() onCloseTapped;
  const SearchATMsButton({
    Key? key,
    required this.onATMsResult,
    required this.onCloseTapped,
  }) : super(key: key);

  @override
  State<SearchATMsButton> createState() => _SearchATMsButtonState();
}

class _SearchATMsButtonState extends State<SearchATMsButton> {
  bool _isLoading = false;

  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (!_isLoading) {
          if (_isLoaded) {
            widget.onCloseTapped();
            setState(() {
              _isLoaded = false;
            });
          } else {
            setState(() {
              _isLoading = true;
            });

            await Future.delayed(const Duration(milliseconds: 500));
            await widget.onATMsResult(atms);
            setState(() {
              _isLoaded = true;
              _isLoading = false;
            });
          }
        }
      },
      child: SizedBox(
        width: 24,
        height: 24,
        child: _isLoading
            ? const CircularProgressIndicator()
            : _isLoaded
                ? const Icon(Icons.close)
                : Image.asset(
                    "assets/icons/sarrafak_432x432.png",
                  ),
      ),
    );
  }
}
