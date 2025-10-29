import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../SourceAndDestinationPage.dart';

class DestinationPageChipsWidget extends StatefulWidget {
  final String svgPath;
  final String text;
  bool selected;
  final String icon;
  final Function(bool selected) onSelect;

  DestinationPageChipsWidget({
    required this.svgPath,
    required this.text,
    this.selected = false,
    required this.icon,
    required this.onSelect,
  });

  @override
  _DestinationPageChipsWidgetState createState() => _DestinationPageChipsWidgetState();
}

class _DestinationPageChipsWidgetState extends State<DestinationPageChipsWidget> {


  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Search for ${widget.text}",
      child: AnimatedContainer(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
        padding: EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 2), // Offset of the shadow
              blurRadius: 4, // Spread of the shadow
            ),
          ],
        ),
        duration: Duration(milliseconds: 600),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(10.0)), // Updated borderRadius
          onTap: () {
            setState(() {
              widget.selected = !widget.selected;
            });
            if(widget.selected){
              widget.onSelect(widget.selected);
              widget.selected ? print("black") : print("white");
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 4),
                child: Image.asset(widget.icon, width:  18,height: 18, color: widget.selected? Colors.white: Colors.black,),
              ),
              Semantics(
                excludeSemantics: true,
                child: Container(
                  margin: EdgeInsets.only(left: 8, right: 4),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.selected? Colors.white : Color(0xff49454f) ,
                      height: 20 / 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              widget.selected? Semantics(
                excludeSemantics: true,
                child: InkWell(
                  onTap: (){
                    setState(() {
                      widget.selected=!widget.selected;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Semantics(
                        label: "Unselect ${widget.text}",
                        child: Icon(Icons.close, size: 18, color: widget.selected? Colors.white: Colors.black,)),
                  ),
                ),
              ) : Container()


              // Icon displayed when active is true
            ],
          ),
        ),
      ),
    );
  }
}

class button extends StatelessWidget {
  final String svgPath;
  final String text;
  final String icon;

  button({
    required this.svgPath,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Image.asset(icon, width:  18,height: 18, color: Colors.black,),
          ),
          Semantics(

            excludeSemantics: true,
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 4),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff49454f) ,
                  height: 20 / 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Icon displayed when active is true
        ],
      ),
    );
  }
}


class HorizontalButtons extends StatelessWidget {
  final List<String> items;

  const HorizontalButtons({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Height of buttons
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Semantics(
              button: true,
              label:
              '${items[index]}, button ${index + 1} of ${items.length}', // Accessibility text
              child: ElevatedButton(
                onPressed: () {
                  // Handle button press
                  print('Pressed: ${items[index]}');
                },
                child: Text(items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
