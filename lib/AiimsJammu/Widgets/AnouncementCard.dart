// //
// // import 'package:flutter/material.dart';
// // import '/AiimsJammu/Screens/HomePage.dart';
// //
// //
// // class AnnouncementCard extends StatelessWidget {
// //   final String department;
// //   final String dateTime;
// //   final String article;
// //
// //   const AnnouncementCard({
// //     Key? key, required this.department, required this.dateTime, required this.article,
// //
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: announcements.map((announcement) {
// //             return Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Text(
// //                       announcement.department,
// //                       style: TextStyle(
// //                         color: Color(0xff0B6B94),
// //                         fontSize: 10,
// //                         fontFamily: 'Roboto',
// //                         fontWeight: FontWeight.w400,
// //                         height: 0,
// //                       ),
// //                     ),
// //                     SizedBox(width: 8),
// //                     Text(
// //                       announcement.dateTime,
// //                       style: TextStyle(
// //                         color: Color(0xFFA1A1AA),
// //                         fontSize: 10,
// //                         fontFamily: 'Roboto',
// //                         fontWeight: FontWeight.w400,
// //                         height: 0,
// //                       ),
// //                     )
// //                   ],
// //                 ),
// //                 SizedBox(height: 8),
// //                 Text(
// //                   announcement.article,
// //                   style: TextStyle(
// //                     color: Color(0xFF3F3F46),
// //                     fontSize: 14,
// //                     fontFamily: 'Roboto',
// //                     fontWeight: FontWeight.w400,
// //                   ),
// //                 ),
// //                 SizedBox(height: 16),
// //               ],
// //             );
// //           }).toList(),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
//
// class AnnouncementCard extends StatelessWidget {
//   final String title;
//   final String department;
//   final String dateTime;
//   final String article;
//
//   const AnnouncementCard({
//     Key? key,
//     required this.title,
//     required this.department,
//     required this.dateTime,
//     required this.article,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     print(dateTime);
//     return Container(
//       width: double.infinity,
//
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 color: Color(0xFF3F3F46),
//                 fontSize: 16,
//                 fontFamily: 'Roboto',
//                 fontWeight: FontWeight.w500,
//
//               ),
//             ),
//
//             SizedBox(height: 8),
//             Row(
//               children: [
//
//                 Text(
//                   department,
//                   style: TextStyle(
//                     color: Color(0xff0B6B94),
//                     fontSize: 12,
//                     fontFamily: 'Roboto',
//                     fontWeight: FontWeight.w400,
//
//                   ),
//                 ),
//                 SizedBox(width: 8,),
//                 Text(
//                   dateTime,
//                   style: TextStyle(
//                     color: Color(0xFFA1A1AA),
//                     fontSize: 10,
//                     fontFamily: 'Roboto',
//                     fontWeight: FontWeight.w400,
//                     height: 0,
//                   ),
//                 ),
//
//               ],
//             ),
//             SizedBox(height: 8,),
//             Divider(),
//
//
//
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Screens/AnnouncementDetail.dart';
import 'Translator.dart';

class AnnouncementCard extends StatelessWidget {
  final String image;
  final String title;
  final String department;
  final String dateTime;
  final String article;

  const AnnouncementCard({
    Key? key,
    required this.image,
    required this.title,
    required this.department,
    required this.dateTime,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    DateTime parsedDateTime = DateTime.parse(dateTime);


    String formattedDateTime = DateFormat('h:mm a d MMMM y').format(parsedDateTime);

    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailsPage(
              image: image,
              title: title,
              department: department,
              dateTime: formattedDateTime,
              article: article,),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatorWidget(
                title,
                style: TextStyle(
                  color: Color(0xFF3F3F46),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  TranslatorWidget(
                    department,
                    style: TextStyle(
                      color: Color(0xff0B6B94),
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 8,),
                  TranslatorWidget(
                    formattedDateTime,
                    style: TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 10,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8,),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
