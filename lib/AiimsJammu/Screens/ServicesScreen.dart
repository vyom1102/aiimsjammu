
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import '../Widgets/Translator.dart';
import '/AiimsJammu/Data/ServicesDemoData.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Data/DoctorDemoData.dart';
import 'package:http/http.dart' as http;
import '../../API/guestloginapi.dart';
import '../Widgets/CalculateDistance.dart';
import '../Widgets/LocationIdFunction.dart';
import '../Widgets/OpeningClosingStatus.dart';
import 'serviceInfo.dart';
class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<dynamic> _services = [];
  List<dynamic> _filteredServices= [];
  List<String> _selectedServices = [];
  bool _isLoading = true;
  String token = "";
  var DashboardListBox = Hive.box('DashboardList');
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _loadServices();
    // _loadServicesFromAPI();
    checkForReload();

  }
  void checkForReload(){
    if(DashboardListBox.containsKey('_services')){
      _services = DashboardListBox.get('_services');
      setState(() {
        _filteredServices = _services;
        _isLoading = false;
      });
      print('_loadServicesFromAPI FROM DATABASE');

    }else{
      _loadServicesFromAPI();
      print('_loadServicesFromAPI API CALL');
    }
  }

  void _loadServicesFromAPI() async {

    try {
      await guestApi().guestlogin().then((value){
        if(value.accessToken != null){
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(

        Uri.parse("https://dev.iwayplus.in/secured/hospital/all-services/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
        },);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            _services = responseData['data'];
            _filteredServices = _services;
            _isLoading = false;
            DashboardListBox.put('_services', responseData['data']);

          });
        } else {
          throw Exception('Response data does not contain the expected list of doctors under the "ServiceData" key');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }
  // void _loadServices() {
  //   Future.delayed(Duration(seconds: 2), () {
  //     setState(() {
  //       _services = jsonDecode(getServices());
  //       _filteredServices = _services;
  //       _isLoading = false; // Set loading to false after loading is done
  //     });
  //   });
  // }

  void _filterServices() {
    setState(() {
      _filteredServices = _selectedServices.isNotEmpty
          ? _services
          .where((services) =>
          _selectedServices.contains(services['type']))
          .toList()
          : _services;
    });
  }
  final String shareText = 'Check out this awesome app!';

  void _searchServices(String query) {
    setState(() {
      _filteredServices = _services
          .where((doctor) =>
      doctor['name'].toLowerCase().contains(query.toLowerCase()) ||
          doctor['speciality']
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          doctor['location'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }
  Future<void> _shareContent(String text) async {
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) {
    List specialities =
    _services.map((services) => services['type']).toSet().toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEBEBEB),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade400,

      ),
      body:_isLoading
      ? _buildShimmerLoading()
          :Column(
        children: [

          Semantics(
            label: "Services",
            header: true,
            child: SizedBox(

              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: specialities.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 4),
                      child: FilterChip(
                        disabledColor: Colors.white,
                        label: TranslatorWidget(
                          'All',
                          style: TextStyle(
                            color: _selectedServices.isEmpty ? Colors.white : Color(0xFF1C2A3A),
                          ),
                        ),
                        showCheckmark: false,
                        selectedColor: Color(0xFF1C2A3A),
                        backgroundColor: Colors.white,
                        selected: _selectedServices.isEmpty,
                        // backgroundColor: _selectedSpecialities.isEmpty ? Color(0xFF1C2A3A) : Colors.transparent,
                        onSelected: (value) {
                          setState(() {
                            _selectedServices.clear();
                            _filterServices();
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  } else {
                    final speciality = specialities[index - 1];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FilterChip(
                        label: TranslatorWidget(
                          speciality,
                          style: TextStyle(
                            color: _selectedServices.contains(speciality) ? Colors.white : Color(0xFF1C2A3A),
                          ),
                        ),
                        selectedColor: Color(0xFF1C2A3A),

                        showCheckmark: false,
                        selected: _selectedServices.contains(speciality),
                        // backgroundColor: _selectedSpecialities.contains(speciality) ? Color(0xFF1C2A3A) : Colors.transparent,
                        onSelected: (value) {
                          setState(() {
                            if (value) {

                              _selectedServices.add(speciality);

                            } else {
                              _selectedServices.remove(speciality);
                            }
                            _filterServices();
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
            child: Row(
              children: [
                Semantics(
                  header:true,
                  child: Container(
                    height: 16,
                    child: TranslatorWidget(
                      'Nearby Services',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.09,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final cardWidth = screenWidth * 0.9;
                final cardHeight =
                    screenHeight * 0.35;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GestureDetector(
                    // onTap:() {PassLocationId(service['locationId']);},
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceInfo(
                            id: service['_id'],
                            imagePath: service['image'],
                            name: service['name'],
                            location:service['locationName'],
                            contact: service['contact'],
                            about: service['about'],
                            accessibility: service["accessibility"],
                            locationId: service['locationId'],
                            type: service['type'],
                            startTime: service['startTime'],
                            endTime: service['endTime'],
                          ),
                        ),
                      );
                    },

                    child:  Card(
                      shadowColor: Color(0xff000000).withOpacity(0.25),
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                                    // Image.network(
                                    //   // 'https://dev.iwayplus.in/uploads/$service['image']',
                                    //   'https://dev.iwayplus.in/uploads/${service['image']}',
                                    //   width: cardWidth,
                                    //   height: 140,
                                    //   fit: BoxFit.cover,
                                    // ),
                                    CachedNetworkImage(
                                      imageUrl: 'https://dev.iwayplus.in/uploads/${service['image']}',
                                      width: cardWidth,
                                      height: 140,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 250,
                                        height: 140,
                                        color: Colors.grey[200],
                                        child:Image.asset(
                                          'assets/images/placeholder.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                            topRight: Radius.circular(8),
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
                                            TranslatorWidget(
                                              service['type'],
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
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                    ),
                                    TranslatorWidget(
                                      service['name'],
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff18181b),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    if (service['accessibility'] != 'NO')
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Image.asset('assets/images/accessible.png', scale: 4),
                                      )
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
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
                                    TranslatorWidget(
                                      service['locationName'],
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
                                  height: 4,
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
                                      future: calculateDistance(service['locationId']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return SizedBox(
                                            width: 25,
                                            height: 25, // Adjust width as needed
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return TranslatorWidget(
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
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Container(
                                      // height: 20,
                                      child: OpeningClosingStatus(startTime: service['startTime'], endTime: service['endTime']),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Shimmer effect for speciality filters...
        SizedBox(height: 10,),
        SizedBox(
          height: 30,
          child: Shimmer.fromColors(
            baseColor: Color(0xffD9D9D9).withOpacity(0.43),
            highlightColor: Colors.grey[100]!,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(

                      width: index==0?50:100,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
              child: Shimmer.fromColors(
                baseColor: Color(0xffD9D9D9).withOpacity(0.43),
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 100,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        // Shimmer effect for displaying list of services...
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Adjust according to your shimmer loading
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Color(0xffD9D9D9).withOpacity(0.43),
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


