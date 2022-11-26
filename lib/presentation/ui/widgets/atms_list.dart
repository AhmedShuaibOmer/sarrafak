import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:sarrafak/app_constants.dart';
import 'package:sarrafak/data/models/atm.dart';

class ATMsList extends StatefulWidget {
  final Function(ATM) onScroll;
  final Function(ATM) onTap;
  final List<ATM> atms;
  final bool isInfoPressed;
  const ATMsList({
    Key? key,
    required this.onScroll,
    required this.atms,
    required this.onTap,
    required this.onDirectionsPressed,
    required this.onInfoPressed,
    required this.isInfoPressed,
  }) : super(key: key);

  @override
  State<ATMsList> createState() => _ATMsListState();

  final Function(ATM) onDirectionsPressed;
  final Function(ATM) onInfoPressed;
}

class _ATMsListState extends State<ATMsList> {
  late PageController _pageController;
  int prevPage = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
      ..addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_pageController.page!.toInt() != prevPage) {
      prevPage = _pageController.page!.toInt();
      widget.onScroll(widget.atms[prevPage]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      width: MediaQuery.of(context).size.width,
      child: PageView.builder(
          controller: _pageController,
          itemCount: widget.atms.length,
          itemBuilder: (BuildContext context, int index) {
            return _nearbyATMsList(index);
          }),
    );
  }

  AnimatedBuilder _nearbyATMsList(index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget? w) {
        double value = 1;
        double fabValue = 1;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page! - index);
          fabValue = (1 - (value.abs() * 3) + 0.06).clamp(0.0, 1.0);
          value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
        }
        ATM atm = widget.atms[index];
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 180.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: InkWell(
              onTap: () async {
                widget.onTap(atm);
                //moveCameraSlightly();
              },
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Card(
                    margin: const EdgeInsets.only(
                        right: 10.0, left: 10.0, top: 0.0, bottom: 28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              atms[index].name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                    fontFamily: 'WorkSans',
                                  ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RatingStars(
                              value: widget.atms[index].rating.runtimeType ==
                                      int
                                  ? (widget.atms[index].rating * 1.0).toDouble()
                                  : (widget.atms[index].rating ?? 0.0)
                                      .toDouble(),
                              starCount: 5,
                              starSize: 12,
                              valueLabelColor: AppConstants.kMainColor,
                              valueLabelTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'WorkSans',
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 14),
                              valueLabelRadius: 12,
                              maxValue: 5,
                              starSpacing: 3,
                              maxValueVisibility: true,
                              valueLabelVisibility: true,
                              animationDuration:
                                  const Duration(milliseconds: 1000),
                              valueLabelPadding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 8),
                              valueLabelMargin:
                                  const EdgeInsets.only(right: 10),
                              starOffColor: const Color(0xffe7e8ea),
                              starColor: AppConstants.kMainColor,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              atms[index].address ?? 'none',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Row(
                        children: [
                          FloatingActionButton(
                            heroTag: "btn1",
                            onPressed: () {
                              widget.onInfoPressed(atm);
                            },
                            child: widget.isInfoPressed
                                ? const Icon(Icons.close)
                                : const Icon(Icons.info_outline),
                          ),
                          Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            color: Theme.of(context)
                                    .floatingActionButtonTheme
                                    .backgroundColor ??
                                Theme.of(context).colorScheme.secondary,
                            child: SizedBox(
                              height: 56,
                              width:
                                  (Curves.easeInOut.transform(fabValue) * 104) +
                                      56,
                              child: InkWell(
                                onTap: () {
                                  widget.onDirectionsPressed(atm);
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(
                                        Icons.directions_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Directions',
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        style: Theme.of(context)
                                            .textTheme
                                            .button
                                            ?.copyWith(
                                              letterSpacing: 1.2,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary
                                                  .withOpacity(Curves.easeInOut
                                                          .transform(fabValue) *
                                                      1),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
