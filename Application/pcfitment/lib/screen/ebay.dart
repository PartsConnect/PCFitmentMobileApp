import 'package:flutter/material.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/button.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class SubmitToeBayPage extends StatefulWidget {
  final String toolbarTitle;

  const SubmitToeBayPage({
    super.key,
    required this.toolbarTitle,
  });

  @override
  State<SubmitToeBayPage> createState() => _SubmitToeBayPageState();
}

class _SubmitToeBayPageState extends State<SubmitToeBayPage> {
  String titleLbl = '';
  String firstContentLbl = '';
  String secondContentLbl = '';
  String confirmContentLbl = '';
  String subConfirmContentLbl = '';
  String submitToEBayBtnLbl = '';
  String eBayLoginBtnLbl = '';

  String eBayUpgradePlanTitleLbl = '';
  String eBayUpgradePlanHeaderLbl = '';
  String eBayUpgradePlanSubHeaderLbl = '';
  String eBayUpgradePlanBodyLbl = '';

  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  String? isFirstLoginCheck;
  String? isSecondPlanCheck;
  String? isThirdCheck;
  String? isFourthCheck;

  bool isGetMyDetailsLoading = false;
  bool isUpdateMyDetailsLoading = false;

  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  @override
  void initState() {
    super.initState();
    dataLabelFetch();
    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            getSubmitToeBayAPICall();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      /*body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Visibility(visible: isEBayLogin, child: _buildUIeBayLogin()),
              Visibility(visible: true, child: _buildeBayUIContent()),
              Visibility(visible: true, child: _buildHideShowContent()),
            ],
          ),
        ),
      ),*/

      body: buildUIContentMain(),
    );
  }

  Widget buildUIContentMain() {
    if (internetConnectionCheck == null) {
      // Loading indicator while checking internet connection
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      );
    } else if (!internetConnectionCheck!) {
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
              SubmitToeBayPage(
                  toolbarTitle:
                      titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle));
        },
      );
    } else {
      // If there is internet, show the main content
      return buildUIContent();
    }
  }

  Widget buildUIContent() {
    return isGetMyDetailsLoading
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
        : buildUIeBayLoginOrNot();

    /*: Visibility(
            visible: isCheckAccess == 'yes',
            replacement: _buildAlerteBayUpgradePlan(),
            child: _buildUIeBayLoginOrNot(),
          );*/
  }

  Widget buildUIeBayLoginOrNot() {
    return Visibility(
      visible: isFirstLoginCheck == 'yes',
      replacement: Visibility(
        visible: isSecondPlanCheck == 'yes',
        replacement: Visibility(
          visible: isThirdCheck == 'yes',
          replacement: buildSuccessBlockContent(),
          child: buildSubmitBtnContent(),
        ),
        child: buildAlertBayUpgradePlan(),
      ),
      child: buildNotLoginEbay(),
    );
  }

  Widget buildNotLoginEbay() {
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
      //padding: const EdgeInsets.all(20.0),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              firstContentLbl.isNotEmpty
                  ? firstContentLbl
                  //: 'Your eBay access token has been expired, Please login and give us and access',
                  : 'You are not logged into eBay, Please go website & login after access this form for submit to eBay...',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
          const Visibility(
            visible: false,
            child: SizedBox(
              height: 20,
            ),
          ),
          Visibility(
            visible: false,
            child: CustomButton(
              buttonText:
                  eBayLoginBtnLbl.isNotEmpty ? eBayLoginBtnLbl : 'eBay Login',
              onPressed: () {},
              isLoading: false,
            ),
          )
        ],
      ),
    );
  }

  Widget buildAlertBayUpgradePlan() {
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
            eBayUpgradePlanTitleLbl.isNotEmpty
                ? eBayUpgradePlanTitleLbl
                : 'Upgrade Plan',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            eBayUpgradePlanHeaderLbl.isNotEmpty
                ? eBayUpgradePlanHeaderLbl
                : 'Before using eBay, please make sure that you have upgrade your PCFitment Plan into tiered plan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            eBayUpgradePlanSubHeaderLbl.isNotEmpty
                ? eBayUpgradePlanSubHeaderLbl
                : 'It looks like you have not subscribed tiered plan. Please upgrade your plan into tiered plan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            eBayUpgradePlanBodyLbl.isNotEmpty
                ? eBayUpgradePlanBodyLbl
                : 'To upgrade your plan, please click on below "Upgrade Now" button.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSuccessBlockContent() {
    return SingleChildScrollView(
      //padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    firstContentLbl.isNotEmpty
                        ? firstContentLbl
                        : '* The System will export/push fitments on eBay for vehicle type Car, Truck, Van, and Medium/Heavy Truck, Other than these will not reflect on eBay.',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    firstContentLbl.isNotEmpty
                        ? firstContentLbl
                        : '* The System will export/push only those part number which mapped with eBay Item ID.',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          eBayConfirmationUI(),
        ],
      ),
    );
  }

  Widget buildSubmitBtnContent() {
    return SingleChildScrollView(
      //padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    firstContentLbl.isNotEmpty
                        ? firstContentLbl
                        : '* The System will export/push fitments on eBay for vehicle type Car, Truck, Van, and Medium/Heavy Truck, Other than these will not reflect on eBay.',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    firstContentLbl.isNotEmpty
                        ? firstContentLbl
                        : '* The System will export/push only those part number which mapped with eBay Item ID.',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Visibility(
              visible: isFourthCheck == 'yes',
              replacement: buttonIsRed(),
              child: buttonIsGray(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonIsGray() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return Colors.grey;
            },
          ),
        ),
        child: Center(
          child: Text(submitToEBayBtnLbl.isNotEmpty
              ? submitToEBayBtnLbl
              : 'Submit To eBay'),
        ),
      ),
    );
  }

  Widget buttonIsRed() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            isUpdateMyDetailsLoading = true;
          });

          updateSubmitToeBayAPICall();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return isUpdateMyDetailsLoading ? Colors.grey : Colors.red;
            },
          ),
        ),
        child: isUpdateMyDetailsLoading
            ? Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
            : Center(
                child: Text(submitToEBayBtnLbl.isNotEmpty
                    ? submitToEBayBtnLbl
                    : 'Submit To eBay'),
              ),
      ),
    );
  }

  Widget eBayConfirmationUI() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 50,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                firstContentLbl.isNotEmpty
                    ? firstContentLbl
                    : 'Your eBay Store is up to date.',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                firstContentLbl.isNotEmpty
                    ? firstContentLbl
                    : 'There is nothing pending to submit.',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> dataLabelFetch() async {
    //titleLbl = await LanguageChange().strTranslatedValue('Submit To eBay');

    submitToEBayBtnLbl =
        await LanguageChange().strTranslatedValue('Submit To eBay');
    //eBayLoginBtnLbl =
    //await LanguageChange().strTranslatedValue('eBay Login');

    eBayUpgradePlanTitleLbl =
        await LanguageChange().strTranslatedValue('eBay Upgrade Plan');
    eBayUpgradePlanHeaderLbl =
        await LanguageChange().strTranslatedValue('eBay Upgrade Plan Header');
    eBayUpgradePlanSubHeaderLbl = await LanguageChange()
        .strTranslatedValue('eBay Upgrade Plan SubHeader');
    eBayUpgradePlanBodyLbl =
        await LanguageChange().strTranslatedValue('eBay Upgrade Plan Body');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  Future<void> getSubmitToeBayAPICall() async {
    setState(() {
      isGetMyDetailsLoading = true;
    });

    Map<String, dynamic> param = {
      'tenantID': PreferenceUtils.getLoginUserId(),
    };

    //TODO : Without Then Check
    /*var response = await DioClient().getQueryParam(getSubmiteBayUrl);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

    //TODO : Then Check
    DioClient()
        .getQueryParam(getSubmiteBayUrl, queryParams: param)
        .then((value) {
      if (value['StatusCode'] == 200) {
        setState(() {
          isGetMyDetailsLoading = false;
          isFirstLoginCheck = value['data']['msg'].toString().toLowerCase();
          isSecondPlanCheck =
              value['data']['ebaylimitreach'].toString().toLowerCase();
          isThirdCheck =
              value['data']['IsAvailableeBayFitment'].toString().toLowerCase();
          isFourthCheck =
              value['data']['IsPendingReq'].toString().toLowerCase();
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

  void updateSubmitToeBayAPICall() async {
    if (await Network.isConnected()) {
      if (context.mounted) FocusScope.of(context).unfocus();

      Map<String, dynamic> param = {
        'tenantID': PreferenceUtils.getLoginUserId(),
      };

      //TODO : Without Then Check
      /*var response = await DioClient()..post(updateSubmiteBayUrl,param);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

      //TODO : Then Check
      DioClient().post(updateSubmiteBayUrl, param).then((value) {
        if (value['StatusCode'] == 200 && value['Status'] == 'OK') {
          setState(() {
            isUpdateMyDetailsLoading = false;
          });

          snackBarSuccessMsg(context, value['Message']);

          getSubmitToeBayAPICall();
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
