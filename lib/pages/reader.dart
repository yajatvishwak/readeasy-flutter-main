// ignore_for_file: prefer_const_constructors, no_logic_in_create_state

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:http/http.dart' as http;

class Reader extends StatefulWidget {
  final String filename;

  const Reader({Key? key, required this.filename}) : super(key: key);

  @override
  State<Reader> createState() => _ReaderState(filename);
}

class _ReaderState extends State<Reader> {
  String filename;
  _ReaderState(this.filename);

  String filetitle = "";
  double fontSize = 0.1;
  double spacing = 0.1;
  double rspacing = 0.1;
  bool ttsState = false;
  String selectedString = "";
  TextToSpeech tts = TextToSpeech();
  String parsedText = "";

  @override
  void initState() {
    super.initState();
    getParsedText();
  }

  void getParsedText() async {
    Map payload = {"filename": filename};
    var url = Uri.parse(dotenv.env['BASEURL']! + 'parsepdf');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload));
    if (response.statusCode == 200) {
      Map res = json.decode(response.body);
      String s = res["text"];
      if (res["code"] == "success") {
        setState(() {
          parsedText = s;
          filetitle = res["filetitle"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Showing " + filetitle),
            SizedBox(
              height: 20,
            ),
            Text("Font Size "),
            Slider(
                value: fontSize,
                onChanged: (val) {
                  setState(() {
                    fontSize = val;
                  });
                }),
            Text("Word Spacing "),
            Slider(
                value: spacing,
                onChanged: (val) {
                  setState(() {
                    spacing = val;
                  });
                }),
            Text("Line Spacing "),
            Slider(
                value: rspacing,
                onChanged: (val) {
                  setState(() {
                    rspacing = val;
                  });
                }),
            ElevatedButton(
                onPressed: () {
                  tts.stop();
                  tts.speak(parsedText);
                },
                child: Text("Read passage")),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        runSpacing: 5 + rspacing * 50,
                        spacing: 15.0 + spacing * 50,
                        children: parsedText
                            .split(" ")
                            .map((e) => TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.centerLeft),
                                onPressed: () {
                                  tts.stop();
                                  setState(() {
                                    selectedString = e;
                                  });
                                  tts.speak(e);
                                },
                                child: (selectedString == e
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            border: Border.all(
                                              color: Colors.blueAccent,
                                            )),
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            fontSize: 32 + fontSize * 100,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: "od",
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        e,
                                        style: TextStyle(
                                          fontSize: 32 + fontSize * 100,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "od",
                                          color: Colors.black,
                                        ),
                                      ))))
                            .toList(),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      )),
    );
  }
}
