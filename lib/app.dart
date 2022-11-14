// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:readeasy/pages/home.dart';
import 'package:readeasy/pages/profile.dart';

class App extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const App();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int currentIndex = 0;
  final screens = [Home(), Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() {
                currentIndex = index;
              }),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
          ]),
    );
  }
}
