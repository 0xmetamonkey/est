import 'package:flutter/material.dart';
import 'do_page.dart';
import 'give_page.dart';
import 'talk_page.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DoPage(),
    GivePage(),
    TalkPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt),
            label: 'Do',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections),
            label: 'Give',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent),
            label: 'Talk',
          ),
        ],
      ),
    );
  }
}
