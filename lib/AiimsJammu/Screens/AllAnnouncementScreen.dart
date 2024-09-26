
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:iwaymaps/AiimsJammu/Widgets/Translator.dart';

import '../../API/guestloginapi.dart';
import '../../config.dart';
import '../Widgets/AnouncementCard.dart';

class AllAnnouncementScreen extends StatefulWidget {
  const AllAnnouncementScreen({super.key});

  @override
  State<AllAnnouncementScreen> createState() => _AllAnnouncementScreenState();
}

class _AllAnnouncementScreenState extends State<AllAnnouncementScreen> {
  List<dynamic> _announcement=[];
  String token = "";
  var DashboardListBox = Hive.box('DashboardList');

  @override

  void initState() {
    super.initState();
    // _loadServices();
    // _loadAnnouncementFromAPI();
    checkForReload();
  }
  void checkForReload(){
    if(DashboardListBox.containsKey('announcements')){
      _announcement = DashboardListBox.get('announcements');
      print('announcements FROM DATABASE');

    }else{
      _loadAnnouncementFromAPI();
      print('announcements API CALL');
    }
  }
  void _loadAnnouncementFromAPI() async {

    try {
      await guestApi().guestlogin().then((value){
        if(value.accessToken != null){
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(

        Uri.parse("${AppConfig.baseUrl}/secured/hospital/all-announcement/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
          "x-access-token": token,
        },);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            _announcement = responseData['data'];
            DashboardListBox.put('announcements', responseData['data']);
            // _filteredServices = _services;
            // _isLoading = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'Announcements',
          style: TextStyle(
            color: Color(0xFF18181B),
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

      body:  Column(

        children: [
          SizedBox(height: 16,),
          Expanded(
            child: ListView.builder(

              scrollDirection: Axis.vertical,
              itemCount: _announcement.length,
              itemBuilder: (BuildContext context, int index) {
                final announcement = _announcement[index];
                return AnnouncementCard(
                  image: announcement['image']??"",
                  title: announcement['title']??"",
                  department: announcement['department']?? "",
                  dateTime: announcement['dateTime']??"",
                  article: announcement['article']??"",

                  // announcements: AnnounceData,

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
