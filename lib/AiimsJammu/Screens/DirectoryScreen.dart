
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../API/RefreshTokenAPI.dart';
import '../../config.dart';

class HospitalDirectory extends StatefulWidget {
  const HospitalDirectory({Key? key}) : super(key: key);

  @override
  State<HospitalDirectory> createState() => _HospitalDirectoryState();
}

class _HospitalDirectoryState extends State<HospitalDirectory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Directory> directories = [];
  List<Directory> filteredDirectories = [];
  bool isLoading = true;
  String accessToken = '';
  var directoryBox = Hive.box('DashboardList');
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadDirectories();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  static String apiUrl = '${AppConfig.baseUrl}/secured/hospital/all-directory/6673e7a3b92e69bc7f4b40ae';

  Future<void> loadDirectories() async {
    var cachedData = directoryBox.get('directories');
    if (cachedData != null) {
      setState(() {
        directories = (json.decode(cachedData) as List).map((item) => Directory.fromJson(item)).toList();
        filteredDirectories = directories;
        isLoading = false;
      });
    } else {
      await fetchDirectories();
    }
  }

  Future<void> fetchDirectories() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          List<dynamic> data = responseData['data'];
          setState(() {
            directories = data.map((item) => Directory.fromJson(item)).toList();
            filteredDirectories = directories;
            isLoading = false;
          });
          directoryBox.put('directories', json.encode(data));
        }
      } else if (response.statusCode == 403) {
        String newAccessToken = await RefreshTokenAPI.refresh();
        accessToken = newAccessToken;
        fetchDirectories();
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load directories: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching directories: $e');
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredDirectories = directories
          .where((dir) => dir.name.toLowerCase().contains(query.toLowerCase()) || dir.department.toLowerCase().contains(query.toLowerCase()) || dir.contactNo.contains(query))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A4A7F),
        title: isSearching
            ? TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        )
            : const Text('Hospital Directory',style: TextStyle(color: Colors.white),),
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              isSearching = false;
              searchController.clear();
              filteredDirectories = directories;
            });
            Navigator.pop(context);
          },
        ),

        actions: !isSearching
            ? [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ),
        ]
            : null,
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Emergency'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          buildDirectoryList(filteredDirectories),
          buildDirectoryList(filteredDirectories.where((dir) => dir.name.toLowerCase().contains('emergency') || dir.department.toLowerCase().contains('emergency')).toList()),
        ],
      ),
    );
  }

  Widget buildDirectoryList(List<Directory> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return DirectoryTile(directory: items[index]);
      },
    );
  }
}

class DirectoryTile extends StatelessWidget {
  final Directory directory;

  const DirectoryTile({Key? key, required this.directory}) : super(key: key);
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  directory.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  directory.contactNo,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Colors.orange, size: 20),
              onPressed: () async {
                // final Uri phoneUri = Uri.parse('tel:${directory.contactNo}');
                // if (await canLaunchUrl(phoneUri)) {
                //   await launchUrl(phoneUri);
                // } else {
                //   print('Could not launch call');
                // }
                makePhoneCall(directory.contactNo);
              },
            ),
          ),
        ],
      ),
    );
  }
}
class Directory {
  final String id;
  final String name;
  final String contactNo;
  final String extentionNo;
  final String email;
  final String locationId;
  final String locationName;
  final String designation;
  final String department;
  final String hospitalId;

  Directory({
    required this.id,
    required this.name,
    required this.contactNo,
    required this.extentionNo,
    required this.email,
    required this.locationId,
    required this.locationName,
    required this.designation,
    required this.department,
    required this.hospitalId,
  });

  factory Directory.fromJson(Map<String, dynamic> json) {
    return Directory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      contactNo: json['contactNo'] ?? '',
      extentionNo: json['extentionNo'] ?? '',
      email: json['email'] ?? '',
      locationId: json['locationId'] ?? '',
      locationName: json['locationName'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
    );
  }
}
