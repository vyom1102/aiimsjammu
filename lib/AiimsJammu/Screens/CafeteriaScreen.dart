
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../../API/guestloginapi.dart';
import '../Widgets/CalculateDistance.dart';
import '../Widgets/LocationIdFunction.dart';
import '../Widgets/OpeningClosingStatus.dart';
import '../Widgets/Translator.dart';
import 'serviceInfo.dart';


class CafeteriaScreen extends StatefulWidget {
  @override
  _CafeteriaScreenState createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
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
    // _loadPharmacyServicesFromAPI();
    checkForReload();

  }

  void checkForReload(){
    if(DashboardListBox.containsKey('_services')){
      _services = DashboardListBox.get('_services');
      setState(() {
        _filteredServices = _services.where((service) => service['type'] == 'Cafeteria').toList();
        _isLoading = false;
      });
      print('atm FROM DATABASE');

    }else{
      _loadPharmacyServicesFromAPI();
      print('atm API CALL');
    }
  }
  void _loadPharmacyServicesFromAPI() async {

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
            // _filteredServices = _services;
            _filteredServices = _services.where((service) => service['type'] == 'Cafeteria').toList();
            DashboardListBox.put('_services', responseData['data']);

            _isLoading = false;
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

  final String shareText = 'Check out this awesome app!';


  @override
  Widget build(BuildContext context) {
    List specialities =
    _services.map((services) => services['type']).toSet().toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'Cafeteria',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,

          ),
        ),
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
                                    Image.network(
                                      // 'https://dev.iwayplus.in/uploads/$service['image']',
                                      'https://dev.iwayplus.in/uploads/${service['image']}',
                                      width: cardWidth,
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
                                SizedBox(height: 16),

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

        Expanded(
          child: ListView.builder(
            itemCount: 5,
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


