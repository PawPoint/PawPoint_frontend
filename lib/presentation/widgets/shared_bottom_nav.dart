import 'package:flutter/material.dart';

/// Shared bottom nav item used across multiple pages.
class NavItem extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : assert(
         icon != null || imagePath != null,
         'Either icon or imagePath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (imagePath != null) {
      iconWidget = ColorFiltered(
        colorFilter: isSelected
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
            : const ColorFilter.matrix([
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                0.3,
                0,
              ]),
        child: Image.asset(
          imagePath!,
          width: 26,
          height: 26,
          fit: BoxFit.contain,
        ),
      );
    } else {
      iconWidget = Icon(
        icon,
        size: 26,
        color: isSelected ? Colors.black : Colors.black26,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared bottom navigation bar widget.
/// Pass the current [selectedIndex] and an [onItemTapped] callback.
class SharedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const SharedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
              NavItem(
                imagePath: 'assets/images/nav_pets.jpg',
                label: 'Pets',
                isSelected: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
              NavItem(
                imagePath: 'assets/images/nav_booknow.png',
                label: 'Book',
                isSelected: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
              NavItem(
                imagePath: 'assets/images/nav_appointments.png',
                label: 'Appts',
                isSelected: selectedIndex == 3,
                onTap: () => onItemTapped(3),
              ),
              NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: selectedIndex == 4,
                onTap: () => onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
