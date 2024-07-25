
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:translator/translator.dart';

class TranslatorWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  TranslatorWidget(
      this.text, {
        this.style,
        this.textAlign = TextAlign.start,
      });

  @override
  State<TranslatorWidget> createState() => _TranslatorWidgetState();
}

class _TranslatorWidgetState extends State<TranslatorWidget> {
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale?.languageCode ?? 'en';
  }

  Future<String> _translateText() async {
    final translator = GoogleTranslator();
    try {
      final translation = await translator.translate(
        widget.text,
        to: _currentLocale,
      );
      return translation.text;
    } catch (e) {
      return 'Error: Unable to translate';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocale == 'en') {
      return Text(
        widget.text,
        style: widget.style,
      );
    } else {
      return FutureBuilder<String>(
        future: _translateText(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink(); // or a CircularProgressIndicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              snapshot.data ?? 'No translation available',
              style: widget.style,
              textAlign: widget.textAlign,
            );
          }
        },
      );
    }
  }
}