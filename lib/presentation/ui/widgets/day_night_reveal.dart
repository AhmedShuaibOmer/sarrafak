import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../helpers/page.dart';
import '../../bloc/theme_bloc.dart';

class DayNightRevealPage extends ExamplePage {
  const DayNightRevealPage()
      : super(const Icon(Icons.nightlight_round), 'DayNight Reveal');

  @override
  Widget build(BuildContext context) {
    return DayNightReveal(child: (f) {
      return Container();
    });
  }
}

class DayNightReveal extends StatefulWidget {
  final Widget Function(bool) child;
  const DayNightReveal({Key? key, required this.child}) : super(key: key);

  @override
  State<DayNightReveal> createState() => _DayNightRevealState();
}

class _DayNightRevealState extends State<DayNightReveal>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  Animation<double>? animation;
  bool cirAn = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeIn,
      // reverseCurve: Curves.easeInOut
    );
    animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Builder(
      builder: (context) {
        bool isLight = context.watch<ThemeBloc>().state.isLight;
        return cirAn
            ? CircularRevealAnimation(
                centerOffset: Offset(size.height / 15, size.width / 3.5),
                animation: animation!,
                child: _dayNightBody(isLight),
              )
            : _dayNightBody(isLight);
      },
    );
  }

  Widget _dayNightBody(bool isLight) {
    return Container(
      color: Colors.amber,
      child: Stack(
        children: <Widget>[
          widget.child(isLight),
          Positioned(
            right: MediaQuery.of(context).size.width / 1.18, //230.0,
            child: GestureDetector(
              onTap: () {
                context.read<ThemeBloc>().add(const AddToggleTheme());
                setState(() {
                  cirAn = true;
                });

                if (animationController?.status == AnimationStatus.forward ||
                    animationController?.status == AnimationStatus.completed) {
                  animationController?.reset();
                  animationController?.forward();
                } else {
                  animationController?.forward();
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height / 5.5,
                width: MediaQuery.of(context).size.height / 15,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).hoverColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 14, right: 14, bottom: 28),
                  child: isLight
                      ? Image.asset(
                          "assets/bulb_on.png",
                          fit: BoxFit.fitHeight,
                        )
                      : Image.asset(
                          "assets/bulb_off.png",
                          fit: BoxFit.fitHeight,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
