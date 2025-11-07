import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../API/buildingAllApi.dart';
import '../API/ladmarkApi.dart';
import '../APIMODELS/landmark.dart';
import '../ELEMENTS/HelperClass.dart';
import '../Repository/RepositoryManager.dart';
import '../singletonClass.dart';
import '../SourceAndDestinationPage.dart';
import '../newSearchPage.dart';
import '../Elements/locales.dart';
import '../UserState.dart';
import '../websocket/interactionManager.dart';
import 'HomepageFilter.dart';

class HomepageSearch extends StatefulWidget {
  final searchText;
  UserState user;
  final Function(String ID,{bool DirectlyStartNavigation}) onVenueClicked;
  final Function(List<String>) fromSourceAndDestinationPage;
  HomepageSearch({super.key, this.searchText = "Search", required this.onVenueClicked, required this.fromSourceAndDestinationPage,required this.user});

  @override
  State<HomepageSearch> createState() => _HomepageSearchState();
}

class _HomepageSearchState extends State<HomepageSearch> {
  List<String> optionsTags = [];
  List<String> floorOptionsTags = [];
  //double ratio=0.0;
  String currentSelectedFilter = "";
  int vall = 0;
  int lastValueStored = 0;

  FlutterTts flutterTts  = FlutterTts();

  Future<void> speak(String msg) async {
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(msg);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchandBuild();
    print("Running init");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // print("callingg...");
    fetchandBuild(); // Called again when dependencies change
  }

  land landmarkData = land();
  void fetchandBuild()async{
    await fetchlist();
  }
  Set<String> optionListForUI ={};
  bool isUpdated=false;

