
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwaymaps/AiimsJammu/Widgets/Translator.dart';
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
class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
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
    _loadPharmacyServicesFromAPI();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
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
            _filteredServices = _services.where((service) => service['type'] == 'Ambulance' || service['type'] == 'BloodBank').toList();

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

  @override
  Widget build(BuildContext context) {
    List specialities =
    _services.map((services) => services['type']).toSet().toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'Emergency Services',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 0.09,
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
          Container(child: Image.asset('assets/images/emergencybanner.png')),

          SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                SizedBox(width: 22,),
                TranslatorWidget(
                  'Help Center',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,

                  ),
                ),
                const SizedBox(width: 8),
                TranslatorWidget(
                  '24/7',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,

                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 1,
                ),
                itemCount: _filteredServices.length,
                itemBuilder: (context, index) {
                  final service = _filteredServices[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceInfo(
                            id: service['_id'],
                            imagePath: service['image'],
                            name: service['name'],
                            location: service['locationName'],
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
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
                      ),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(service['type']=='Ambulance')
                          Image.asset('assets/images/EmergencyLogo.png',scale: 3,),
                          if(service['type']=='BloodBank')
                          Image.asset('assets/images/Blood Bank.png',scale: 3,),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                              SizedBox(width: 8,),
                              if (service['accessibility'] != 'NO')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Image.asset('assets/images/accessible.png', scale: 4),
                                ),
                            ],
                          ),

                          SizedBox(height: 12),


                          Container(
                            child: OpeningClosingStatus(startTime: service['startTime'], endTime: service['endTime']),
                          ),
                          SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(onPressed: (){

                                _makePhoneCall(service['contact']);
                              }, icon: Icon(Icons.phone)),
                              IconButton(onPressed: (){
                                PassLocationId(context,service['locationId']);
                              }, icon: Icon(Icons.directions)),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
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


