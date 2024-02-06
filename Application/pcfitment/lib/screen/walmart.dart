import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/button.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/date_format.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class SubmitToWalmartPage extends StatefulWidget {
  final String toolbarTitle;

  const SubmitToWalmartPage({
    super.key,
    required this.toolbarTitle,
  });

  @override
  State<SubmitToWalmartPage> createState() => _SubmitToWalmartPageState();
}

class _SubmitToWalmartPageState extends State<SubmitToWalmartPage> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController senderNameController = TextEditingController();
  TextEditingController senderPhoneController = TextEditingController();
  TextEditingController documentTitleController = TextEditingController();
  TextEditingController transferDtController = TextEditingController();
  TextEditingController effectiveDtController = TextEditingController();

  String? isVerified = '';
  String? isCheckAccess;

  bool isGetMyDetailsLoading = false;
  bool isUpdateMyDetailsLoading = false;

  String titleLbl = '';
  String companyNameLbl = '';
  String senderNameLbl = '';
  String senderPhoneLbl = '';
  String documentTitleLbl = '';
  String brandCodeLbl = '';
  String transferDtLbl = '';
  String effectiveDtLbl = '';
  String submitToAmazonBtnLbl = '';

  String walmartGuideTitleLbl = '';
  String walmartGuide1Lbl = '';
  String walmartGuide2Lbl = '';
  String walmartGuide3Lbl = '';

  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  String? selectedTransferDate;
  String? selectedEffectiveDate;

  String? brandCode;
  List brandCodeList = [];

  String id = '';
  String brandName = '';
  String createdDate = '';

  bool? internetCheck;
  bool? isDeviceConnected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInternetConnection();

    dataLableFetch();

    if (internetCheck != null && internetCheck!) {
      setState(() {
        isGetMyDetailsLoading = true;
      });

      multipleAPICall();
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    senderNameController.dispose();
    senderPhoneController.dispose();
    documentTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ),
        body: buildUIContent());
  }

  Widget buildUIContent() {
    if (internetCheck == null) {
      // Loading indicator while checking internet connection
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      );
    } else if (!internetCheck!) {
      // Show the no internet widget if there is no internet connection
      return CustomMsgShow(
        imagePath: 'assets/images/ic_no_internet.png',
        buttonText: retryBtnLbl.isNotEmpty ? retryBtnLbl : 'Retry',
        msgText: internetTitleLbl.isNotEmpty
            ? internetTitleLbl
            : Constants.networkTitleMsg,
        additionalText:
            internetMsgLbl.isNotEmpty ? internetMsgLbl : Constants.networkMsg,
        onPressed: () {
          Navigation.pushReplacement(
            context,
            SubmitToWalmartPage(
              toolbarTitle:
                  titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle,
            ),
          );
        },
      );
    } else {
      // If there is internet, show the main content
      return isGetMyDetailsLoading
          ? Center(
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  strokeWidth: 3,
                ),
              ),
            )
          : Visibility(
              visible: isCheckAccess == 'Yes',
              replacement: buildAlertWalmartGuide(),
              child: buildWalmartUI(),
            );
    }
  }

  // ignore: unused_element
  Widget buildUIContent1() {
    return internetCheck != null && internetCheck!
        ? isGetMyDetailsLoading
            ? Center(
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25), // Make it rounded
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 3, // Adjust thickness of the progress bar
                  ),
                ),
              )
            : Visibility(
                visible: isCheckAccess == 'Yes',
                replacement: buildAlertWalmartGuide(),
                child: buildWalmartUI(),
              )
        : noInternetWidget(onRetry: () {
            Navigation.pushReplacement(
                context,
                SubmitToWalmartPage(
                    toolbarTitle:
                        titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle));
          });
  }

  Widget noInternetWidget({required VoidCallback onRetry}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(5),
        // Adjust the value for desired roundness
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Offset to bottom-right
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
            'assets/images/ic_no_internet.png',
            // Replace with your Walmart image
            width: 100, // Adjust image width as needed
            height: 100, // Adjust image height as needed
          ),
          const SizedBox(height: 20),
          const Text(
            Constants.networkMsg,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          CustomButton(
            buttonText: 'Retry',
            onPressed: onRetry,
            isLoading: false,
          ),
        ],
      ),
    );
  }

  Widget buildAlertWalmartGuide() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(5),
        // Adjust the value for desired roundness
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Offset to bottom-right
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
            'assets/images/ic_alert.png', // Replace with your Walmart image
            width: 100, // Adjust image width as needed
            height: 100, // Adjust image height as needed
          ),
          const SizedBox(height: 20),
          Text(
            walmartGuideTitleLbl.isNotEmpty
                ? walmartGuideTitleLbl
                : 'Walmart Guide',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            walmartGuide1Lbl.isNotEmpty
                ? walmartGuide1Lbl
                : 'Before using Walmart submission, please make sure that you have made setup in your Walmart store as per their rules.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            walmartGuide2Lbl.isNotEmpty
                ? walmartGuide2Lbl
                : 'If you have any doubt to make setup please take a look at our helpdesk article "Submit Fitments on Walmart".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            walmartGuide3Lbl.isNotEmpty
                ? walmartGuide3Lbl
                : 'Once you\'re done with setup, please contact us at support@partsconnect.us to enable this service.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWalmartUI() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              enabled: true,
              controller: companyNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                //contentPadding: const EdgeInsets.symmetric(
                //    vertical: 8, horizontal: 12), // Padding inside the dropdown
                labelText:
                    companyNameLbl.isNotEmpty ? companyNameLbl : 'Company Name',
                prefixIcon: const Icon(Icons.business_sharp),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: senderNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                //contentPadding: const EdgeInsets.symmetric(
                //    vertical: 8, horizontal: 12), // Padding inside the dropdown
                labelText:
                    senderNameLbl.isNotEmpty ? senderNameLbl : 'Sender Name',
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: senderPhoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                //contentPadding: const EdgeInsets.symmetric(
                //    vertical: 8, horizontal: 12), // Padding inside the dropdown
                labelText:
                    senderPhoneLbl.isNotEmpty ? senderPhoneLbl : 'Sender Phone',
                prefixIcon: const Icon(Icons.phone_android_sharp),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: documentTitleController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                //contentPadding: const EdgeInsets.symmetric(
                //    vertical: 8, horizontal: 12), // Padding inside the dropdown
                labelText: documentTitleLbl.isNotEmpty
                    ? documentTitleLbl
                    : 'Document Title',
                prefixIcon: const Icon(Icons.document_scanner),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            transferDtFun(),
            const SizedBox(height: 20),
            effectiveDtFun(),
            const SizedBox(height: 20),
            brandCodeFun(),
            const SizedBox(height: 20),
            CustomButton(
              buttonText: submitToAmazonBtnLbl.isNotEmpty
                  ? submitToAmazonBtnLbl
                  : 'Submit To Walmart',
              onPressed: validation,
              isLoading: isUpdateMyDetailsLoading,
            )
          ],
        ),
      ),
    );
  }

  Widget brandCodeFun() {
    //FocusScope.of(context).unfocus();

    //brandCode ??= brandCodeList.isNotEmpty ? brandCodeList[0]['Value'] : null;

    Map<String, dynamic>? selectedBrand = brandCodeList.firstWhere(
      (item) => item['Value'] == brandCode,
      orElse: () => null,
    );

    Set<String> uniqueValues = {};

    brandCodeList = brandCodeList.where((item) {
      bool isUnique = uniqueValues.add(item["Value"]);
      return isUnique;
    }).toList();

    isVerified =
        selectedBrand != null ? selectedBrand['IsBrandVerifiedtxt'] : '';
    brandName = selectedBrand != null ? selectedBrand['Text'] : '';
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        isDense: false,
        //contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        prefixIcon: const Icon(Icons.code),
        labelText: brandCodeLbl.isNotEmpty ? brandCodeLbl : "Brand Code",
        /*Image.asset(
          "assets/icon/ic_home.png",
          scale: 10,
          color: Colors.black,
        ),*/
        //border: const OutlineInputBorder(),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Default border color
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black), // Border color when focused
        ),
      ),
      style: const TextStyle(color: Colors.black),
      /*hint: Text(
        brandCodeLbl.isNotEmpty ? brandCodeLbl : "Brand Code",
        textAlign: TextAlign.center,
      ),*/
      value: selectedBrand != null ? selectedBrand['Value'] : null,
      onChanged: (String? newValue) {
        setState(() {
          if (mounted) brandCode = newValue;
        });
      },
      items: brandCodeList.map((map) {
        return DropdownMenuItem<String>(
          value: map["Value"],
          child: Text(
            map["Text"],
          ),
        );
      }).toList(),
    );
  }

  Widget transferDtFun() {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        previousDateDisable(context, transferDtController);

        /*final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: selectedTransferDate != null
              ? DateTime.parse(selectedTransferDate!)
              : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            selectedTransferDate = pickedDate.toString(); // Convert to string
            transferDtController.text = yearMMMDDForm(selectedTransferDate!);
          });
        }*/
      },
      child: TextFormField(
        enabled: false,
        controller: transferDtController,
        decoration: InputDecoration(
          labelText: transferDtLbl.isNotEmpty ? transferDtLbl : 'Transfer Date',
          prefixIcon: const Icon(Icons.date_range),
          border: const OutlineInputBorder(),
          //contentPadding: const EdgeInsets.symmetric(
          //    vertical: 8, horizontal: 12), // Padding inside the dropdown
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget effectiveDtFun() {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        previousDateDisable(context, effectiveDtController);
        /*final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: selectedEffectiveDate != null
              ? DateTime.parse(selectedEffectiveDate!)
              : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            selectedEffectiveDate = pickedDate.toString(); // Convert to string
            effectiveDtController.text = yearMMMDDForm(selectedEffectiveDate!);
          });
        }*/
      },
      child: TextFormField(
        enabled: false,
        controller: effectiveDtController,
        decoration: InputDecoration(
          //contentPadding: const EdgeInsets.symmetric(
          //    vertical: 8, horizontal: 12), // Padding inside the dropdown
          labelText:
              effectiveDtLbl.isNotEmpty ? effectiveDtLbl : 'Effective Date',
          prefixIcon: const Icon(Icons.date_range),
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  void checkInternetConnection() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!mounted) return;
    setState(() {
      internetCheck = isDeviceConnected!;
    });

    InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        if (!mounted) return;
        setState(() {
          internetCheck = true;
          if (kDebugMode) {
            print(internetCheck);
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          internetCheck = false;
          if (kDebugMode) {
            print(internetCheck);
          }
        });
      }
    });
  }

  void validation() {
    try {
      if (companyNameController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter company name.");
      } else if (senderNameController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter sender name.");
      } else if (senderPhoneController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter sender phone.");
      } else if (documentTitleController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter document title.");
      } else if (brandCode!.isEmpty) {
        snackBarErrorMsg(context, "Please select brand code.");
      } else if (transferDtController.text.isEmpty) {
        snackBarErrorMsg(context, "Please select transfer date.");
      } else if (effectiveDtController.text.isEmpty) {
        snackBarErrorMsg(context, "Please select effective date.");
      } else {
        setState(() {
          isUpdateMyDetailsLoading = true;
        });

        updateSubmitToWalmartAPICall();

        /*if (isVerified == 'Yes') {
          updateSubmitToAmazonAPICall();
          print('submit to amazon');
        } else {
          updateSubmitToAmazonVerificationAPICall();
          print('verify submit to amazon');
        }*/
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void multipleAPICall() async {
    if (await Network.isConnected()) {
      getSubmitToWalmartAPICall();
      brandCodeWalmartAPICall();
    } else {
      setState(() {
        isGetMyDetailsLoading = false;
      });
      //if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  Future<void> brandCodeWalmartAPICall() async {
    Map<String, dynamic> param = {
      'tenantID': PreferenceUtils.getLoginUserId(),
    };

    //TODO : Without Then Check
    /*var response = await DioClient().getQueryParam(brandWalmartUrl);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

    //TODO : Then Check
    DioClient()
        .getQueryParam(brandWalmartUrl, queryParams: param)
        .then((value) {
      if (value['StatusCode'] == 200) {
        setState(() {
          brandCodeList.addAll(value['data']);
        });
      } else {
        snackBarErrorMsg(context,
            value != null ? value['Message'] : 'Invalid response from server');
      }
    }).catchError((error) {
      handleError(error);
    });
  }

  Future<void> dataLableFetch() async {
    //titleLbl = await LanguageChange().strTranslatedValue('Submit To Amazon');

    companyNameLbl = await LanguageChange().strTranslatedValue('Company Name');
    senderNameLbl = await LanguageChange().strTranslatedValue('Sender Name');
    senderPhoneLbl = await LanguageChange().strTranslatedValue('Sender Phone');
    documentTitleLbl =
        await LanguageChange().strTranslatedValue('Document Title');
    brandCodeLbl = await LanguageChange().strTranslatedValue('Brand Code');
    transferDtLbl = await LanguageChange().strTranslatedValue('Transfer Date');
    effectiveDtLbl =
        await LanguageChange().strTranslatedValue('Effective Date');

    submitToAmazonBtnLbl =
        await LanguageChange().strTranslatedValue('Submit To Walmart');

    walmartGuideTitleLbl =
        await LanguageChange().strTranslatedValue('Walmart Guide');
    walmartGuide1Lbl =
        await LanguageChange().strTranslatedValue('Walmart Guide Header');
    walmartGuide2Lbl =
        await LanguageChange().strTranslatedValue('Walmart Guide SubHeader');
    walmartGuide3Lbl =
        await LanguageChange().strTranslatedValue('Walmart Guide Body');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  Future<void> getSubmitToWalmartAPICall() async {
    setState(() {
      isGetMyDetailsLoading = true;
    });

    Map<String, dynamic> param = {
      'tenantID': PreferenceUtils.getLoginUserId(),
    };

    //TODO : Without Then Check
    /*var response = await DioClient().getQueryParam(getNotificationHistoryDetailsUrl);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

    //TODO : Then Check
    DioClient()
        .getQueryParam(getSubmitToWalmartUrl, queryParams: param)
        .then((value) {
      if (value['StatusCode'] == 200) {
        setState(() {
          isGetMyDetailsLoading = false;

          id = value['data']['headerid'];
          companyNameController.text = value['data']['company'];
          senderNameController.text = value['data']['sendername'];
          senderPhoneController.text = value['data']['senderphone'];
          documentTitleController.text = value['data']['documenttitle'];
          transferDtController.text = value['data']['transferdate'];
          brandCode = value['data']['brandaaiaid'];
          effectiveDtController.text = value['data']['effectivedate'];
          //createdDate = value['data']['createddate'];
          createdDate = '';
          isVerified = value['data']['IsBrandVerifiedtxt'];
          brandName = value['data']['BrandName'];
          isCheckAccess = value['data']['IsWalmartLogin'];
        });
      } else {
        setState(() {
          isGetMyDetailsLoading = false;
        });
        snackBarErrorMsg(context,
            value != null ? value['Message'] : 'Invalid response from server');
      }
    }).catchError((error) {
      setState(() {
        isGetMyDetailsLoading = false;
      });
      handleError(error);
    });
  }

  void updateSubmitToWalmartAPICall() async {
    if (await Network.isConnected()) {
      if (context.mounted) FocusScope.of(context).unfocus();

      Map<String, dynamic> param = {
        'headerid': id,
        'company': companyNameController.text,
        'sendername': senderNameController.text,
        'senderphone': senderPhoneController.text,
        'transferdate': transferDtController.text,
        'brandaaiaid': brandCode,
        'documenttitle': documentTitleController.text,
        'effectivedate': effectiveDtController.text,
        'tenantID': PreferenceUtils.getLoginUserId(),
        'createddate': createdDate,
        'IsBrandVerifiedtxt': isVerified,
        'BrandName': brandName,
        'IsWalmartLogin': isCheckAccess,
      };

      //TODO : Without Then Check
      /*var response = await DioClient()..post(updateSubmitToWwalmartUrl,param);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

      //TODO : Then Check
      DioClient().post(updateSubmitToWalmartUrl, param).then((value) {
        if (value['StatusCode'] == 200 && value['Status'] == 'OK') {
          setState(() {
            isUpdateMyDetailsLoading = false;
          });

          snackBarSuccessMsg(context, value['Message']);
          getSubmitToWalmartAPICall();
          //Navigator.pop(context);
        } else {
          setState(() {
            isUpdateMyDetailsLoading = false;
          });
          snackBarErrorMsg(
              context,
              value != null
                  ? value['Message']
                  : 'Invalid response from server');
        }
      }).catchError((error) {
        setState(() {
          isUpdateMyDetailsLoading = false;
        });
        handleError(error);
      });
    } else {
      setState(() {
        isUpdateMyDetailsLoading = false;
      });
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
