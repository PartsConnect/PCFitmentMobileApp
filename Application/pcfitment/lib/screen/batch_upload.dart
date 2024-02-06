import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class BatchUploadPage extends StatefulWidget {
  const BatchUploadPage({super.key});

  @override
  State<BatchUploadPage> createState() => _BatchUploadPageState();
}

class _BatchUploadPageState extends State<BatchUploadPage> {
  String titleLbl = '';

  late bool isStep1Enabled;
  late bool isStep2Enabled;
  late bool isStep3Enabled;
  late bool isStep4Enabled;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    batchUploadCheckStatusAPICall();
    setState(() {
      isStep1Enabled = true;
      isStep2Enabled = false;
      isStep3Enabled = false;
      isStep4Enabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleLbl.isNotEmpty ? titleLbl : 'Batch Upload',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tabUIContent(),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
                color: Colors.red,
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(visible: isStep1Enabled, child: firstTabUIContent()),
              Visibility(visible: isStep2Enabled, child: secondTabUIContent()),
              Visibility(visible: isStep3Enabled, child: thirdTabUIContent()),
              Visibility(visible: isStep4Enabled, child: fourthTabUIContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabUIContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isStep1Enabled = true;
              isStep2Enabled = false;
              isStep3Enabled = false;
              isStep4Enabled = false;
            });
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      //isStep1Enabled ? Colors.grey[200] : Colors.black,
                      isStep1Enabled ? Colors.black : Colors.grey[200],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/icon/ic_upload.png',
                  width: 20,
                  height: 20,
                  //color: isStep1Enabled ? Colors.black : Colors.white,
                  color: isStep1Enabled ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Step 1',
                style: TextStyle(
                    color: isStep1Enabled ? Colors.black : Colors.grey[200],
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/icon/ic_right_arrow.png',
          width: 35,
          //height: 20,
          color: Colors.grey[200],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isStep1Enabled = false;
              isStep2Enabled = true;
              isStep3Enabled = false;
              isStep4Enabled = false;
            });
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      //isStep2Enabled ? Colors.grey[200] : Colors.black,
                      isStep2Enabled ? Colors.black : Colors.grey[200],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/icon/ic_filter.png',
                  width: 20,
                  height: 20,
                  //color: isStep2Enabled ? Colors.black : Colors.white,
                  color: isStep2Enabled ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Step 2',
                style: TextStyle(
                    color: isStep2Enabled ? Colors.black : Colors.grey[200],
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/icon/ic_right_arrow.png',
          width: 35,
          //height: 20,
          color: Colors.grey[200],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isStep1Enabled = false;
              isStep2Enabled = false;
              isStep3Enabled = true;
              isStep4Enabled = false;
            });
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      //isStep3Enabled ? Colors.grey[200] : Colors.black,
                      isStep3Enabled ? Colors.black : Colors.grey[200],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/icon/ic_download.png',
                  width: 20,
                  height: 20,
                  //color: isStep3Enabled ? Colors.black : Colors.white,
                  color: isStep3Enabled ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Step 3',
                style: TextStyle(
                    color: isStep3Enabled ? Colors.black : Colors.grey[200],
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/icon/ic_right_arrow.png',
          width: 35,
          //height: 20,
          color: Colors.grey[200],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isStep1Enabled = false;
              isStep2Enabled = false;
              isStep3Enabled = false;
              isStep4Enabled = true;
            });
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      //isStep4Enabled ? Colors.grey[200] : Colors.black,
                      isStep4Enabled ? Colors.black : Colors.grey[200],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/icon/ic_refresh.png',
                  width: 20,
                  height: 20,
                  //color: isStep4Enabled ? Colors.black : Colors.white,
                  color: isStep4Enabled ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Step 4',
                style: TextStyle(
                    color: isStep4Enabled ? Colors.black : Colors.grey[200],
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget firstTabUIContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prepare and Upload Data',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        const Visibility(
          visible: false,
          child: Text(
            'Prepare your data file using the PCFitment Excel Template , and save the completed file to your computer. Then upload your data on the right.',
            style: TextStyle(color: Colors.black),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Prepare your data file using the ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'PCFitment Excel Template',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (kDebugMode) {
                      print('abc');
                    }
                    //launch('https://www.example.com/pcfitment');
                  },
              ),
              const TextSpan(
                text:
                    ' , and save the completed file to your computer. Then upload your data on the right.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Brand Name ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
              TextSpan(
                text: '- MyNewFitm (GHNX)',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget secondTabUIContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Validation',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Once you’ve uploaded the file, our system will validate the data. You will receive an email once the validation process has been completed. This process can take up to a few hours.',
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(
          height: 25,
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Brand Name ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
              TextSpan(
                text: '- MyNewFitm (GHNX)',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Text(
          'Your file upload information :',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: const Text('File name',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const Text(
              ' : ',
            ),
            const Expanded(
              child: Text(
                'AcesTemplate_2.xlsx',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: const Text('Upload date & time',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const Text(
              ' : ',
            ),
            const Expanded(
              child: Text(
                '1/2/2024 1:09:16 AM Processed',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget thirdTabUIContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Data and Download Report',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          'The data from your uploaded file will be divided into two groups: Valid Data and Errors',
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(
          height: 25,
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Brand Name ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
              TextSpan(
                text: '- MyNewFitm (GHNX)',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.none,
                ),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Text(
          'Process Report:',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: const Text('Number of Vehicles Fitments',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const Text(
              ' : ',
            ),
            const Expanded(
              child: Text(
                '48',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: const Text('Number of Parts',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const Text(
              ' : ',
            ),
            const Expanded(
              child: Text(
                '1',
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: const Text('Number of Part Types',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const Text(
              ' : ',
            ),
            const Expanded(
              child: Text(
                '1',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget fourthTabUIContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Make Corrections and Repeat',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Using the Error Report downloaded in Step 3, fix any errors and repeat steps 1-3 to resubmit your file.',
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Future<void> batchUploadCheckStatusAPICall() async {
    if (await Network.isConnected()) {
      //TODO : Without Then Check
      /*var response = await DioClient().getQueryParam(getNotificationHistoryDetailsUrl);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

      //TODO : Then Check
      DioClient().getQueryParam(batchUploadCheckStatusUrl).then((value) {
        if (value['StatusCode'] == 200) {
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          snackBarErrorMsg(
              context,
              value != null
                  ? value['Message']
                  : 'Invalid response from server');
        }
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        handleError(error);
      });
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void handleError(error) {
    if (error is BadRequestException) {
      var message = error.message;
      snackBarErrorMsg(context, message!);
    } else if (error is TimeOutException) {
      var message = error.message;
      snackBarErrorMsg(context, message!);
    } else if (error is FetchDataException) {
      var message = error.message;
      snackBarErrorMsg(context, message!);
    } else if (error is ApiNotRespondingException) {
      snackBarErrorMsg(context, 'Oops! It took longer to respond.');
    } else if (error is UnAuthorizedException) {
      snackBarErrorMsg(context, 'Unauthorized request.');
    } else if (error is SocketException) {
      var message = error.message;
      snackBarErrorMsg(context, 'Socket error occurred: $message');
    } else {
      // Handle other unexpected errors
      snackBarErrorMsg(context, 'Unexpected error occurred.');
    }
  }
}
