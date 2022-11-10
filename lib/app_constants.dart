import 'package:flutter/material.dart';

import 'data/models/atm.dart';

class AppConstants {
  static const String kMapboxMapAccessToken =
      'pk.eyJ1IjoiYWNzdGF0bWZpbmRlciIsImEiOiJjbDl3bTdhbDQwMXZsM3Bub3ZuNzhqMnMzIn0.cJINNTA6-iwDAJMcFX6pug';

  static const kHereMapAccessKeyId = 'mtYG8t5TrKzO3Lm-ifqDZg';

  static const kHereMapAccessSecretId =
      'ekFeQZfZK1p61Chy_-fxkcEl8gwT2t1MtHbMCVowRK-RFWEkWRgZpxBfC-dFfl30P7djhabIGuojCvR_NdpX1A';

  static final kInitialLocation = <double>[15.508457, 32.522854];

  static const kMainColor = Color(0xffe2840a);
}

final List<ATM> atms = [
  ATM(
    id: '1',
    name: 'صراف آلي بنك الخرطوم',
    address: 'GH6H+GQ3، الخرطوم، السودان',
    latitude: 15.5112403,
    longitude: 32.6260307,
    phoneNumber: '0156661000',
    website: 'http://bankofkhartoum.com/',
    rating: 4,
  ),
  ATM(
    id: '2',
    name: 'صراف آلي البنك السعودي',
    address: 'JG29+PRV, Saleh Pasha El Mek St, الخرطوم، السودان',
    latitude: 15.5811562,
    longitude: 32.5519628,
    rating: 3,
  ),
  ATM(
    id: '3',
    name: 'صراف آلي بنك الخرطوم',
    address: 'JFCH+MMG، أم درمان، السودان Mek St, الخرطوم، السودان',
    latitude: 15.6290897,
    longitude: 32.5064747,
    phoneNumber: '0156661000',
    website: 'http://www.bankofkhartoum.com/',
    rating: 3,
  ),
  ATM(
    id: '4',
    name: 'صرافة بنك الخرطوم',
    address: 'JCWG+Q3W، أمبدة،، السودان',
    latitude: 15.6469964,
    longitude: 32.4334806,
    phoneNumber: '0114674550',
    rating: 2,
  ),
  ATM(
    id: '5',
    name: 'ATM',
    address: 'MFCG+JW8، أم درمان، السودان',
    latitude: 15.6715316,
    longitude: 32.5705676,
    rating: 5,
  ),
  ATM(
    id: '6',
    name: 'صراف آلي',
    address: 'JG46+M8R، الخرطوم، السودان',
    latitude: 15.5827217,
    longitude: 32.5856053,
    rating: 4,
  ),
  ATM(
    id: '7',
    name: 'صراف آلي بنك السلام',
    address: 'JG39+HX4, Sayid El Mirghani, الخرطوم، السودان',
    latitude: 15.5880005,
    longitude: 32.5678068,
    phoneNumber: '0183737000',
    rating: 2,
  ),
  ATM(
    id: '8',
    name: 'صراف آلي بنك الخرطوم',
    address: 'JGCQ+C9P، الخرطوم بحري، السودان',
    latitude: 15.6210943,
    longitude: 32.6702929,
    phoneNumber: '0156661000',
    website: 'http://www.bankofkhartoum.com/',
    rating: 1,
  ),
  ATM(
    id: '9',
    name: 'صراف آلي بنك أمدرمان الوطني فرع الصناعات',
    address: 'JGRR+WPJ، الخرطوم بحري، السودان',
    latitude: 15.6210943,
    longitude: 32.6702929,
    phoneNumber: '0183770400',
    rating: 4,
  ),
  ATM(
    id: '10',
    name: 'صراف آلي بنك الخليج',
    address:
        'JGPJ+5HP، الختمية، الخرطوم بحري،، الخرطوم بحري،، الخرطوم بحري،، الخرطوم بحري، السودان',
    latitude: 15.6312738,
    longitude: 32.5592396,
    rating: 3,
  ),
  ATM(
    id: '11',
    name: 'صراف آلي بنك الخرطوم',
    address: 'JGCQ+C9P، الخرطوم بحري، السودان',
    latitude: 15.6291339,
    longitude: 32.5500493,
    phoneNumber: '0156661000',
    website: 'http://www.bankofkhartoum.com/',
    rating: 2,
  ),
  ATM(
    id: '12',
    name: 'مصرف البلد',
    address: 'JGHV+QFR، شارع الإنقاذ، الخرطوم بحري، السودان',
    latitude: 15.6299853,
    longitude: 32.5463612,
  ),
  ATM(
      id: '13',
      name: 'صراف آلي بنك الخرطوم فرع الانقاذ بحري',
      address: 'JGMQ+FX9، شارع الإنقاذ، الخرطوم بحري، السودان',
      latitude: 15.6337319,
      longitude: 32.5401363,
      phoneNumber: '0156661000',
      rating: 4,
      website: 'http://www.bankofkhartoum.com/'),
  ATM(
    id: '14',
    name: 'Sudanese Islamic Bank',
    address: 'JHM4+9F7، الخرطوم بحري، السودان',
    latitude: 15.6339587,
    longitude: 32.5738708,
    rating: 3,
  ),
  ATM(
    id: '15',
    name: 'صراف آلي بنك الخرطوم',
    address: 'JHW4+68F، الخرطوم بحري، السودان',
    latitude: 15.6339587,
    longitude: 32.5738708,
    phoneNumber: '0156661000',
    website: ' http://bankofkhartoum.com/',
    rating: 1,
  ),
  ATM(
    id: '16',
    name: 'United Capital Bank ATM',
    address: 'JHX3+VX9، الخرطوم بحري، السودان',
    latitude: 15.6339587,
    longitude: 32.5851583,
    rating: 5,
  ),
  ATM(
    id: '17',
    name: 'صراف آلي بنك امدرمان الوطني معرض الخرطوم الدولي',
    address: 'JH59+66H، شارع المعرض، الخرطوم، السودان',
    latitude: 15.624667,
    longitude: 32.633458,
    phoneNumber: '0183770400',
    rating: 2,
  ),
  ATM(
    id: '18',
    name: 'صراف آلي البنك السوداني الفرنسي',
    address: 'HHV6+M2J، الخرطوم، السودان',
    latitude: 15.5975081,
    longitude: 32.5796399,
    phoneNumber: '0183771730',
    rating: 1,
  ),
  ATM(
    id: '19',
    name: 'بنك الخرطوم',
    address: 'GHJ4+M3H، شارع الشهيد، كرار الخرطوم، الخرطوم، السودان',
    latitude: 15.530263,
    longitude: 32.5796399,
    phoneNumber: '0156661000',
    rating: 4,
    website: 'http://www.bankofkhartoum.com/',
  ),
/*  ATM(
    id: '20',
    name: 'كلية السلامة للعلوم والتكنو لوجيا',
    address: 'JGMV+G68، الخرطوم بحري، السودان',
    latitude: 15.6337863,
    longitude: 32.5438025,
    phoneNumber: '0999921111',
    website: 'http://www.acst.edu.sd/',
  ),*/
];
