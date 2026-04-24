import 'dart:async';
import 'dart:ui' as img;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:unified_map_view/unified_map_view.dart';
import 'package:unified_map_view/maplibre.dart';
import 'package:navigation_sdk/navigation_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import '../Navigation.dart';
import 'APIModel/CardData.dart';

class SessionDetail extends StatefulWidget {
  late String title;
  late String date;
  late String startDate;
  late String endDate;
  late String time;
  late String loc;
  late String? venueId;
  late List<String>? hash;
  late String seats;
  late String eventid;
  late String category;
  late String notificationMessage;
  late String moderator;
  late List<dynamic>? subevents;
  late String? filename;
  late String? description;
  late String? eventType;
  late String? bookingType;
  late String? speakerName;
  late CardData? dataForHiveStorageAndFurtherUse;
  late String? speakerID;
  bool hideDirectionButton;

  SessionDetail(
      {this.hideDirectionButton = false,
        required this.title,
      required this.date,
      required this.startDate,
      required this.endDate,
      required this.time,
      required this.loc,
        required this.venueId,
      required this.hash,
      required this.seats,
      required this.eventid,
      required this.moderator,
      required this.category,
      required this.subevents,
      required this.filename,
      this.notificationMessage = '',
      required this.description,
      required this.eventType,
      required this.bookingType,
      required this.speakerName,
      required this.speakerID,
      required this.dataForHiveStorageAndFurtherUse});

  @override
  SessionDetailState createState() => SessionDetailState();
}

