import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final Function() onLayersPressed;
  final Function() onNavigatePressed;

  const MenuButton({
    Key? key,
    required this.onLayersPressed,
    required this.onNavigatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FabCircularMenu(
        alignment: Alignment.bottomLeft,
        fabColor: Theme.of(context).primaryColor.withOpacity(0.5),
        fabOpenColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        ringDiameter: 250.0,
        ringWidth: 60.0,
        ringColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        fabSize: 60.0,
        children: [
          IconButton(
              onPressed: onNavigatePressed, icon: const Icon(Icons.navigation)),
          IconButton(
            onPressed: onLayersPressed,
            icon: const Icon(Icons.layers),
          ),
        ]);
  }
}
