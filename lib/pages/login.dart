// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readeasy/app.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login();

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  "ReadEasy",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Assistive Reader for dsylexic indiviuals"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Username',
                  ),
                  controller: usernameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                  controller: passwordController,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        print("clicked");
                        Map payload = {
                          "username": usernameController.text,
                          "password": passwordController.text
                        };
                        var url = Uri.parse(dotenv.env['BASEURL']! + "login");
                        print(url);

                        var response = await http.post(url,
                            headers: {"Content-Type": "application/json"},
                            body: json.encode(payload));
                        if (response.statusCode == 200) {
                          Map res = json.decode(response.body);
                          print(res);
                          if (res["code"] == "success") {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString("name", res["name"].toString());
                            prefs.setString(
                                "username", usernameController.text);
                            prefs.setString("id", res["id"].toString());
                            prefs.setString(
                                "password", passwordController.text);
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
                                content:
                                    Text(res["message"] ?? "Unable to auth"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Login")),
                ),
              )
            ]),
      ),
    );
  }
}
