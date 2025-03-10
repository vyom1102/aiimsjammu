// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// //
// // import '../../Navigation.dart';
// //
// // class Buildinglandmarks extends StatefulWidget {
// //   final String buildingName;
// //   final String buildingId;
// //   final Map<dynamic, dynamic> landmarkData;
// //
// //   const Buildinglandmarks({
// //     super.key,
// //     required this.buildingName,
// //     required this.buildingId,
// //     required this.landmarkData,
// //   });
// //
// //   @override
// //   State<Buildinglandmarks> createState() => _BuildinglandmarksState();
// // }
// //
// // class _BuildinglandmarksState extends State<Buildinglandmarks> {
// //   String selectedDepartment = 'Departments';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     print("idsss ${widget.buildingId}");
// //     List<String> buildingIds = widget.buildingId.split(',');
// //     print("Landmark Data: ${widget.landmarkData}");
// //   }
// //
// //   final Map<String, String> buildingNames = {
// //     "66794105b80a6778c53c4856": "OPD BLOCK",
// //     "6798c8fa96af63c3e8277db2": "DIAGNOSTIC BLOCK",
// //     "6798c81c96af63c3e826add3": "PRIVATE WARD 1",
// //     '6798c99e96af63c3e828203d': 'PRIVATE WARD 2',
// //     "6798c6df96af63c3e82659ec": "EMERGENCY BLOCK",
// //   };
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Filter landmarks to only show those with element-type = Rooms
// //     List<dynamic> roomLandmarks = [];
// //     if (widget.landmarkData['landmarks'] != null) {
// //       roomLandmarks = (widget.landmarkData['landmarks'] as List<dynamic>)
// //           .where((landmark) =>
// //       landmark['properties'] != null &&
// //           landmark['element']['type'] == 'Rooms')
// //           .toList();
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Colors.white),
// //           onPressed: () => Navigator.of(context).pop(),
// //         ),
// //         foregroundColor: Colors.white,
// //         backgroundColor: const Color(0xFF003666),
// //         title: Text(
// //           '${widget.buildingName} Services',
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 20,
// //             fontFamily: 'Roboto',
// //             fontWeight: FontWeight.w400,
// //           ),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //         child: Column(
// //           children: [
// //             Container(
// //               margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24),
// //                 border: Border.all(color: Colors.grey[300]!),
// //               ),
// //               child: DropdownButtonHideUnderline(
// //                 child: DropdownButton<String>(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                   borderRadius: BorderRadius.circular(24),
// //                   icon: const Icon(Icons.arrow_drop_down),
// //                   isExpanded: true,
// //                   value: selectedDepartment,
// //                   onChanged: (String? newValue) {
// //                     if (newValue != null) {
// //                       setState(() {
// //                         selectedDepartment = newValue;
// //                       });
// //                     }
// //                   },
// //                   items: <String>['Departments', 'Cardiology', 'Neurology', 'Orthopedics']
// //                       .map<DropdownMenuItem<String>>((String value) {
// //                     return DropdownMenuItem<String>(
// //                       value: value,
// //                       child: Text(value),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: roomLandmarks.length,
// //                 itemBuilder: (context, index) {
// //                   final landmark = roomLandmarks[index];
// //                   return Container(
// //                     margin: const EdgeInsets.only(bottom: 12.0),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(16.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               // Text(
// //                               //   landmark['name'] ?? 'Unknown OPD',
// //                               //   style: const TextStyle(
// //                               //     fontSize: 18,
// //                               //     fontWeight: FontWeight.w500,
// //                               //   ),
// //                               // ),
// //                               Text(
// //                                 (landmark['name'] ?? 'Unknown Landmark').length > 25
// //                                     ? (landmark['name'] as String).substring(0, 25) + '...'
// //                                     : landmark['name'] ?? 'Unknown Landmark',
// //                                 style: const TextStyle(
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               InkWell(
// //                                 onTap: (){
// //                                   Navigator.push(
// //                                     context,
// //                                     MaterialPageRoute(
// //                                       builder: (context) => Navigation(directLandID: landmark['properties']['polyId'],),
// //                                     ),
// //                                   );
// //                                 },
// //                                 child: Container(
// //                                   decoration: BoxDecoration(
// //                                     color: Colors.white,
// //
// //                                     borderRadius: BorderRadius.circular(50),
// //                                     border: Border.all(color: Color(0xFFE6E6E6),width: 1)
// //                                   ),
// //                                   padding: const EdgeInsets.all(8),
// //                                   child: SvgPicture.asset('assets/images/assistant_direction.svg')
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 12),
// //                           Row(
// //                             children: [
// //                                Icon(Icons.calendar_today, size: 16, color: Colors.blue[900]),
// //                               const SizedBox(width: 8),
// //                               Text(
// //                                 landmark['properties']['timings']??
// //                                 'Monday - Saturday | 9 AM - 5 PM',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   color: Colors.grey[800],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Row(
// //                             children: [
// //                               const Icon(Icons.location_on, color: Colors.blueGrey),
// //                               const SizedBox(width: 5),
// //                               Expanded(
// //                                 child: Text(
// //                                   buildingNames[landmark['building_ID']] ?? 'No Location Info',
// //                                   style: const TextStyle(fontSize: 14, color: Colors.black54),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 8),
// //                           const Text(
// //                             'Open Now',
// //                             style: TextStyle(
// //                               color: Colors.green,
// //                               fontWeight: FontWeight.w500,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../Navigation.dart';
//
// class Buildinglandmarks extends StatefulWidget {
//   final String buildingName;
//   final String buildingId;
//   final Map<dynamic, dynamic> landmarkData;
//
//   const Buildinglandmarks({
//     super.key,
//     required this.buildingName,
//     required this.buildingId,
//     required this.landmarkData,
//   });
//
//   @override
//   State<Buildinglandmarks> createState() => _BuildinglandmarksState();
// }
//
// class _BuildinglandmarksState extends State<Buildinglandmarks> {
//   String selectedDepartment = 'All Departments';
//   List<String> departments = ['All Departments'];
//   List<dynamic> roomLandmarks = [];
//   List<dynamic> filteredLandmarks = [];
//   String searchQuery = '';
//   TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     print("idsss ${widget.buildingId}");
//     List<String> buildingIds = widget.buildingId.split(',');
//     print("Landmark Data: ${widget.landmarkData}");
//
//     // Filter landmarks to only show those with element-type = Rooms
//     if (widget.landmarkData['landmarks'] != null) {
//       roomLandmarks = (widget.landmarkData['landmarks'] as List<dynamic>)
//           .where((landmark) =>
//       landmark['properties'] != null &&
//           landmark['element']['type'] == 'Rooms')
//           .toList();
//
//       // Get unique department names
//       Set<String> uniqueDepartments = {'All Departments'};
//       for (var landmark in roomLandmarks) {
//         if (landmark['properties'] != null &&
//             landmark['properties']['assignedTo'] != null &&
//             landmark['properties']['assignedTo'].toString().isNotEmpty) {
//           uniqueDepartments.add(landmark['properties']['assignedTo'].toString());
//         }
//       }
//       departments = uniqueDepartments.toList();
//
//       // Initialize filtered landmarks
//       filteredLandmarks = List.from(roomLandmarks);
//     }
//   }
//
//   final Map<String, String> buildingNames = {
//     "66794105b80a6778c53c4856": "OPD BLOCK",
//     "6798c8fa96af63c3e8277db2": "DIAGNOSTIC BLOCK",
//     "6798c81c96af63c3e826add3": "PRIVATE WARD 1",
//     '6798c99e96af63c3e828203d': 'PRIVATE WARD 2',
//     "6798c6df96af63c3e82659ec": "EMERGENCY BLOCK",
//   };
//
//   void filterLandmarks() {
//     setState(() {
//       if (selectedDepartment == 'All Departments') {
//         filteredLandmarks = roomLandmarks;
//       } else {
//         filteredLandmarks = roomLandmarks
//             .where((landmark) =>
//         landmark['properties'] != null &&
//             landmark['properties']['assignedTo'] != null &&
//             landmark['properties']['assignedTo'].toString() == selectedDepartment)
//             .toList();
//       }
//
//       // Apply search filter if search query exists
//       if (searchQuery.isNotEmpty) {
//         filteredLandmarks = filteredLandmarks
//             .where((landmark) =>
//         landmark['name'] != null &&
//             landmark['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
//             .toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         foregroundColor: Colors.white,
//         backgroundColor: const Color(0xFF003666),
//         title: Text(
//           '${widget.buildingName} Services',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.white),
//             onPressed: () {
//               showSearch(
//                 context: context,
//                 delegate: LandmarkSearchDelegate(
//                   roomLandmarks: roomLandmarks,
//                   buildingNames: buildingNames,
//                   selectedDepartment: selectedDepartment,
//                   onSelectLandmark: (landmark) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Navigation(directLandID: landmark['properties']['polyId']),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   borderRadius: BorderRadius.circular(24),
//                   icon: const Icon(Icons.arrow_drop_down),
//                   isExpanded: true,
//                   value: selectedDepartment,
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         selectedDepartment = newValue;
//                         filterLandmarks();
//                       });
//                     }
//                   },
//                   items: departments
//                       .map<DropdownMenuItem<String>>((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search landmarks...',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value;
//                     filterLandmarks();
//                   });
//                 },
//               ),
//             ),
//             Expanded(
//               child: filteredLandmarks.isEmpty
//                   ? const Center(
//                 child: Text(
//                   'No landmarks found',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               )
//                   : ListView.builder(
//                 itemCount: filteredLandmarks.length,
//                 itemBuilder: (context, index) {
//                   final landmark = filteredLandmarks[index];
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 12.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   (landmark['name'] ?? 'Unknown Landmark').length > 25
//                                       ? (landmark['name'] as String).substring(0, 25) + '...'
//                                       : landmark['name'] ?? 'Unknown Landmark',
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => Navigation(directLandID: landmark['properties']['polyId']),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(50),
//                                     border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
//                                   ),
//                                   padding: const EdgeInsets.all(8),
//                                   child: SvgPicture.asset('assets/images/assistant_direction.svg'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Icon(Icons.calendar_today, size: 16, color: Colors.blue[900]),
//                               const SizedBox(width: 8),
//                               Text(
//                                 landmark['properties']['timings'] ??
//                                     'Monday - Saturday | 9 AM - 5 PM',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on, color: Colors.blueGrey),
//                               const SizedBox(width: 5),
//                               Expanded(
//                                 child: Text(
//                                   buildingNames[landmark['building_ID']] ?? 'No Location Info',
//                                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (landmark['properties'] != null && landmark['properties']['assignedTo'] != null)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.medical_services, size: 16, color: Colors.redAccent),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     landmark['properties']['assignedTo'],
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.black54,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Open Now',
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Search delegate for landmark search
// class LandmarkSearchDelegate extends SearchDelegate<dynamic> {
//   final List<dynamic> roomLandmarks;
//   final Map<String, String> buildingNames;
//   final String selectedDepartment;
//   final Function(dynamic) onSelectLandmark;
//
//   LandmarkSearchDelegate({
//     required this.roomLandmarks,
//     required this.buildingNames,
//     required this.selectedDepartment,
//     required this.onSelectLandmark,
//   });
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     return buildSearchResults();
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return buildSearchResults();
//   }
//
//   Widget buildSearchResults() {
//     if (query.isEmpty) {
//       return const Center(
//         child: Text("Type to search landmarks"),
//       );
//     }
//
//     List<dynamic> filteredResults = roomLandmarks
//         .where((landmark) =>
//     landmark['name'] != null &&
//         landmark['name'].toString().toLowerCase().contains(query.toLowerCase()))
//         .toList();
//
//     // Apply department filter if a specific department is selected
//     if (selectedDepartment != 'All Departments') {
//       filteredResults = filteredResults
//           .where((landmark) =>
//       landmark['properties'] != null &&
//           landmark['properties']['assignedTo'] != null &&
//           landmark['properties']['assignedTo'].toString() == selectedDepartment)
//           .toList();
//     }
//
//     if (filteredResults.isEmpty) {
//       return const Center(
//         child: Text("No landmarks found"),
//       );
//     }
//
//     return ListView.builder(
//       itemCount: filteredResults.length,
//       itemBuilder: (context, index) {
//         final landmark = filteredResults[index];
//         return ListTile(
//           title: Text(landmark['name'] ?? 'Unknown Landmark'),
//           subtitle: Text(
//             buildingNames[landmark['building_ID']] ?? 'No Location Info',
//           ),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//           onTap: () {
//             onSelectLandmark(landmark);
//             close(context, landmark);
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Navigation.dart';

