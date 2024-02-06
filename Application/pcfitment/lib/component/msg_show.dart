import 'package:flutter/material.dart';
import 'package:pcfitment/component/button.dart';

class CustomMsgShow extends StatelessWidget {
  final String imagePath;
  final String buttonText;
  final String msgText;
  final String additionalText; // Add an additional text
  final VoidCallback onPressed;

  const CustomMsgShow({
    super.key,
    required this.imagePath,
    required this.buttonText,
    required this.msgText,
    required this.additionalText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 50),
           Text(
            msgText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10), // Adjust the spacing between the texts
          Text(
            additionalText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Visibility(
            visible: true,
            child: CustomButton(
              buttonText: buttonText,
              onPressed: onPressed,
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}
