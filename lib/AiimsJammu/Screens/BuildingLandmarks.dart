
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/Translator.dart';
import 'package:shimmer/shimmer.dart';

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
  String selectedFilter = 'All';
  List<String> filterOptions = ['All'];
  List<dynamic> roomLandmarks = [];
  List<dynamic> filteredLandmarks = [];
  bool isSearching = false;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  List<String> uniqueBuildingIds = [];
  bool isLoading = true;

  final Map<String, String> buildingNames = {
    "66794105b80a6778c53c4856": "OPD BLOCK",
    "6798c8fa96af63c3e8277db2": "DIAGNOSTIC BLOCK",
    "6798c81c96af63c3e826add3": "PRIVATE WARD 1",
    '6798c99e96af63c3e828203d': 'PRIVATE WARD 2',
    "6798c6df96af63c3e82659ec": "EMERGENCY BLOCK",
    "679ca3fde7e7001d98497002": "AYUSH BLOCK"
  };

  @override
  void initState() {
    super.initState();
    print("idsss ${widget.buildingId}");
    List<String> buildingIds = widget.buildingId.split(',');
    print("Landmark Data: ${widget.landmarkData}");

    // Load data with a slight delay to show shimmer effect
    loadData();
  }

  Future<void> loadData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter landmarks to only show those with element-type = Rooms
    if (widget.landmarkData['landmarks'] != null) {
      roomLandmarks = (widget.landmarkData['landmarks'] as List<dynamic>)
          .where((landmark) =>
      landmark['properties'] != null &&
          landmark['element']['type'] == 'Rooms')
          .toList();

      // Get unique building IDs from landmarks
      for (var landmark in roomLandmarks) {
        if (landmark['building_ID'] != null) {
          uniqueBuildingIds.add(landmark['building_ID'].toString());
        }
      }

      // Initialize filter options with "All"
      Set<String> uniqueFilters = {'All'};

      // Add department filters
      for (var landmark in roomLandmarks) {
        if (landmark['properties'] != null &&
            landmark['properties']['assignedTo'] != null &&
            landmark['properties']['assignedTo'].toString().isNotEmpty) {
          if (landmark['properties']['assignedTo'] != "null")
            uniqueFilters.add("Dept: ${landmark['properties']['assignedTo']}");
        }
      }

      // Add building name filters if multiple buildings present
      if (uniqueBuildingIds.length > 1) {
        for (var buildingId in uniqueBuildingIds.toSet()) {
          if (buildingNames.containsKey(buildingId)) {
            uniqueFilters.add("Building: ${buildingNames[buildingId]!}");
          }
        }
      }

      // Convert to list and sort (keeping "All" at the top)
      filterOptions = uniqueFilters.toList();
      filterOptions.sort((a, b) {
        if (a == 'All') return -1;
        if (b == 'All') return 1;

        // Sort by type (Building first, then Department)
        bool aIsBuilding = a.startsWith('Building:');
        bool bIsBuilding = b.startsWith('Building:');

        if (aIsBuilding && !bIsBuilding) return -1;
        if (!aIsBuilding && bIsBuilding) return 1;

        return a.compareTo(b);
      });

      // Initialize filtered landmarks
      filteredLandmarks = List.from(roomLandmarks);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterLandmarks() {
    setState(() {
      if (selectedFilter == 'All') {
        filteredLandmarks = roomLandmarks;
      } else if (selectedFilter.startsWith('Dept:')) {
        // Filter by department
        String department = selectedFilter.substring(6); // Remove 'Dept: ' prefix
        filteredLandmarks = roomLandmarks
            .where((landmark) =>
        landmark['properties'] != null &&
            landmark['properties']['assignedTo'] != null &&
            landmark['properties']['assignedTo'].toString() == department)
            .toList();
      } else if (selectedFilter.startsWith('Building:')) {
        // Filter by building
        String buildingName = selectedFilter.substring(10); // Remove 'Building: ' prefix

        // Get building ID from name
        String? selectedBuildingId;
        buildingNames.forEach((key, value) {
          if (value == buildingName) {
            selectedBuildingId = key;
          }
        });

        if (selectedBuildingId != null) {
          filteredLandmarks = roomLandmarks
              .where((landmark) =>
          landmark['building_ID'] != null &&
              landmark['building_ID'].toString() == selectedBuildingId)
              .toList();
        }
      }

      // Apply search filter if search query exists
      if (searchQuery.isNotEmpty) {
        filteredLandmarks = filteredLandmarks
            .where((landmark) =>
        landmark['name'] != null &&
            landmark['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
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
      return TranslatorWidget(
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

  Widget _buildShimmerFilter() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
      ),
      height: 48,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 220,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 180,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandmarkList() {
    if (isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => _buildShimmerCard(),
      );
    } else if (filteredLandmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            TranslatorWidget(
              'No landmarks found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: filteredLandmarks.length,
        itemBuilder: (context, index) {
          final landmark = filteredLandmarks[index];
          final polyId = landmark['properties']['polyId'] ?? landmark["_id"];
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
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
                        child: TranslatorWidget(
                          (landmark['name'] ?? 'Unknown Landmark').length > 25
                              ? (landmark['name'] as String).substring(0, 25) +
                              '...'
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
                              builder: (context) =>
                                  Navigation(directLandID: polyId),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color: const Color(0xFFE6E6E6), width: 1),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SvgPicture.asset(
                              'assets/images/assistant_direction.svg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.blue[900]),
                      const SizedBox(width: 8),
                      TranslatorWidget(
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
                        child: TranslatorWidget(
                          buildingNames[landmark['building_ID']] ??
                              'No Location Info',
                          style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TranslatorWidget(
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await loadData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Combined filter dropdown or shimmer placeholder
              isLoading
                  ? _buildShimmerFilter()
                  : Container(
                margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16.0),
                    borderRadius: BorderRadius.circular(24),
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    value: selectedFilter,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedFilter = newValue;
                          filterLandmarks();
                        });
                      }
                    },
                    items: filterOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      // Add appropriate icons based on filter type
                      Widget leading;
                      if (value.startsWith('Building:')) {
                        leading = Icon(Icons.apartment,
                            size: 16, color: Colors.blue[900]);
                      } else if (value.startsWith('Dept:')) {
                        leading = Icon(Icons.medical_services,
                            size: 16, color: Colors.blue[900]);
                      } else {
                        leading = Icon(Icons.filter_list,
                            size: 16, color: Colors.blue[900]);
                      }

                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            leading,
                            const SizedBox(width: 8),
                            Expanded(
                              child: TranslatorWidget(value),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(child: _buildLandmarkList()),
            ],
          ),
        ),
      ),
    );
  }
}