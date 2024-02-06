import 'package:flutter/material.dart';

class DashboardIcon extends StatelessWidget {
  final String text;
  final String imagePath;
  final Color? iconColor; // New property for dynamic color
  final VoidCallback onPressed;

  const DashboardIcon({super.key,
    required this.text,
    required this.imagePath, // Updated constructor with imagePath
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconColor != null) // Conditionally apply ColorFiltered if iconColor is provided
            ColorFiltered(
              colorFilter: ColorFilter.mode(iconColor!, BlendMode.srcIn),
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          if (iconColor == null) // Show Image.asset without ColorFiltered if iconColor is null
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
