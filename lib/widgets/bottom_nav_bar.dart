import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlashyTabBar(
      animationCurve: Curves.linear,
      selectedIndex: currentIndex,
      iconSize: 30,
      showElevation: false, // Remove elevation for a flat design
      onItemSelected: onTap, // Call the passed-in tap handler
      items: [
        FlashyTabBarItem(
          icon: Icon(
            Icons.home,
            color: currentIndex == 0 ? Colors.blue : Colors.grey,
          ),
          title: const Text('Home'),
        ),
        FlashyTabBarItem(
          icon: Icon(
            Icons.business_center,
            color: currentIndex == 1 ? Colors.blue : Colors.grey,
          ),
          title: const Text('Business'),
        ),
        FlashyTabBarItem(
          icon: Icon(
            Icons.explore,
            color: currentIndex == 2 ? Colors.blue : Colors.grey,
          ),
          title: const Text('Explore'),
        ),
        FlashyTabBarItem(
          icon: Icon(
            Icons.person,
            color: currentIndex == 3 ? Colors.blue : Colors.grey,
          ),
          title: const Text('Profile'),
        ),
      ],
    );
  }
}
