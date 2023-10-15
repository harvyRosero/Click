import 'package:flutter/material.dart';
import 'package:click_here/util/firebase.helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:click_here/util/app.styles.dart';
import 'package:click_here/screens/first.screen.dart';
import 'package:click_here/screens/profile.screen.dart';
import 'package:click_here/screens/winners.screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService firebaseService = FirebaseService();
  final pageController = PageController();

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const FirstPage(),
    const WinnersPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clover),
            label: 'Sorteo',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.trophy),
            label: 'Ganadores',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Perfil',
          ),
        ],
        selectedLabelStyle: const TextStyle(
          color: kPrimaryColor
        ),
        selectedIconTheme: const IconThemeData(
          color: kPrimaryColor, // aquí puede definir el color que desee
        ),
      ),
    );
  }

}

