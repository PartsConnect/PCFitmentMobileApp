import 'package:flutter/material.dart';
import 'package:pcfitment/component/button.dart';
import 'package:pcfitment/utils/constants.dart';

class CustomBottomSheet {
  static void showNoNetworkBottomSheet({
    required BuildContext context,
    required VoidCallback onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return SizedBox(
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(Constants.networkMsg),
                const Spacer(),
                Image.asset(
                  'assets/images/ic_no_internet.png',
                  // Replace with your image path
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Retry',
                            onPressed: onRetry,
                            isLoading: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add spacing between buttons if needed
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Cancel',
                            onPressed: () {
                              Navigator.pop(context); // Close bottom sheet
                            },
                            isLoading: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showNoRecordBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  Constants.noDataMsg,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Image.asset(
                  'assets/images/ic_no_data.jpg',
                  // Replace with your image path
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Cancel',
                            onPressed: () {
                              Navigator.pop(context); // Close bottom sheet
                            },
                            isLoading: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showSomethingWrongBottomSheet({
    required BuildContext context,
    required VoidCallback onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(Constants.somethingWrongMsg),
                const Spacer(),
                Image.asset(
                  'assets/images/ic_something_went_wrong.jpg',
                  // Replace with your image path
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Retry',
                            onPressed: onRetry,
                            isLoading: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add spacing between buttons if needed
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Cancel',
                            onPressed: () {
                              Navigator.pop(context); // Close bottom sheet
                            },
                            isLoading: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showTimeOutBottomSheet({
    required BuildContext context,
    required VoidCallback onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(Constants.timeOutMsg),
                const Spacer(),
                Image.asset(
                  'assets/images/ic_time_out.jpg',
                  // Replace with your image path
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Retry',
                            onPressed: onRetry,
                            isLoading: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add spacing between buttons if needed
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Cancel',
                            onPressed: () {
                              Navigator.pop(context); // Close bottom sheet
                            },
                            isLoading: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
