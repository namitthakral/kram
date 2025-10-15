import 'package:flutter/material.dart';

class CustomMainScreenWithBottomSheet extends StatelessWidget {
  const CustomMainScreenWithBottomSheet({
    required this.imagePath,
    required this.child,
    super.key,
  });
  final String imagePath;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    body: Stack(
      children: [
        // 🖼️ Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 📄 Bottom Sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 450,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: child, // 📌 Custom child widget
          ),
        ),
      ],
    ),
  );
}