class Buildinglandmarks extends StatefulWidget {
  final String buildingName;
  final String buildingId;
  final Map<dynamic, dynamic> landmarkData;

  const Buildinglandmarks({
    super.key,
    required this.buildingName,
    required this.buildingId,
    required this.landmarkData,
  });

  @override
  State<Buildinglandmarks> createState() => _BuildinglandmarksState();
}

class _BuildinglandmarksState extends State<Buildinglandmarks> {
  String selectedDepartment = 'All Departments';
  List<String> departments = ['All Departments'];
  List<dynamic> roomLandmarks = [];
  List<dynamic> filteredLandmarks = [];
  bool isSearching = false;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("idsss ${widget.buildingId}");
    List<String> buildingIds = widget.buildingId.split(',');
    print("Landmark Data: ${widget.landmarkData}");

    // Filter landmarks to only show those with element-type = Rooms
    if (widget.landmarkData['landmarks'] != null) {
      roomLandmarks = (widget.landmarkData['landmarks'] as List<dynamic>)
          .where((landmark) =>
      landmark['properties'] != null &&
          landmark['element']['type'] == 'Rooms')
          .toList();

      // Get unique department names
      Set<String> uniqueDepartments = {'All Departments'};
      for (var landmark in roomLandmarks) {
        if (landmark['properties'] != null &&
            landmark['properties']['assignedTo'] != null &&
            landmark['properties']['assignedTo'].toString().isNotEmpty) {
          uniqueDepartments.add(landmark['properties']['assignedTo'].toString());
        }
      }
      departments = uniqueDepartments.toList();

      // Initialize filtered landmarks
      filteredLandmarks = List.from(roomLandmarks);
    }
  }

  final Map<String, String> buildingNames = {
    "66794105b80a6778c53c4856": "OPD BLOCK",
    "6798c8fa96af63c3e8277db2": "DIAGNOSTIC BLOCK",
    "6798c81c96af63c3e826add3": "PRIVATE WARD 1",
    '6798c99e96af63c3e828203d': 'PRIVATE WARD 2',
    "6798c6df96af63c3e82659ec": "EMERGENCY BLOCK",
  };

  void filterLandmarks() {
    setState(() {
      if (selectedDepartment == 'All Departments') {
        filteredLandmarks = roomLandmarks;
      } else {
        filteredLandmarks = roomLandmarks
            .where((landmark) =>
        landmark['properties'] != null &&
            landmark['properties']['assignedTo'] != null &&
            landmark['properties']['assignedTo'].toString() == selectedDepartment)
            .toList();
      }

      // Apply search filter if search query exists
      if (searchQuery.isNotEmpty) {
        filteredLandmarks = filteredLandmarks
            .where((landmark) =>
        landmark['name'] != null &&
            landmark['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search landmarks...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
          filterLandmarks();
        });
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            setState(() {
              isSearching = false;
              searchQuery = '';
              searchController.clear();
              filterLandmarks();
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              isSearching = true;
            });
          },
        ),
      ];
    }
  }

  Widget _buildAppBarTitle() {
    if (isSearching) {
      return _buildSearchField();
    } else {
      return Text(
        '${widget.buildingName} Services',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (isSearching) {
              setState(() {
                isSearching = false;
                searchQuery = '';
                searchController.clear();
                filterLandmarks();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003666),
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  borderRadius: BorderRadius.circular(24),
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  value: selectedDepartment,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedDepartment = newValue;
                        filterLandmarks();
                      });
                    }
                  },
                  items: departments
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: filteredLandmarks.isEmpty
                  ? const Center(
                child: Text(
                  'No landmarks found',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: filteredLandmarks.length,
                itemBuilder: (context, index) {
                  final landmark = filteredLandmarks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  (landmark['name'] ?? 'Unknown Landmark').length > 25
                                      ? (landmark['name'] as String).substring(0, 25) + '...'
                                      : landmark['name'] ?? 'Unknown Landmark',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Navigation(directLandID: landmark['properties']['polyId']),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset('assets/images/assistant_direction.svg'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.blue[900]),
                              const SizedBox(width: 8),
                              Text(
                                landmark['properties']['timings'] ??
                                    'Monday - Saturday | 9 AM - 5 PM',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                               Icon(Icons.location_on, size: 16, color: Colors.blue[900]),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  buildingNames[landmark['building_ID']] ?? 'No Location Info',
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                          // if (landmark['properties'] != null && landmark['properties']['assignedTo'] != null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 8.0),
                          //     child: Row(
                          //       children: [
                          //         const Icon(Icons.medical_services, size: 16, color: Colors.redAccent),
                          //         const SizedBox(width: 8),
                          //         Text(
                          //           landmark['properties']['assignedTo'],
                          //           style: const TextStyle(
                          //             fontSize: 14,
                          //             color: Colors.black54,
                          //             fontWeight: FontWeight.w500,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          const SizedBox(height: 8),
                          const Text(
                            'Open Now',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}