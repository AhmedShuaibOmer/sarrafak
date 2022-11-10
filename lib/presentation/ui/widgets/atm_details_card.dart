import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../../../data/models/atm.dart';

class ATMDetailsCard extends StatefulWidget {
  final ATM? atm;
  const ATMDetailsCard({Key? key, required this.atm}) : super(key: key);

  @override
  State<ATMDetailsCard> createState() => _ATMDetailsCardState();
}

class _ATMDetailsCardState extends State<ATMDetailsCard> {
  bool isReviews = true;

  bool isPhotos = false;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      front: SizedBox(
        width: 175.0,
        child: Card(
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
                      image: AssetImage('assets/atm_illu.png'),
                      fit: BoxFit.cover)),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Address: ',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.atm?.address ?? '',
                    style: const TextStyle(
                        fontFamily: 'WorkSans',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Contact: ',
                  style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.atm?.phoneNumber ?? 'none given',
                    style: const TextStyle(
                        fontFamily: 'WorkSans',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ]),
        ),
      ),
      back: Container(
        height: 300.0,
        width: 225.0,
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor.withOpacity(0.95),
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
                      padding: const EdgeInsets.fromLTRB(7.0, 4.0, 7.0, 4.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11.0),
                          color:
                              isReviews ? Colors.green.shade300 : Colors.white),
                      child: Text(
                        'Reviews',
                        style: TextStyle(
                            color: isReviews ? Colors.white : Colors.black87,
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
                      padding: EdgeInsets.fromLTRB(7.0, 4.0, 7.0, 4.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11.0),
                          color:
                              isPhotos ? Colors.green.shade300 : Colors.white),
                      child: Text(
                        'Photos',
                        style: TextStyle(
                            color: isPhotos ? Colors.white : Colors.black87,
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
    );
  }
}
