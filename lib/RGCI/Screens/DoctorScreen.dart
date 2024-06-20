import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iwaymaps/RGCI/Screens/DoctorProfile.dart';
import 'package:shimmer/shimmer.dart';
import '../../API/guestloginapi.dart';
import '../Data/DoctorDemoData.dart';
import 'package:http/http.dart' as http;

import '../Widgets/LocationIdFunction.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];

  String _selectedSpeciality = '';
  bool _isSearching = false;
  bool _isLoading = true;
  String token = "";
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _loadDoctors();
    _loadDoctorsFromAPI();
  }

  void _loadDoctorsFromAPI() async {
    try {
      await guestApi().guestlogin().then((value){
        if(value.accessToken != null){
          token = value.accessToken!;
        }
      });
      print('trying');
      final response = await http.get(

        Uri.parse("https://dev.iwayplus.in/secured/hospital/all-doctors/6673e7a3b92e69bc7f4b40ae"),
        headers: {
          'Content-Type': 'application/json',
        "x-access-token": token,
      },);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          setState(() {
            _doctors = responseData['data'];
            _filteredDoctors = _doctors;
            _isLoading = false;
          });
        } else {
          throw Exception('Response data does not contain the expected list of doctors under the "DoctorData" key');
        }
      } else {
        print("nope");
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  void _filterDoctors(String speciality) {
    setState(() {
      _selectedSpeciality = speciality;
      _filteredDoctors = speciality.isNotEmpty
          ? _doctors
              .where((doctor) => doctor['speciality'] == speciality)
              .toList()
          : _doctors;
    });
  }

  void _searchDoctors(String query) {
    setState(() {
      _filteredDoctors = _doctors
          .where((doctor) =>
      doctor['name'].toLowerCase().contains(query.toLowerCase())
          ||
          doctor['speciality'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    List specialities =
        _doctors.map((doctor) => doctor['speciality']).toSet().toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
              0),
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
        title: _isSearching
            ? TextField(
                onChanged: _searchDoctors,
                decoration: InputDecoration(
                  hintText: 'Search Doctors',
                  border: InputBorder.none,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'All Doctors',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 0.09,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _filteredDoctors = _doctors;
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : Column(
              children: [
                Semantics(
                  header: true,
                  container: true,
                  label: "Filters",
                  child: SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: specialities.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 4),
                            child: FilterChip(
                              label: Text(
                                'All',
                                style: TextStyle(
                                  color: _selectedSpeciality.isEmpty
                                      ? Colors.white
                                      : Color(0xFF1C2A3A),
                                ),
                              ),
                              showCheckmark: false,
                              selectedColor: Color(0xFF1C2A3A),
                              selected: _selectedSpeciality.isEmpty,
                              onSelected: (value) {
                                setState(() {
                                  _filterDoctors('');
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
                              label: Text(
                                speciality,
                                style: TextStyle(
                                  color: _selectedSpeciality == speciality
                                      ? Colors.white
                                      : Color(0xFF1C2A3A),
                                ),
                              ),
                              selectedColor: Color(0xFF1C2A3A),
                              showCheckmark: false,
                              selected: _selectedSpeciality == speciality,
                              onSelected: (value) {
                                setState(() {
                                  _filterDoctors(speciality);
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
                SizedBox(
                  height: 4,
                ),


                Expanded(
                  child: ListView.builder(
                    itemCount: specialities.length,
                    itemBuilder: (context, specialityIndex) {
                      final speciality = specialities[specialityIndex];
                      final doctorsOfSpeciality = _filteredDoctors
                          .where((doctor) => doctor['speciality'] == speciality)
                          .toList();
                      final bool isSelected = speciality == _selectedSpeciality;
                      if (_selectedSpeciality.isNotEmpty) {

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if (isSelected || _selectedSpeciality.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    speciality,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: doctorsOfSpeciality.length,
                              itemBuilder: (context, index) {
                                final doctor = doctorsOfSpeciality[index];
                                return Container(
                                  height: 179,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 12,
                                        top: 12,
                                        child: Container(
                                          width: 302,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [

                                              Container(
                                                width: 90,
                                                height: 90,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: NetworkImage('https://dev.iwayplus.in/uploads/${doctor['imageUrl']}'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Semantics(
                                                      label: "Name",
                                                      child: Text(
                                                        doctor['name'],
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF18181B),
                                                          fontSize: 16,
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(height: 8),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color:
                                                              Color(0xFF8D8C8C),
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),

                                                        Semantics(
                                                          label: "locationName",
                                                          child: Text(

                                                            // doctor['locationName'].split(' ').first,
                                                            // doctor['locationName'].split(' ').take(2).join(' '),
                                                            doctor['locationName'].split(' ').isEmpty || !RegExp(r'^\d+$').hasMatch(doctor['locationName'].split(' ').first)
                                                                ? doctor['locationName'].split(' ').take(2).join(' ')
                                                                : doctor['locationName'].split(' ').first,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF8D8C8C),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 12,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 1,
                                                color: Color(0xffEBEBEB),
                                              ),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => DoctorProfile(
                                                              docId: doctor['_id'],
                                                              doctor: doctor,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        side: BorderSide(
                                                            color: Color(
                                                                0xFF0B6B94)),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'View Profile',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF0B6B94),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Icon(
                                                            Icons
                                                                .arrow_outward_outlined,
                                                            color: Color(
                                                                0xFF0B6B94),
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        print('called');
                                                        PassLocationId(context,doctor['locationId']);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Color(0xFF0B6B94),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Transform.rotate(
                                                            angle: 180 * 3.1415926535 / 180,
                                                            child: Icon(
                                                              Icons.subdirectory_arrow_left_outlined,
                                                              color: Colors.white,
                                                              size: 18,
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Directions',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if ((isSelected || _selectedSpeciality.isEmpty)&& doctorsOfSpeciality.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,vertical: 10),
                                child: Semantics(
                                  header: true,
                                  child:
                                  Row(
                                    children: [
                                      Text(

                                        speciality.length > 30

                                            ? '${speciality.substring(0, 30)} ...'

                                            : speciality,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        height: 20,
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _filterDoctors(speciality);
                                            });
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all<EdgeInsets>(
                                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                            ),
                                          ),
                                          child: Text(
                                            'See all',
                                            style: TextStyle(
                                              color: Color(0xFF3F3F46),
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 0.10,
                                            ),
                                          ),
                                        ),
                                      )

                                    ],
                                  ),
                                ),
                              ),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: doctorsOfSpeciality.map((doctor) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 18.0),
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width*0.78,
                                      height: 170,
                                      margin: EdgeInsets.only(
                                          top: 8, bottom: 8,left: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 12.0,top: 12),
                                            child: Row(
                                              children: [

                                                Container(
                                                  width: 90,
                                                  height: 90,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage('https://dev.iwayplus.in/uploads/${doctor['imageUrl']}'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        doctor['name'],
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF18181B),
                                                          fontSize: 16,
                                                          fontFamily: 'Roboto',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),

                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            color:
                                                                Color(0xFF8D8C8C),
                                                            size: 16,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            // doctor['locationName'].split(' ').first,
                                                            doctor['locationName'].split(' ').isEmpty || !RegExp(r'^\d+$').hasMatch(doctor['locationName'].split(' ').first)
                                                                ? doctor['locationName'].split(' ').take(2).join(' ')
                                                                : doctor['locationName'].split(' ').first,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF8D8C8C),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontWeight:
                                                                  FontWeight.w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Column(
                                              children: [
                                                SizedBox(height: 7,),
                                                Container(
                                                    height: 1,
                                                    color: Color(0xffEBEBEB)),
                                                SizedBox(height: 7),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        onPressed: () {

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => DoctorProfile(
                                                                docId: doctor['_id'],
                                                                doctor: doctor,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 6),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(4),
                                                          ),
                                                          side: BorderSide(
                                                              color: Color(
                                                                  0xFF0B6B94)),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'View Profile',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF0B6B94),
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Icon(
                                                              Icons
                                                                  .arrow_outward_outlined,
                                                              color: Color(
                                                                  0xFF0B6B94),
                                                              size: 18,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          PassLocationId(context,doctor['locationId']);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Color(0xFF0B6B94),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 6),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(4),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Transform.rotate(
                                                              angle: 180 * 3.1415926535 / 180,
                                                              child: Icon(
                                                                Icons.subdirectory_arrow_left_outlined,
                                                                color: Colors.white,
                                                                size: 18,
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              'Directions',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.white,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),

              ],
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [

        SizedBox(
          height: 10,
        ),
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
                      width: index == 0 ? 50 : 100,
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
              padding: const EdgeInsets.all(16.0),
              child: Shimmer.fromColors(
                baseColor: Color(0xffD9D9D9).withOpacity(0.43),
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 80,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

