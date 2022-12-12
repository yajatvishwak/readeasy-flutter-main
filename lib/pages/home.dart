// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readeasy/pages/reader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController fileTitleController = TextEditingController();
  String name = "";
  List<dynamic> pdfs = [
    {"filetitle": "as", "filename": "e70a50fc-04c7-44bb-bea5-78dd675df6ee.pdf"},
    {"filetitle": "as", "filename": "test.pdf"}
  ];

  @override
  void initState() {
    super.initState();
    getInitVals();
  }

  void getInitVals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "name";
    });
    Map payload = {"id": prefs.getString("id")};
    var url = Uri.parse(dotenv.env['BASEURL']! + 'getuserdetails');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload));
    if (response.statusCode == 200) {
      Map res = json.decode(response.body);
      print(res);
      if (res["code"] == "success") {
        setState(() {
          pdfs = res["items"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text(
                "Welcome " + name,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Enter file title"),
                  TextField(
                    controller: fileTitleController,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              print(result.files.single.path);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              var url =
                                  Uri.parse(dotenv.env['BASEURL']! + 'addpdf');
                              var request = http.MultipartRequest("POST", url);
                              request.fields['id'] =
                                  prefs.getString("id") ?? "";
                              request.fields['filetitle'] =
                                  fileTitleController.text;
                              request.files
                                  .add(new http.MultipartFile.fromBytes(
                                'pdf',
                                await File.fromUri(Uri.parse(
                                        result.files.single.path ?? ""))
                                    .readAsBytes(),
                              ));
                              request.send().then((response) {
                                if (response.statusCode == 200) getInitVals();
                              });
                            } else {
                              // User canceled the picker
                            }
                          },
                          child: Text("Add Pdf"))),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Your PDFs",
                style: TextStyle(fontSize: 24),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: pdfs.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                        elevation: 3,
                        shadowColor: Colors.blueGrey,
                        child: ListTile(
                          title: Text(pdfs[index]["filetitle"]),
                          subtitle: Text(pdfs[index]["filename"],
                              overflow: TextOverflow.ellipsis),
                          leading: IconButton(
                              onPressed: () {}, icon: Icon(Icons.book)),
                          trailing: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Reader(
                                      filename: pdfs[index]["filename"],
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.chevron_right_outlined)),
                        )),
                  );
                },
              )
            ],
          ),
        ),
      )),
    );
  }
}