class SessionDetailState extends State<SessionDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Color heartcolor = Color(0xffBDBDBD);
  GlobalKey _globalKey = GlobalKey();
  Uint8List? _imageBytes;
  final String imageUrl =
      'https://i0.wp.com/picjumbo.com/wp-content/uploads/beautiful-nature-scenery-free-photo.jpg?w=2210&quality=70';

  final String longText =
      "Experience the indomitable spirit of athletes. Witness extraordinary talent in events such as Blind Football, Special Olympics, Para Olympics, Asian Blind Chess Championship and many more.";

  bool isExpanded = false;
  String finallongText = "";

  Future<ui.Image> loadImage() async {
    final String imageUrl =
        'https://maps.iwayplus.in/uploads/${widget.filename}';
    // Replace with your image URL
    final Uri resolved = Uri.parse(imageUrl);
    final HttpClientRequest request = await HttpClient().getUrl(resolved);
    final HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image rawImage = frameInfo.image;

      // Create a Paint object for border styling
      final Paint borderPaint = Paint()
        ..color = Colors.black // Set the color for the border
        ..style = PaintingStyle.stroke // Set the style to stroke
        ..strokeWidth = 5.0; // Set the width of the border

      // Define the border radius
      final double borderRadius = 10.0; // Adjust the border radius as needed

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw a rounded rectangle to clip the image with rounded corners
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0, 0, rawImage.width.toDouble(), rawImage.height.toDouble()),
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      );

      // Clip the image with the rounded rectangle
      canvas.clipRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, rawImage.width.toDouble() + 100,
              rawImage.height.toDouble() + 100),
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

      // Draw the image onto the canvas
      canvas.drawImage(rawImage, Offset.zero, Paint());

      // Convert the canvas to an image
      final roundedImage = await recorder.endRecording().toImage(
            rawImage.width,
            rawImage.height,
          );

      return roundedImage;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<ui.Image> loadLogo() async {
    final ByteData data = await rootBundle.load(
        'assets/iwayLogo.png'); // Replace 'assets/logo.png' with your asset path
    final Uint8List bytes = data.buffer.asUint8List();

    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });

    return completer.future;
  }

  Future<ui.Image> createImage(int width, int height) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Create a paint object for drawing
    final ui.Paint paint = ui.Paint()
      ..color = const ui.Color(0xFF0000FF); // Example color: blue

    // Draw a rectangle on the canvas
    canvas.drawRect(
        ui.Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()), paint);

    // Convert the canvas to an image
    final ui.Image image = await recorder.endRecording().toImage(width, height);
    return image;
  }

  Future<Uint8List> _capturePng2() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final ui.Image img1 =
        await loadImage(); // Replace this with your image loading logic
    final ui.Image img = await createImage(
        300, 200); // Replace this with your image loading logic
    final double borderRadius = 10.0; // Adjust the border radius as needed

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, img1.width.toDouble(), img1.height.toDouble()),
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawImage(img1, Offset.zero, Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            0, 0, img1.width.toDouble(), img1.height.toDouble() + 240),
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      Paint()..color = Color(0xff48246C),
    );
    canvas.drawImage(img1, Offset.zero, Paint()..color = Color(0xff48246C));

    final ui.ParagraphStyle mainTextStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 48.0,
      fontWeight: FontWeight.bold,
    );
    // Define text for the main title
    final String mainText = widget.title;

    // Create a paragraph builder for the main title
    final ui.ParagraphBuilder mainParagraphBuilder =
        ui.ParagraphBuilder(mainTextStyle)
          ..pushStyle(ui.TextStyle(
            color: ui.Color(0xffFFFFFFF),
            fontWeight: FontWeight.w600,
          ))
          ..addText(mainText);
    final Paragraph mainParagraph = mainParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: 1300)); // Adjust width as needed
    final double leftMargin = 35.0; // Adjust left margin as needed
    canvas.drawParagraph(mainParagraph, Offset(leftMargin, img1.height + 30));

    final ui.ParagraphStyle additionalTextStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 36.0,
      fontWeight: FontWeight.bold,
    );

    // Define text for the additional text
    final String additionalText = widget.loc;

    // Create a paragraph builder for the additional text
    final ui.ParagraphBuilder additionalParagraphBuilder =
        ui.ParagraphBuilder(additionalTextStyle)
          ..pushStyle(ui.TextStyle(
              color: ui.Color(0xffFFFFFFF), fontWeight: FontWeight.w600))
          ..addText(additionalText);
    final Paragraph additionalParagraph = additionalParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: 2600)); // Adjust width as needed
    canvas.drawParagraph(
        additionalParagraph,
        Offset(
            leftMargin,
            img1.height +
                100)); // Position the additional text below the main text

    //----logo--
    // Draw the logo and text onto the canvas
    final ui.Image logo =
        await loadLogo(); // Replace with your logo loading logic
    final double scaleFactor =
        0.2; // Adjust this scale factor as needed (e.g., 0.5 for half size)
    final double logoWidth = logo.width.toDouble() * scaleFactor;
    final double logoHeight = logo.height.toDouble() * scaleFactor;
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(),
          logo.height.toDouble()), // Source rectangle (entire image)
      Rect.fromLTWH(
        leftMargin,
        img1.height.toDouble() + 180,
        logoWidth,
        logoHeight,
      ), // Destination rectangle (position and size on the canvas)
      Paint()..color = Colors.white,
    );
    final ui.ParagraphStyle logoTextStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    );
    final String logoText = 'Iwayplus';

    // Create a paragraph builder for the text inside the logo
    final ui.ParagraphBuilder logoParagraphBuilder =
        ui.ParagraphBuilder(logoTextStyle)
          ..pushStyle(ui.TextStyle(color: ui.Color(0xffFFFFFFF)))
          ..addText(logoText);
    final Paragraph logoParagraph = logoParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: 800)); // Adjust width as needed
    canvas.drawParagraph(
        logoParagraph,
        Offset(leftMargin + 45,
            img1.height.toDouble() + 190)); // Position the text inside the logo

    final ui.Image capturedImage = await recorder
        .endRecording()
        .toImage(img1.width, (img1.height + 240).toInt());

    final ByteData? byteData =
        await capturedImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return byteData.buffer.asUint8List();
    }
    throw Exception('Failed to capture image');
  }

  void shareToInstagramStory() async {
    Uint8List imageBytes = await _capturePng2();
    // // Use imageBytes to share on Instagram (not implemented here)
    // // Example: shareImageOnInstagram(imageBytes);
    // setState(() {
    //   _imageBytes = imageBytes;
    // });
    final tempDir = await Directory.systemTemp;
    final tempPath = '${tempDir.path}/image_share.png';
    await File(tempPath).writeAsBytes(imageBytes);
    // Share.shareFiles([tempPath],
    //     mimeTypes: ['image/png']);

    String textToShare =
        '${widget.title} \n \n${widget.description}'; // Replace with the text you want to share
    //Share.shareFiles([tempPath],subject: widget.eventType, text: textToShare, );
  }

  List<String> itemList = ["Music", "Dance", "Karlo", "stage", "pr"];

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Widget buildItemList() {
    if (itemList.isEmpty) {
      return SizedBox(); // Return an empty SizedBox if the list is empty
    } else if (itemList.length <= 2) {
      // Display two containers for the first two items
      return Row(
        children: [
          buildItemContainer(itemList[0]),
          SizedBox(width: 4), // Add some space between containers
          buildItemContainer(itemList[1]),
        ],
      );
    } else {
      // Display two containers for the first two items
      // and a third container showing the count of remaining items
      return Row(
        children: [
          buildItemContainer(itemList[0]),
          SizedBox(width: 4), // Add some space between containers
          buildItemContainer(itemList[1]),
          SizedBox(width: 2), // Add some space between containers
          buildRemainingItemsContainer(itemList.length - 2),
        ],
      );
    }
  }

  String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + '..';
    }
  }

  Widget buildItemListFinal() {
    if (widget.hash!.isEmpty) {
      return SizedBox(); // Return an empty SizedBox if the list is empty
    } else if (widget.hash!.length == 1) {
      return Row(
        children: [
          //buildItemContainer(widget.genre[0]),
          Container(
            margin: EdgeInsets.only(
              left: 7,
            ),
            child: Text(
              truncateString("#" + widget.hash![0], 16),
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff4A4545),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 4), // Add some space between containers
        ],
      );
    } else {
      // Display two containers for the first two items
      // and a third container showing the count of remaining items
      return Row(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 7,
            ),
            child: Text(
              truncateString("#" + widget.hash![0], 10),
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff4A4545),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 2), // Add some space between containers
          buildRemainingItemsContainer(widget.hash!.length - 1),
        ],
      );
    }
  }

  Widget buildItemContainer(String item) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: Color(0xff878787), // Set border color to black
        ),
      ),
      child: Text(
        item,
        style: const TextStyle(
          fontFamily: "Roboto",
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xff878787),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildRemainingItemsContainer(int remainingCount) {
    return Container(
      // margin: EdgeInsets.only( top: 12, bottom: 6),
      padding: EdgeInsets.all(4),
      child: Text(
        '+$remainingCount',
        style: const TextStyle(
          fontFamily: "Roboto",
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xff878787),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _loadMap() async {
    // Simulate loading delay, replace with your actual initialization code.
    await Future.delayed(Duration(seconds: 2));
  }

  Future<GoogleMapController> _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    return _controller.future;
  }

  List<Widget> subeventwidgetlist = [];
  bool savedCard = false;
  static var testBox = Hive.box('testingSave');

  @override
  void initState() {
    super.initState();

    print("testBox${testBox.containsKey(widget.eventid)}");
    print(widget.eventid);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if(!widget.hideDirectionButton){
      widget.hideDirectionButton = (widget.hideDirectionButton && (widget.venueId == null || widget.venueId!.isEmpty));
    }
  }

  @override
  Widget build(BuildContext context) {
    finallongText = widget.description == "" ? longText : finallongText;
    print("long text $finallongText");
    print(widget.description);

    final data = ModalRoute.of(context)!.settings.arguments;
    print('Coming Data');
    print(data);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    //
    DateTime dateTime = DateTime.parse(widget.date);
    String formattedDate = DateFormat.yMMMMEEEEd().format(dateTime);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xffffffff),
          leading: IconButton(
            icon: Semantics(
                label: 'Back',
                child:
                    Icon(Icons.arrow_back_ios_new, color: Color(0xff000000))),
            onPressed: () {
              Navigator.pop(context);
            },
          ), // Set your desired background color
          title: Container(
            alignment: Alignment.center,
            child: Text(
              'Session Details',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff000000),
              ),
            ),
          ),
          actions: [
            widget.eventid != ""
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      child: Semantics(
                        label: 'Boorkmark Event',
                        child: Icon(
                          // Check if the event ID exists in the bookmarked cards
                          widget.eventid != ""
                              ? testBox.containsKey(widget.eventid)
                                  ? Icons
                                      .bookmark_rounded // If event is bookmarked, show filled icon
                                  : Icons.bookmark_outline_rounded
                              : Icons
                                  .bookmark_outline_rounded, // Otherwise, show outlined icon
                          size: 34,
                          color: widget.eventid != ""
                              ? testBox.containsKey(widget.eventid)
                                  ? Colors
                                      .yellow // If bookmarked, color is yellow
                                  : Colors.black26
                              : Colors.black26, // Otherwise, color is black26
                        ),
                      ),
                      onTap: () async {
                        if (testBox.containsKey(widget.eventid)) {
                          testBox.delete(widget.eventid);
                        } else {
                          testBox.put(widget.eventid, widget.eventid);
                        }

                        setState(
                            () {}); // Ensure UI updates after the bookmark state change
                      },
                    ),
                  )
                : Container(),

            // InkWell(
            //   onTap: () async {
            //     print("start");
            //     shareToInstagramStory();
            //     print("Start Over");
            //   },
            //   child: Semantics(
            //     label: 'Share Button',
            //     child: Container(
            //       margin: EdgeInsets.only(top: 16, bottom: 16, right: 23),
            //       child: Icon(Icons.share_outlined,
            //           size: 24, color: Color(0xff4A4545)),
            //     ),
            //   ),
            // )
          ],
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.filename != null && widget.filename!.length > 0
                        ? Container(
                            alignment: Alignment.topRight,
                            height: 220,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://maps.iwayplus.in/uploads/${widget.filename}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                          )
                        : Container(
                            alignment: Alignment.topRight,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/SessionDetail_defaultImage.jpg'),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 12),
                      width: screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Container(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff171717),
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 11),
                            child: Row(
                              children: [
                                Container(
                                    child: Icon(Icons.calendar_month,
                                        size: 24, color: Color(0xff282828))),
                                widget.date.isNotEmpty
                                    ? Container(
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff282828),
                                          ),
                                          textAlign: TextAlign.center,
                                        ))
                                    : Container(),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Container(
                                    child: Icon(Icons.access_time,
                                        size: 24, color: Color(0xff282828))),
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: Text(
                                    convertToAmPm(widget.time),
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff4A4545),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Container(
                                    child: Icon(Icons.location_on_outlined,
                                        size: 24, color: Color(0xff282828))),
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: Text(
                                    widget.loc,
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff282828),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                        width: screenWidth,
                        child: DefaultTabController(
                          length: 3, // Number of tabs
                          child: Scaffold(
                            appBar: const TabBar(
                              dividerColor: Color(0xffEBEBEB),
                              labelColor: Color(0xff171717),
                              // unselectedLabelColor: Color(0xff282828),
                              unselectedLabelStyle: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff282828)),
                              indicatorColor: Color(0xffECC113),
                              tabs: [
                                Tab(
                                    child: Text(
                                  "About",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    // fontWeight: FontWeight.w500,
                                    //  color: Color(0xff48246C),
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                                // Tab(
                                //     child: Text(
                                //       "Venue Map",
                                //       style: const TextStyle(
                                //         fontFamily: "Roboto",
                                //         fontSize: 16,
                                //         //  fontWeight: FontWeight.w400,
                                //         // color: Color(0xff48246C),
                                //       ),
                                //       textAlign: TextAlign.center,
                                //     )),
                                Tab(
                                    child: Text(
                                  "Co-ordinator",
                                  //  subeventwidgetlist.isNotEmpty?"Sub Events":"Co-Ordinators",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    //  fontWeight: FontWeight.w400,
                                    // color: Color(0xff48246C),
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                              ],
                            ),
                            body: TabBarView(
                              children: [
                                // Content of Tab 1
                                Container(
                                    //     margin: EdgeInsets.only(top : 16),
                                    padding: EdgeInsets.fromLTRB(18, 16, 18, 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: SingleChildScrollView(
                                        child: widget.description == ""
                                            ? Text(
                                                "No Description Available",
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
                                                  fontFamily: "Roboto",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff777777),
                                                ),
                                              )
                                            : Container(
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        screenWidth * 0.7),
                                                child: Text(
                                                  widget.description!,
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontFamily: "Roboto",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff777777),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    )),
                                // Content of Tab 2
                                // Container(
                                //     height: 150,
                                //     padding:
                                //     EdgeInsets.fromLTRB(18, 16, 18, 8),
                                //     width: screenWidth,
                                //     decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(6),
                                //       boxShadow: [
                                //         BoxShadow(
                                //             color: Colors.black26,
                                //             offset: Offset.zero,
                                //             spreadRadius: 0,
                                //             blurRadius: 4,
                                //             blurStyle: BlurStyle.outer)
                                //       ],
                                //     ),
                                //     child: FutureBuilder(
                                //       future: _loadMap(),
                                //       builder: (context, snapshot) {
                                //         if (snapshot.connectionState ==
                                //             ConnectionState.waiting) {
                                //           return Center(
                                //               child:
                                //               CircularProgressIndicator());
                                //         } else if (snapshot.hasError) {
                                //           return Center(
                                //               child:
                                //               Text('Error loading map'));
                                //         } else {
                                //           return Container(
                                //             // width: 237.0,
                                //             // height: 247.0,
                                //             child: GoogleMap(
                                //               onMapCreated: _onMapCreated,
                                //               initialCameraPosition:
                                //               CameraPosition(
                                //                 target: LatLng(
                                //                     15.49829, 73.82099),
                                //                 zoom: 16,
                                //               ),
                                //               markers: {
                                //                 Marker(
                                //                   markerId:
                                //                   MarkerId('Marker'),
                                //                   position: LatLng(
                                //                       15.49829, 73.82099),
                                //                   infoWindow: InfoWindow(
                                //                       title: 'Marker Title'),
                                //                 ),
                                //               },
                                //               onTap: (value) {
                                //                 _launchInBrowser(Uri.parse(
                                //                     'https://www.google.com/maps/dir/?api=1&destination=15.516698054561358, 73.83534886845493&travelmode=driving&dirflg=d'));
                                //               },
                                //               onCameraMove: (value) {
                                //                 print(value);
                                //               },
                                //             ),
                                //           );
                                //         }
                                //       },
                                //     )),
                                // Content of Tab 3
                                // subeventwidgetlist.isNotEmpty?
                                // Expanded(
                                //   child: Column(
                                //   children: subeventwidgetlist,
                                // )
                                // ):
                                GestureDetector(
                                  onTap: () {
                                    print("widget.speakerI");
                                    print(widget.speakerID);
                                    if (widget.speakerID != "" && widget.speakerID != null) {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             SpeakerProfileScreen(
                                      //               name: "",
                                      //               description: "",
                                      //               designation: "",
                                      //               fromCommiteePage: false,
                                      //               speakerID:
                                      //                   widget.speakerID!,
                                      //               fileName: null,
                                      //             )));
                                    }else{


                                    }
                                  },
                                  child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(18, 16, 18, 8),
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: Color(
                                                        0xFFB2EFE4), // Hex color with 0xFF prefix
                                                    shape: BoxShape
                                                        .circle, // Makes the container circular
                                                  ),
                                                  child: Icon(Icons
                                                      .person_outline_outlined),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth:
                                                                    screenWidth *
                                                                        0.7),
                                                        child: Text(
                                                          widget.speakerName ??
                                                              "",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                                0xff000000),
                                                          ),
                                                        ),
                                                      ),
                                                      // Container(
                                                      //   margin: EdgeInsets.only(top: 2),
                                                      //   child: Text(
                                                      //     'Coordinator 1 Desig.',
                                                      //     style: TextStyle(
                                                      //       fontFamily: 'Roboto',
                                                      //       fontSize: 16,
                                                      //       fontWeight: FontWeight.w400,
                                                      //       color: Color(
                                                      //           0xff282828),
                                                      //     ),
                                                      //   ),
                                                      // )
                                                    ],
                                                  ),
                                                ),
                                                // Spacer(),
                                                // Container(
                                                //   child: Icon(Icons.phone_outlined, size: 24, color: Color(0xffECC113),),
                                                // ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            (widget.hideDirectionButton ) ?Container():ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffECC113), // Button background color
                fixedSize: Size(screenWidth, 72), // Width and height
                padding: const EdgeInsets.only(bottom: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Square borders
                ),
              ),
              onPressed: () {
                NavigationSDK.startNavigation(
                  context,
                  data: {"venueName": "AIIMSJAMMU"},
                  appColor: const Color(0xFF0097A7),
                  closeApp: false,
                  locale: AppConfig.languageCode,
                  skipSplash: true,
                  mapType: MapProvider.mapLibre,
                  providers: {MapProvider.mapLibre: MaplibreMapProvider()},
                );
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Direction",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff171717),
                      ),
                    ),
                    Icon(Icons.turn_right_outlined, color: Color(0xff171717)), // Icon color
                  ],
                ),
              ),
            )

          ],
        ));
  }

  Future<void> _launchGoogleCalendar(
      String eventName, DateTime eventDateTime, String time) async {
    final url = Uri.parse(
        'https://www.google.com/calendar/render?action=TEMPLATE&text=$eventName&dates=${_formatDateTime(eventDateTime)}/${_formatDateTime(eventDateTime.add(Duration(hours: calculateDuration(time.substring(0, 5), time.substring(8, 13)).inHours)))}');

    _launchInBrowser(url);

    // if (await canLaunch(url)) {
    // await launch(url);
    // } else {
    // throw 'Could not launch $url';
    // }
  }

  Duration calculateDuration(String startTime, String endTime) {
    // Parse the time strings into DateTime objects
    DateTime startDateTime = DateTime.parse('2023-01-01 $startTime:00');
    print(startDateTime);
    print(startTime);
    print(endTime);
    DateTime endDateTime = DateTime.parse('2023-01-01 $endTime:00');

    // Calculate the duration between the two times
    Duration duration = endDateTime.difference(startDateTime);

    return duration;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}${_twoDigits(dateTime.month)}${_twoDigits(dateTime.day)}T${_twoDigits(dateTime.hour)}${_twoDigits(dateTime.minute)}00';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}

String convertToAmPm(String time) {
  // Split the time into hour and minute
  List<String> parts = time.split(":");
  int hour = int.parse(parts[0]);
  String minute = parts[1];

  // Determine if it's AM or PM
  String period = hour < 12 ? "AM" : "PM";

  // Adjust hour for 12-hour format
  hour = hour % 12;
  if (hour == 0) {
    hour = 12; // 12 AM or 12 PM
  }

  // Return formatted time with AM/PM
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

void showToast(String mssg) {
  Fluttertoast.showToast(
    msg: mssg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