  String getIcon(String option) {
    switch (option.toLowerCase()) {
      case 'washroom':
        return 'assets/washroomIcon.png';
      case 'cafeteria':
        return 'assets/cafeteria.png';
      case 'drinking water':
        return 'assets/waterPoint.png';
      case 'atm':
        return 'assets/atmIcon.png';
      case 'exit':
        return 'assets/entryExit.png';
      case 'lift':
        return 'assets/liftIcon.png';
      case 'reception':
        return 'assets/receptionIcon.png';
      default:
        return ''; // Return a default icon if no match is found
    }
  }
  Future<void> loadLandmarkData() async {
    try {
      Set<String> tempOptionSet = {}; // use Set to prevent duplicates
      await Future.forEach(
        landmarkData.landmarksMap!.entries,
            (MapEntry keyValue) async {
          var value = keyValue.value;
          final subType = value.element?.subType ?? '';
          final buildingID = value.buildingID;
          // Always include global types
          if (subType == "restRoom") {
            tempOptionSet.add("Washroom");
          } else if (subType == "ATM") {
            tempOptionSet.add("ATM");
          } else if (subType == "Drinking Water") {
            tempOptionSet.add("Drinking Water");
          }
          if (widget.user.bid == buildingAllApi.outdoorID) return;
          // Conditional based on selected building ID
          if (buildingID == widget.user.bid) {
            if (subType == "Cafeteria") {
              tempOptionSet.add("Cafeteria");
            } else if (subType == "main entry") {
              tempOptionSet.add("Exit");
            } else if (subType == "lift") {
              tempOptionSet.add("Lift");
            } else if (subType == "Help Desk | Reception") {
              tempOptionSet.add("Reception");
            }
          }
        },
      );

      setState(() {
        optionListForUI = tempOptionSet; // overwrite old list
        isUpdated = true;
      });
    } catch (e) {
      print("Error in updating list: $e");
      setState(() {
        isUpdated = false;
      });
    }
  }
  Future<void> fetchlist() async {
    land? singletonData = await SingletonFunctionController.building.landmarkdata;
    if(singletonData != null){
      landmarkData = singletonData;
      await loadLandmarkData();
      return;
    }
    buildingAllApi.getStoredAllBuildingID().forEach((key, value) async {
      await RepositoryManager().getLandmarkDataNew(key).then((value) async {
        landmarkData.mergeLandmarks(value.landmarks);
        print("buildingAllApi.getStoredAllBuildingID()${value.landmarks}");
        await loadLandmarkData();
      });
      // print("buildingAllApi.getStoredAllBuildingID() runned");
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
            width: screenWidth - 32,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white, // You can customize the border color
                width: 1.0, // You can customize the border width
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Shadow color
                  offset:
                  Offset(0, 2), // Offset of the shadow
                  blurRadius: 4, // Spread of the shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height:24,
                    width: 24,
                    margin: EdgeInsets.only(left: 12, top: 2),
                    child: Image.asset("assets/AppIcon.png")),
                Expanded(
                  child: FocusScope(
                    autofocus: true,
                    child: Focus(
                      child: Semantics(
                        header: true,
                        textField: true,
                        sortKey: const OrdinalSortKey(0),
                        label: "${LocaleData.waytogo.getString(context)}",

                        child: InkWell(
                          onTap: (){
                            InteractionManager().logInteraction("Navigation Search");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewSearchPage(hintText: 'Destination location',voiceInputEnabled: false, user:widget.user))
                            ).then((value){
                              print("POP22");
                              fetchandBuild();
                              InteractionManager().logInteraction("${value}");
                              widget.onVenueClicked(value,DirectlyStartNavigation: false);
                            });
                          },
                          child: Semantics(
                            excludeSemantics: true,
                            child: Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  "${LocaleData.waytogo.getString(context)}",
                                  style: const TextStyle(
                                    fontFamily: "PT_Sans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff8e8d8d),
                                    height: 25 / 16,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 48,
                  margin: EdgeInsets.only(right: 5),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewSearchPage(hintText: 'Destination location',voiceInputEnabled: true, user: widget.user))
                        ).then((value){
                          print("POPPP");
                          widget.onVenueClicked(value);
                        });
                      },
                      icon: Semantics(
                        label: "Voice search",
                        sortKey: const OrdinalSortKey(1),
                        child: Icon(
                          Icons.mic_none_sharp,
                          color: Color(0xff8E8C8C),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
        optionListForUI.isNotEmpty?Container(
          width: screenWidth,
          child: ChipsChoice<int>.single(
            value: vall,
            onChanged:(val){
              setState(() => vall = val);
              if(HelperClass.SemanticEnabled){
                speak("${optionListForUI.toList()[val]} selected");
              }else if(lastValueStored == val){
                speak("${optionListForUI.toList()[val]} selected");
              }
              lastValueStored = val;
              print("wilsonchecker ${optionListForUI.toList()[val]}");
              print(val);
            },
            choiceItems: C2Choice.listFrom<int, String>(
              source: optionListForUI.toList(),
              value: (i, v) => i,
              label: (i, v) => v,
            ),
            choiceBuilder: (item, i){
              return HomepageFilter(svgPath: '', text: optionListForUI.toList()[i], onSelect: (bool selected) {  }, onClicked: widget.onVenueClicked, icon: getIcon(optionListForUI.toList()[i].toLowerCase()), user: widget.user,);
            },
            direction: Axis.horizontal,
          ),
        ):Container(),
      ],
    );
  }
}

String getIcon(String option) {
  switch (option.toLowerCase()) {
    case 'washroom':
      return 'assets/washroomIcon.png';
    case 'cafeteria':
      return 'assets/cafeteria.png';
    case 'drinking water':
      return 'assets/waterPoint.png';
    case 'atm':
      return 'assets/atmIcon.png';
    case 'exit':
      return 'assets/entryExit.png';
    case 'lift':
      return 'assets/liftIcon.png';
    case 'reception':
      return 'assets/receptionIcon.png';
    case 'stair':
      return 'assets/stairIcon.png';
    case 'ramp':
      return 'assets/rampIcon.png';
    default:
      return ''; // Return a default icon if no match is found
  }
}



class CustomChip extends StatelessWidget {
  final String label;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final Function(bool selected) onSelect;

  const CustomChip({
    Key? key,
    required this.label,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.selected = false,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected
            ? (color ?? Colors.white)
            : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(selected ? 10 : 10)),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(selected ? 25 : 10)),
        onTap: () => onSelect(!selected),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 10),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                  height: 20/14,
                ),
              ),
            ),
            Container(
              child: selected ? AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                firstChild: const Icon(Icons.close, color: Colors.white), // Check icon when selected
                secondChild: const Icon(Icons.close, color: Colors.white), // Close icon when not selected
                crossFadeState: selected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              ): null,
            ) ,
            // Icon displayed when active is true

          ],
        ),
      ),
    );
  }
}

class Content extends StatefulWidget {
  final String title;
  final Widget child;

  const Content({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            // color: Colors.blueGrey[50],
            child: Text(
              widget.title,
              style: const TextStyle(
                // color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}

void _about(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              'chips_choice',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.black87),
            ),
            subtitle: const Text('by davigmacode'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Easy way to provide a single or multiple choice chips.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.black54),
                  ),
                  Container(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}