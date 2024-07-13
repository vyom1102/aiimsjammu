import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iwaymaps/AiimsJammu/Screens/ContactUs.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/Translator.dart';
import 'PrivacyPolicy.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Future<void> sendMailto({
    String email = "mail@example.com",
  }) async {
    final String emailSubject = "Feedbacks";
    final Uri parsedMailto = Uri.parse(
        "mailto:<$email>?subject=$emailSubject");

    if (!await launchUrl(
      parsedMailto,
      mode: LaunchMode.externalApplication,
    )) {
      throw "error";
    }
  }
  Future<void> _shareContent(String text) async {
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 0.09,
          ),
        ),


      ),
      body: Column(
        children: [
          Semantics(
            label:"",
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>ContactUs()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/call.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Contact Us',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label:"",
            child: InkWell(
              onTap: () {

                _launchURL('https://play.google.com/store/apps/details?id=com.iwayplus.rgcinavigation');
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/kid_star.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Rate this app',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label:"",
            child: InkWell(
              onTap: (){
                sendMailto(email: "Support@iwayplus.com");
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/mail.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Send Feedbacks',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label:"",
            child: InkWell(
              onTap: (){
                _shareContent("https://play.google.com/store/apps/details?id=com.iwayplus.rgcinavigation");
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/share.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Share this app',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label:"",
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>PrivacyPolicy()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/profilePageAssets/article.svg'),
                    ),
                    const SizedBox(width: 12),
                    TranslatorWidget(
                      'Terms and Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: SvgPicture.asset('assets/images/arrow_forward_ios.svg'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
