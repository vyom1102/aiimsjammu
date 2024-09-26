
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
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

class OtherServiceScreen extends StatefulWidget {
  @override
  _OtherServiceScreenState createState() => _OtherServiceScreenState();
}

class _OtherServiceScreenState extends State<OtherServiceScreen> {
  List<dynamic> _services = [];
  List<dynamic> _filteredServices= [];
  List<String> _selectedServices = [];
  bool _isLoading = true;
  String token = "";

  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _loadServices();
    _loadOtherServicesFromAPI();
  }


  void _loadOtherServicesFromAPI() async {

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
            _filteredServices = _services.where((service) =>
            service['type'] != 'Pharmacy' &&
                service['type'] != 'Ambulance' &&
                service['type'] != 'BloodBank' &&
                service['type'] != 'Counters' &&
                service['type'] != 'Cafeteria'
            ).toList();
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
    // setState(() {
    //   _filteredServices = _selectedServices.isNotEmpty
    //       ? _filteredServices
    //       .where((services) =>
    //       _selectedServices.contains(services['type']))
    //       .toList()
    //       : _filteredServices;
    // });
    setState(() {
      _filteredServices = _selectedServices.isNotEmpty
          ? _filteredServices.where((service) =>
          _selectedServices.contains(service['type'])).toList()
          : _filteredServices.toList();
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
    _filteredServices.map((services) => services['type']).toSet().toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'Other Services',
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

                return GestureDetector(
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

                  child:  Container(
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(8),
                    //   border: Border.o(color: Color(0xFFE0E0E0), width: 1),
                    // ),
                    width: MediaQuery.sizeOf(context).width,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

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
                                  ),
                                Spacer(),
                                // IconButton(onPressed: (){}, icon: Icon(Icons.directions))

                                InkWell(
                                  onTap:(){
                                    PassLocationId(context,service['locationId']);
                },
                                    child: Icon(Icons.directions,color: Color(0xff0B6B94),)),
                                SizedBox(width: 30,),
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
                                Spacer(),
                                InkWell(
                                  onTap:(){
                                    PassLocationId(context,service['locationId']);
                                  },
                                  child: TranslatorWidget(
                                    'Directions',
                                    style: TextStyle(
                                      color: Color(0xFF3F3F46),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,

                                    ),
                                  ),
                                ),
                                SizedBox(width: 16,),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(),

                          ],
                        ),
                      ],
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


