import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../../../screen/home.dart';
import 'profile.dart';
import '../../../../screen/search.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _currentIndex = 1; // Default to Home page
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = [
    MySearch(),
    MyHome(),
    MyProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: const Color.fromARGB(255, 100, 12, 5),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.search, color: Colors.white),
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        index: _currentIndex, // Ensure the right tab is highlighted
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
