import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/Translator.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});
  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }
  Future<void> sendMailto({
    String email = "mail@example.com",
  }) async {
    final String emailSubject = "Enter Subject ";
    final Uri parsedMailto = Uri.parse(
        "mailto:<$email>?subject=$emailSubject");

    if (!await launchUrl(
      parsedMailto,
      mode: LaunchMode.externalApplication,
    )) {
      throw "error";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TranslatorWidget(
          "Contact Us",
          style: const TextStyle(
            fontFamily: "Roboto",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xff000000),

          ),
          textAlign: TextAlign.left,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TranslatorWidget(
              "You can get in touch with us through below platforms.  Our team will reach out to you soon as it would it be possible.",
              style: const TextStyle(
                fontFamily: "Roboto",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xffa1a1aa),

              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            width: MediaQuery.sizeOf(context).width*0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffE5E7EB),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                SizedBox(height: 16,),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    TranslatorWidget(
                      "Customer Support",
                      style: const TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff000000),

                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 16,),
                InkWell(
                  onTap: (){
                    _makePhoneCall("+91 8899950166");
                  },

                  child: Row(
                    children: [
                      SizedBox(width: 16,),
                      Container(
                        width: 24,
                        height: 24,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: SvgPicture.asset('assets/images/call.svg'),
                      ),
                      SizedBox(width: 16,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          TranslatorWidget(
                            "Contact Number",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffa1a1aa),

                            ),
                            textAlign: TextAlign.left,
                          ),
                          TranslatorWidget(
                            "+91 8899950166",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),

                            ),
                            textAlign: TextAlign.left,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                InkWell(
                  onTap: (){
                    sendMailto(email: "info@aiimsjammu.edu.in");
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 16,),
                      Container(
                        width: 24,
                        height: 24,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: SvgPicture.asset('assets/images/mail.svg'),
                      ),
                      SizedBox(width: 16,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatorWidget(
                            "Mail us",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffa1a1aa),

                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8,),
                          TranslatorWidget(
                            "info@aiimsjammu.edu.in",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),

                            ),
                            textAlign: TextAlign.left,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                InkWell(
                  onTap: (){
                    _launchInWebView(Uri.parse("https://www.aiimsjammu.edu.in/"));
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 16,),
                      Container(
                        width: 24,
                        height: 24,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: SvgPicture.asset('assets/images/captive_portal.svg'),
                      ),
                      SizedBox(width: 16,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatorWidget(
                            "Website  ",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffa1a1aa),
                  
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8,),
                          TranslatorWidget(
                            "https://www.aiimsjammu.edu.in/",
                            style: const TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                  
                            ),
                            textAlign: TextAlign.left,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
