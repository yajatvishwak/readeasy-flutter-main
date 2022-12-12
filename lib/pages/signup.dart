// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:readeasy/app.dart';
import 'package:readeasy/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup();

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController usernameEditing = TextEditingController();
  TextEditingController passwordEditing = TextEditingController();
  TextEditingController nameEditing = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  "Rentify",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Peer to peer renting platform"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: usernameEditing,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Username',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: passwordEditing,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameEditing,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Text("Not New here? Signin here")),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        Map payload = {
                          "username": usernameEditing.text,
                          "password": passwordEditing.text,
                          "name": nameEditing.text,
                        };
                        var url = Uri.parse(dotenv.env["BASEURL"]! + 'signup');
                        var response = await http.post(url,
                            headers: {"Content-Type": "application/json"},
                            body: json.encode(payload));
                        Map res = json.decode(response.body);
                        print(res);
                        if (response.statusCode == 200 &&
                            res["code"] == "success") {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("name", nameEditing.text);
                          prefs.setString("username", usernameEditing.text);
                          prefs.setString("id", res["id"].toString());
                          prefs.setString("password", passwordEditing.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const App()),
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Text("Unable to auth"),
                                    content: Text(
                                        res["message"] ?? "Unable to auth"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ));
                        }
                      },
                      child: const Text("Signup")),
                ),
              )
            ]),
      ),
    );
  }
}
