import 'package:flutter/material.dart';
import 'package:pr1_mirror_wall_app/screens/javapoint_screen.dart';
import 'package:pr1_mirror_wall_app/screens/tutorialspoint_screen.dart';
import 'package:pr1_mirror_wall_app/screens/w3schools_screen.dart';
import 'package:pr1_mirror_wall_app/screens/wikipedia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    WikipediaScreen(),
    W3SchoolsScreen(),
    JavaPointsScreen(),
    TutorialPointsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
        elevation: 10,
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/wiki.png',scale: 15,),
            label: 'Wikipedia',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/w3.png',scale: 15,),
            label: 'W3Schools',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/java.png',scale: 6,),
            label: 'JavaPoints',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/tuto.png',scale: 15,),
            label: 'TutorialPoints',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
