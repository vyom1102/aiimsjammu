import 'package:flutter/material.dart';
import '../UserState.dart';
import '../newSearchPage.dart';

class HomepageFilter extends StatefulWidget {
  final Function(String ID) onClicked;
  final String svgPath;
  final String text;
  bool selected;
  String icon;
  UserState user;
  final Function(bool selected) onSelect;

  HomepageFilter({
    required this.svgPath,
    required this.text,
    this.selected = false,
    required this.onSelect,
    required this.icon,
    required this.onClicked,
    required this.user
  });

  @override
  _HomepageFilterState createState() => _HomepageFilterState();
}

class _HomepageFilterState extends State<HomepageFilter> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          label: 'Search for ${widget.text}',
          child: Container(
            margin: EdgeInsets.only(left: 0, top: 4, right: 7, bottom: 0),
            padding: EdgeInsets.all(8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Shadow color
                  offset: Offset(0, 2), // Offset of the shadow
                  blurRadius: 4, // Spread of the shadow
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(10.0)), // Updated borderRadius
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewSearchPage(previousFilter: widget.text.toLowerCase(),voiceInputEnabled: false, user: widget.user,))
                ).then((value){

                  widget.onClicked(value);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Image.asset(widget.icon, width:  18,height: 18, color: widget.selected? Colors.white: Colors.black,),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 4),
                    child: Semantics(
                      excludeSemantics: true,
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          fontFamily: "PT_Sans",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff49454f),
                          height: 20 / 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Icon displayed when active is true
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
