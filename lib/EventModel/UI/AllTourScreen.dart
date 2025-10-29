import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../API/AllTourAPI.dart';
import '../APIModel/AllTourModel.dart';
import 'TourDetailScreen.dart';
import 'package:intl/intl.dart';


class AllTourScreen extends StatefulWidget {
  const AllTourScreen({super.key});

  @override
  State<AllTourScreen> createState() => _AllTourScreenState();
}

class _AllTourScreenState extends State<AllTourScreen> {
  late Future<AllTourModel> _tourFuture;
  List<Data> _allTours = [];
  List<Data> _filteredTours = [];
  String? _selectedDate;
  List<String> tourIDS = [];

  @override
  void initState() {
    super.initState();
    _tourFuture = AllTourAPI().fetchTours();
  }

  void _filterByDate(String date) {
    setState(() {
      _selectedDate = date;
      _filteredTours = _allTours.where((tour) => tour.date == date).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white, // white background
        middle: Text("List of Tours"),
      ),
      child: SafeArea(
        child: FutureBuilder<AllTourModel>(
          future: _tourFuture,
          builder: (context, snapshot) {
            snapshot.data == null;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 16),
              );
            } else if (snapshot.data == null || snapshot.hasError) {
              return Center(
                child: Semantics(
                  label: "Looks like we’re having a little network hiccup",
                  child: Container(
                    padding: EdgeInsets.all(20),

                    child: Text(
                      "Looks like we’re having a little network hiccup!!",
                      style: TextStyle(
                          color: CupertinoColors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PT_Sans',
                          fontSize: 24
                      ),
                    ),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
              return Center(
                child: Semantics(
                  label: "Looks like we’re having a little network hiccup",
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Text("Looks like we’re having a little network hiccup!!",
                      style: TextStyle(
                        color: CupertinoColors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'PT_Sans',
                        fontSize: 24
                    ),
                                  ),
                  ),
                ),
              );
            }

            _allTours = snapshot.data!.data!;

            // Unique date list
            final dates = _allTours.map((t) => t.date).toSet().toList();
            dates.sort();

            // Apply filter
            if (_selectedDate == null && dates.isNotEmpty) {
              _selectedDate = dates.first;
              _filteredTours =
                  _allTours.where((t) => t.date == _selectedDate).toList();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final isSelected = date == _selectedDate;

                      return GestureDetector(
                        onTap: () => _filterByDate(date!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF66157b)
                                : CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: CupertinoColors.activeBlue
                                    .withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                                : [],
                          ),
                          child: Center(
                            child: Container(
                              child: Text(
                                formatDate(date!) ?? "",
                                style: TextStyle(
                                    color: isSelected
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PT_Sans',
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                // 🔹 Tour List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTours.length,
                    itemBuilder: (context, index) {
                      final tour = _filteredTours[index];
                      tourIDS = _filteredTours[index].listofevent!;
                      return _buildTourCard(tour);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String formatDate(String dateString) {
    // Parse the input string
    final DateTime date = DateTime.parse(dateString);

    // Format it to "08 Oct"
    final String formatted = DateFormat('dd MMM').format(date);

    return formatted;
  }


  Widget _buildTourCard(dynamic tour) {
    return GestureDetector(
      onTap: (){
        print("GestureDetector");
        // On Tap of Tour Card
        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (_) => TourDetailScreen(eventIds: tourIDS),
        //   ),
        // );

      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x22000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.map_pin_ellipse, color: CupertinoColors.activeBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label: "${tour.title ?? "Untitled Tour"}",
                    child: Text(
                      tour.title ?? "Untitled Tour",
                      style: const TextStyle(
                        decoration: TextDecoration.none, // 👈 Stops underlines
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                        fontFamily: 'PT_Sans',
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(CupertinoIcons.calendar,
                    size: 18, color: CupertinoColors.systemGrey),
                const SizedBox(width: 10),
                Semantics(
                  label: "${formatDate(tour.date)}",
                  child: Text(formatDate(tour.date) ?? "No date",
                      style: const TextStyle(
                        fontFamily: 'PT_Sans',
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                        decoration: TextDecoration.none, // 👈 Stops underlines
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(CupertinoIcons.time,
                    size: 18, color: CupertinoColors.systemGrey),
                const SizedBox(width: 10),
                Semantics(
                  label: '${tour.startTime?.isNotEmpty == true
                      ? tour.startTime!
                      : "No start time"}',
                  child: Text(
                    tour.startTime?.isNotEmpty == true
                        ? tour.startTime!
                        : "No start time",
                    style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                      decoration: TextDecoration.none, // 👈 Stops underlines
                      fontFamily: 'PT_Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 16
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF8f3ca2).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Semantics(
                label: "Duration: ${tour.duration ?? "Unknown"} | ${tour.shift ?? ""}",
                child: Text(
                  "Duration: ${tour.duration ?? "Unknown"} | ${tour.shift ?? ""}",
                  style: const TextStyle(
                    decoration: TextDecoration.none, // 👈 Stops underlines
                    fontFamily: 'PT_Sans',
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}