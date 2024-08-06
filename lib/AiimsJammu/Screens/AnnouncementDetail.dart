import 'package:flutter/material.dart';

import '../Widgets/Translator.dart';

class AnnouncementDetailsPage extends StatefulWidget {
  final String image;
  final String title;
  final String department;
  final String dateTime;
  final String article;

  const AnnouncementDetailsPage({
    Key? key,
    required this.image,
    required this.title,
    required this.department,
    required this.dateTime,
    required this.article,
  }) : super(key: key);

  @override
  State<AnnouncementDetailsPage> createState() => _AnnouncementDetailsPageState();
}

class _AnnouncementDetailsPageState extends State<AnnouncementDetailsPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          // IconButton(
          //   onPressed: () {
          //     setState(() {
          //       isFavorite = !isFavorite;
          //     });
          //   },
          //   icon: Icon(
          //     isFavorite ? Icons.favorite : Icons.favorite_border,
          //     color: isFavorite ? Colors.red : null,
          //   ),
          // ),
          // IconButton(
          //   onPressed: () {
          //
          //   },
          //   icon: Icon(
          //     Icons.share
          //   ),
          // ),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(widget.image.isNotEmpty)
              Image.network(
                'https://dev.iwayplus.in/uploads/${widget.image}',
                // width: 250,
                height: 140,
                fit: BoxFit.fitWidth,
              ),
            if(widget.image.isNotEmpty)
            SizedBox(height: 8,),

            TranslatorWidget(
              widget.title,
              style: TextStyle(
                color: Color(0xFF18181B),
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,

              ),
            ),

            SizedBox(height: 8),

            Row(
              children: [

                TranslatorWidget(
                  widget.department,
                  style: TextStyle(
                    color: Color(0xff0B6B94),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 8,),
                TranslatorWidget(
                  widget.dateTime,
                  style: TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 10,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: TranslatorWidget(
                  widget.article,
                  style: TextStyle(
                    color: Color(0xFF595967),
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,

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
