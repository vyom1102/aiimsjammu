// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import '../../APIMODELS/FingerPrintData.dart';
// import '../API/SubEventsAPI.dart';
// import 'package:intl/intl.dart';
//
//
// class TourDetailScreen extends StatefulWidget {
//   final List<String> eventIds;
//
//   const TourDetailScreen({Key? key, required this.eventIds}) : super(key: key);
//
//   @override
//   _TourDetailScreenState createState() => _TourDetailScreenState();
// }
//
// class _TourDetailScreenState extends State<TourDetailScreen> {
//   late Future<List<Data>> _futureEvents;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureEvents = _fetchEvents();
//   }
//
//   String formatDate(String dateString) {
//     // Parse the input string
//     final DateTime date = DateTime.parse(dateString);
//
//     // Format it to "08 Oct"
//     final String formatted = DateFormat('dd MMM').format(date);
//
//     return formatted;
//   }
//
//   Future<List<Data>> _fetchEvents() async {
//     try {
//       final api = Subeventsapi();
//       final subEventsModel = await api.fetchSubEvents();
//       final allEvents = subEventsModel.data ?? [];
//
//       // Filter the events by eventIds passed from tour card
//       final filteredEvents = await allEvents
//           .where((event) => widget.eventIds.contains(event.sId))
//           .toList();
//
//       filteredEvents.sort((a, b) {
//         final aTimeUtc = DateTime.tryParse(a.startTime ?? '');
//         final bTimeUtc = DateTime.tryParse(b.startTime ?? '');
//         print("aTimeUtc $aTimeUtc $bTimeUtc");
//
//         if (aTimeUtc == null || bTimeUtc == null) return 0;
//
//         // Convert both to local (IST)
//         final aTimeLocal = aTimeUtc.toLocal();
//         final bTimeLocal = bTimeUtc.toLocal();
//
//         return aTimeLocal.compareTo(bTimeLocal);
//       });
//
//       print("filteredEvents $filteredEvents");
//       return filteredEvents;
//     } catch (e) {
//       print('Error fetching events: $e');
//       return [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: const CupertinoNavigationBar(
//         backgroundColor: CupertinoColors.white, // white background
//         middle: Text("Tour itinerary"),
//       ),
//       child: SafeArea(
//         child: FutureBuilder<List<Data>>(
//           future: _futureEvents,
//           builder: (context, snapshot) {
//             snapshot.data == null;
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CupertinoActivityIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child:
//               Container(
//                 padding: EdgeInsets.all(20),
//                 child: Text(
//                   "Looks like we’re having a little network hiccup..",
//                   style: TextStyle(
//                       color: CupertinoColors.black,
//                       decoration: TextDecoration.none,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: 'PT_Sans',
//                       fontSize: 24
//                   ),
//                 ),
//               )
//
//               );
//             } else if (snapshot.data == null || !snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                 child:
//                 Container(
//                   padding: EdgeInsets.all(20),
//                   child: Text("Looks like we’re having a little network hiccup!!",
//                   style: TextStyle(
//                       color: CupertinoColors.black,
//                       decoration: TextDecoration.none,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: 'PT_Sans',
//                       fontSize: 24
//                   ),
//                                 ),
//                 ),
//               );
//             }
//             final events = snapshot.data!;
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: events.length,
//                     itemBuilder: (context, index) {
//                       final event = events[index];
//                       final isLast = index == events.length - 1;
//                       print("event.startTime ${event.startTime}");
//                       print("event.end ${event.endTime}");
//                       DateTime startDateTime = DateTime.parse(event.startTime!).toLocal();
//                       DateTime endDateTime = DateTime.parse(event.endTime!).toLocal();
//
//                       // Format to 12-hour time with AM/PM
//                       String formattedStart = DateFormat('hh:mm a').format(startDateTime);
//                       String formattedEnd = DateFormat('hh:mm a').format(endDateTime);
//                       String formattedDate = DateFormat('EEE, dd MMM yyyy').format(startDateTime);
//
//
//                       print('Start: $formattedStart'); // e.g., Start: 09:00 AM (for IST)
//                       print('End: $formattedEnd');
//                       print('formattedDate: $formattedDate');
//                       return GestureDetector(
//                         onTap: (){
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => EventDescriptionPage(eventId: event.sId!)
//                             ),
//                           );
//                         },
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     left: 10,
//                                     top: 5,
//                                     bottom: 0,
//                                     child: !isLast
//                                         ? Container(
//                                       width: 3,
//                                       decoration: BoxDecoration(
//                                         color: Color(0xFF8f3ca2).withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(2),
//                                       ),
//                                     )
//                                         : Container(),
//                                   ),
//                                   Positioned(
//                                     left: 1,
//                                     child: Container(
//                                       width: 22,
//                                       height: 22,
//                                       decoration: BoxDecoration(
//                                         color: Color(0xFF66157b),
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: CupertinoColors.systemGrey6,
//                                           width: 3,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//
//                                   Container(
//                                     padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
//                                     margin: const EdgeInsets.only(left: 25, top: 0),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         // Text(
//                                         //   "${formattedStart} - $formattedEnd",
//                                         //   maxLines: 2,
//                                         //   overflow: TextOverflow.ellipsis,
//                                         //   style: const TextStyle(
//                                         //     decoration: TextDecoration.none,
//                                         //     fontWeight: FontWeight.w400,
//                                         //     fontSize: 15,
//                                         //     fontFamily: 'PT_Sans',
//                                         //     color: Color(0xFF66157b),
//                                         //   ),
//                                         // ),
//                                         formattedStart != ""?Semantics(
//                                           label:"${formattedStart} $formattedDate}",
//                                           child: Text(
//                                             "${formattedStart} - ${formattedDate}",
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                               decoration: TextDecoration.none,
//                                               fontWeight: FontWeight.w400,
//                                               fontSize: 15,
//                                               fontFamily: 'PT_Sans',
//                                               color: Color(0xFF66157b),
//                                             ),
//                                           ),
//                                         ):Container(),
//                                         const SizedBox(height: 6),
//                                         Semantics(
//                                           label: "${event.title ?? "Untitled Event"}",
//                                           child: Text(
//                                             event.title ?? "Untitled Event",
//                                             style: const TextStyle(
//                                               decoration: TextDecoration.none,
//                                               fontWeight: FontWeight.w400,
//                                               fontSize: 23,
//                                               fontFamily: 'PT_Sans',
//                                               color: CupertinoColors.black,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Semantics(
//                                           label: "${event.description?? "No description available."}",
//                                           child: Text(
//                                             event.description ?? "No description available.",
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                               decoration: TextDecoration.none,
//                                               fontWeight: FontWeight.w400,
//                                               fontSize: 17,
//                                               fontFamily: 'PT_Sans',
//                                               color: CupertinoColors.black,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 // 🔹 Proceed Button
//                 // Padding(
//                 //   padding: const EdgeInsets.all(16.0),
//                 //   child: SizedBox(
//                 //     width: double.infinity,
//                 //     height: 50,
//                 //     child: CupertinoButton.filled(
//                 //       focusColor: const Color(0xFF66157b),
//                 //       child: Row(
//                 //         mainAxisAlignment: MainAxisAlignment.center, // center content
//                 //         children: const [
//                 //           Text(
//                 //             "View on Map",
//                 //             style: TextStyle(
//                 //               fontSize: 18,
//                 //               fontWeight: FontWeight.w500,
//                 //               color: CupertinoColors.white,
//                 //             ),
//                 //           ),
//                 //           SizedBox(width: 8), // spacing between text and icon
//                 //           Icon(
//                 //             CupertinoIcons.map,
//                 //             color: CupertinoColors.white,
//                 //             size: 20,
//                 //           ),
//                 //         ],
//                 //       ),
//                 //       onPressed: () {
//                 //         print("View on Map button pressed");
//                 //       },
//                 //     ),
//                 //   ),
//                 // ),
//
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
