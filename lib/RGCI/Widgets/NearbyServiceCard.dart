// Widget _buildNearbyService(String imagePath, String name, String Location,
//     String locationId, String type,String startTime, String endTime,String accessibility,List<String> weekDays) {
//
//   return Container(
//     color: Colors.white,
//     child: GestureDetector(
//       onTap: () {
//         // PassLocationId(locationId);
//
//       },
//       child: Card(
//         shadowColor: Color(0xff000000).withOpacity(0.25),
//         color: Colors.white,
//         elevation: 1,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Color(0xFFE0E0E0), width: 1),
//           ),
//           width: 250,
//           child: Stack(children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Stack(
//                   children: [
//
//                     Image.network(
//                       'https://dev.iwayplus.in/uploads/${imagePath}',
//                       width: 250,
//                       height: 140,
//                       fit: BoxFit.cover,
//                     ),
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       // child: Container(
//                       //   height: 40,
//                       //   decoration: BoxDecoration(
//                       //     shape: BoxShape.circle,
//                       //     color: Colors.transparent.withOpacity(
//                       //         0.2),
//                       //   ),
//                       //   child: IconButton(
//                       //     disabledColor: Colors.grey,
//                       //     onPressed: () {},
//                       //     icon: Icon(
//                       //       isFavorite ? Icons.favorite : Icons.favorite_border,
//                       //       color: isFavorite ? Colors.red : null,
//                       //     ),
//                       //     color: Colors.white,
//                       //   ),
//                       // ),
//                       child: Container(
//                         // width: 73,
//                         height: 26,
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Color(0xFF05AF9A),
//                           borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(8),
//                             bottomLeft: Radius.circular(8),
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Color(0x3F000000),
//                               blurRadius: 4,
//                               offset: Offset(0, 0),
//                               spreadRadius: 0,
//                             )
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               type,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontFamily: 'Roboto',
//                                 fontWeight: FontWeight.w400,
//                                 height: 0.12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 12,
//                     ),
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontFamily: "Roboto",
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xff18181b),
//
//                       ),
//                       textAlign: TextAlign.left,
//                     ),
//
//                     if(accessibility!='NO')
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Image.asset('assets/images/accessible.png',scale: 4,),
//                       )
//                   ],
//                 ),
//                 SizedBox(
//                   height: 4,
//                 ),
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Icon(
//                       Icons.location_on_outlined,
//                       color: Color(0xFF8D8C8C),
//                       size: 16,
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Text(
//                       Location,
//                       style: const TextStyle(
//                         fontFamily: "Roboto",
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: Color(0xFF8D8C8C),
//
//                       ),
//                       textAlign: TextAlign.left,
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 4,
//                 ),
//
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 12,
//                     ),
//                     SizedBox(
//                       child: SvgPicture.asset('assets/images/routing.svg'),
//
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//
//                     FutureBuilder<double>(
//                       future: calculateDistance(locationId),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return SizedBox(
//                             width: 25,
//                             height: 25,// Adjust width as needed
//                             child: CircularProgressIndicator(),
//                           );
//                         } else if (snapshot.hasError) {
//                           return Text(
//                             'Error',
//                             style: TextStyle(color: Colors.red),
//                           );
//                         } else {
//                           return Text(
//                             '${snapshot.data!.toStringAsFixed(2)} m',
//                             style: TextStyle(
//                               color: Color(0xFF8D8C8C),
//                               fontSize: 14,
//                               fontFamily: 'Roboto',
//                               fontWeight: FontWeight.w400,
//                               height: 0.10,
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                     // Spacer(),
//                     // Icon(
//                     //   Icons.local_hospital,
//                     //   size: 16,
//                     //   color: Color(0xff6b7280),
//                     // ),
//                     // SizedBox(
//                     //   width: 4,
//                     // ),
//                     // Text(
//                     //   type,
//                     //   style: const TextStyle(
//                     //     fontFamily: "Roboto",
//                     //     fontSize: 12,
//                     //     fontWeight: FontWeight.w400,
//                     //     color: Color(0xff6b7280),
//                     //     height: 18 / 12,
//                     //   ),
//                     //   textAlign: TextAlign.left,
//                     // ),
//                     // SizedBox(
//                     //   width: 12,
//                     // )
//                   ],
//                 ),
//                 SizedBox(height: 12,),
//                 Row(
//                   children: [
//                     SizedBox(width: 12,),
//                     Container(
//                       // height: 20,
//                         child: OpeningClosingStatus(startTime: startTime, endTime: endTime,)),
//                   ],
//                 ),
//                 SizedBox(height: 5,)
//               ],
//             ),
//           ]),
//         ),
//       ),
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/RGCI/Screens/ServiceInfo.dart';

import 'CalculateDistance.dart';
import 'OpeningClosingStatus.dart';

class NearbyServiceWidget extends StatelessWidget {
  final String id;
  final String imagePath;
  final String name;
  final String location;
  final String locationId;
  final String type;
  final String startTime;
  final String endTime;
  final String accessibility;
  final String contact;
  final String about;
  final List<String> weekDays;


  const NearbyServiceWidget({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.locationId,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.accessibility,
    required this.contact,
    required this.about,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceInfo(
                id: id,
                contact: contact,
                about: about,
                imagePath: imagePath,
                name: name,
                location: location,
                accessibility: accessibility,
                locationId: locationId,
                type: type,
                startTime: startTime,
                endTime: endTime,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFE0E0E0), width: 1),
          ),
          width: 250,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        'https://dev.iwayplus.in/uploads/$imagePath',
                        width: 250,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF05AF9A),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                type,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff18181b),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      if (accessibility != 'NO')
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.asset('assets/images/accessible.png', scale: 4),
                        )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF8D8C8C),
                        size: 16,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        location,
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF8D8C8C),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      SizedBox(
                        child: SvgPicture.asset('assets/images/routing.svg'),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      FutureBuilder<double>(
                        future: calculateDistance(locationId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              width: 25,
                              height: 25, // Adjust width as needed
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error',
                              style: TextStyle(color: Colors.red),
                            );
                          } else {
                            return Text(
                              '${snapshot.data!.toStringAsFixed(2)} m',
                              style: TextStyle(
                                color: Color(0xFF8D8C8C),
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0.10,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 12),
                      Container(
                        // height: 20,
                        child: OpeningClosingStatus(startTime: startTime, endTime: endTime),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
