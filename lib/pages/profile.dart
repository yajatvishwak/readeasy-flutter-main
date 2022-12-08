import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile();

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinitvals();
  }

  getinitvals() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString("username"));
    usernameController.text = prefs.getString("username") ?? "";
    passwordController.text = prefs.getString("password") ?? "";
    nameController.text = prefs.getString("name") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Edit Profile",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Username",
                  contentPadding: EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: "Password",
                  contentPadding: EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Name",
                  contentPadding: EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      Map payload = {
                        "username": usernameController.text,
                        "password": passwordController.text,
                        "name": nameController.text,
                        "uid": prefs.getString("uid")
                      };
                      var url =
                          Uri.parse(dotenv.env["BASEURL"]! + 'editprofile');
                      var response = await http.post(url,
                          headers: {"Content-Type": "application/json"},
                          body: json.encode(payload));
                      prefs.setString("name", nameController.text);
                      prefs.setString("username", usernameController.text);
                      prefs.setString("password", passwordController.text);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text("Saved"),
                                content: Text("Saved to db"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ));
                    },
                    child: Text("Save")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(onPressed: () {}, child: Text("Logout")),
              ),
            )
          ],
        ),
      ),
    )));
  }
}
