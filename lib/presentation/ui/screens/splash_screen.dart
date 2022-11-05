import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Image _logo;
  @override
  void initState() {
    super.initState();
    _logo = Image.asset("assets/icons/sarrafak_432x432.png");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_logo.image, context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
            color: const Color(0xFFE2840A),
            height: screenHeight,
            width: screenWidth,
            child: LottieBuilder.asset(
              'assets/animassets/lf30_editor_1rfpwhai.json',
            )),
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset(
            "assets/icons/sarrafak_432x432.png",
          ),
        ),
      ],
    );
  }
}
