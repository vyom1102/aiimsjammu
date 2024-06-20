import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageCarouselWidget extends StatefulWidget {
  final List<ImageTextPair> imagesWithText;

  const ImageCarouselWidget({Key? key, required this.imagesWithText})
      : super(key: key);

  @override
  _ImageCarouselWidgetState createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    print(widget.imagesWithText);
    _pageController = PageController();
    // Start the automatic animation
    startAutoAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to animate to the next page
  void animateToNextPage() {
    if (_currentPage < widget.imagesWithText.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  // Function to start automatic animation
  void startAutoAnimation() {
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      animateToNextPage();
    });
  }
  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      ),
      height: 180,
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: widget.imagesWithText.map((pair) {
              return InkWell(
                onTap: (){
                  _launchInWebView(Uri.parse(pair.webUrl));
                },
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [

                    ClipRRect(
                      // borderRadius: BorderRadius.circular(20),
                      child:

                      Image.network(
                        'https://dev.iwayplus.in/uploads/${pair.image}',

                        fit: BoxFit.fill
                        ,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: MediaQuery.sizeOf(context).width * 0.4,
                      top: 20,
                      child: Column(
                        children: [
                          if(pair.text.isNotEmpty)
                            Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                // color: Colors.black.withOpacity(0.5),
                                child: Text(
                                  pair.text,
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,

                                  ),
                                  textAlign: TextAlign.left,
                                )),
                          if(pair.subText.isNotEmpty)
                            Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                color: Colors.transparent.withOpacity(0.2),
                                child: Text(
                                  pair.subText,
                                  style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,

                                  ),
                                  textAlign: TextAlign.left,
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imagesWithText.length, (index) {
                return Container(
                  width: _currentPage == index ? 40 : 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _currentPage == index
                        ? Colors.white
                        : Color(0xffE5E7EB),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageTextPair {
  final String image;
  final String text;
  final String subText;
  final String webUrl;

  ImageTextPair({required this.image,  this.text="", this.subText="" ,this.webUrl=""});
}
