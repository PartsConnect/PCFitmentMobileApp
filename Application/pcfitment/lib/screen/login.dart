import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcfitment/api/dashboard_api.dart';
import 'package:pcfitment/api/login_api.dart';
import 'package:pcfitment/component/button.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/database/database_helper.dart';
import 'package:pcfitment/model/lang_model.dart';
import 'package:pcfitment/screen/Dashboard.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/services/notification_services.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pcfitment/widgets/snackbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isObscured = true;
  bool? isAPITermCondition;
  bool? isAPIPrivacyPolicy;
  bool isTermCondition = false;
  bool isPrivacyPolicy = false;
  var tcUrl = '';
  var ppUrl = '';
  bool isShow = true;

  double loadingProgress = 0.0; // Declare loadingProgress here

  bool? isShowTCPP;
  bool isLoading = false;

  String loginUserEmailLbl = '';
  String loginUserPasswordLbl = '';
  String loginUserBtnLbl = '';
  String loginTermsLbl = '';
  String loginPPLbl = '';
  String loginCancelLbl = '';
  String loginAcceptLbl = '';

  NotificationServices notificationServices = NotificationServices();

  late AnimationController animationController;

  //late Animation<double> _opacityTween;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //    overlays: [SystemUiOverlay.bottom]);

    super.initState();
    notificationServices.getDeviceToken().then((value) => {
          PreferenceUtils.setFCMId(value),
          // ignore: avoid_print
          if (kDebugMode) {print('Device Token $value')}
        });

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();

    //_opacityTween = Tween<double>(begin: 1.0, end: 0.2).animate(
    //  CurvedAnimation(
    //    parent: _controller,
    //    curve: Curves.easeInOut,
    //  ),
    //);

    // Start the blinking animation
    //_controller.repeat(reverse: true);

    getDeviceDetails();
    languagesDetailsAPICall();
  }

  @override
  void dispose() {
    userEmailController.dispose();
    passwordController.dispose();
    animationController.dispose();

    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //    overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // Optional
    ));

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
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
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/ic_app_logo.png',
                    height: 100, // Set your desired height
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: userEmailController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      //labelText: AppLocalizations.of(context)!.loginUserNameLb,
                      labelText: loginUserEmailLbl.isNotEmpty
                          ? loginUserEmailLbl // Set labelText to loginUserEmail when it's not empty
                          : AppLocalizations.of(context)!.loginUserNameLb,
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      //labelText: AppLocalizations.of(context)!.loginPasswordLb,
                      labelText: loginUserPasswordLbl.isNotEmpty
                          ? loginUserPasswordLbl // Set labelText to loginUserEmail when it's not empty
                          : AppLocalizations.of(context)!.loginPasswordLb,
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                        child: GestureDetector(
                          onTap: toggleObscured,
                          child: Icon(
                            isObscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    obscureText: isObscured,
                  ),
                  Visibility(
                      visible:
                          isAPITermCondition != null && !isAPITermCondition!,
                      child: const SizedBox(height: 20)),
                  Visibility(
                    visible: isAPITermCondition != null && !isAPITermCondition!,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text(loginTermsLbl.isNotEmpty
                                ? loginTermsLbl
                                : "Terms & Condition"),
                            value: isTermCondition,
                            onChanged: (value) {
                              termsConditionBottomDialog(context);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                                horizontal: -4.0, vertical: -4.0),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            privacyPolicyBottomDialog(context);
                          },
                          child: Text(
                            loginPPLbl.isNotEmpty
                                ? loginPPLbl
                                : "Privacy Policy",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    //buttonText: AppLocalizations.of(context)!.loginBtnLb,
                    buttonText: loginUserBtnLbl.isNotEmpty
                        ? loginUserBtnLbl // Set labelText to loginUserEmail when it's not empty
                        : AppLocalizations.of(context)!.loginBtnLb,
                    onPressed: errorLens,
                    isLoading: isLoading,
                  ),

                  /*isLoading
                      ? Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.circular(25), // Make it rounded
                          ),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth:
                                3, // Adjust thickness of the progress bar
                          ),
                        )
                      : SizedBox(
                          height: 50, // Adjust the height of the button
                          width:
                              double.infinity, // Adjust the width of the button
                          child: ElevatedButton(
                            onPressed: () {
                              errorLens();
                            },
                            child: Text("Login"),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                return isLoading ? Colors.grey : Colors.red;
                              }),
                            ),
                          ),
                        ),*/

                  /*ElevatedButton(
                    onPressed: () {
                      errorLens();
                      },
                    child: Text(AppLocalizations.of(context)!.loginBtnLb),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void toggleObscured() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  bool isEmailValid(String email) {
    // Regular expression for basic email validation
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  Future<void> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (kDebugMode) {
        print(androidInfo.id);
      }
      PreferenceUtils.setDeviceId(androidInfo.id);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      PreferenceUtils.setDeviceId(iosInfo.identifierForVendor!);
    }
  }

  /*Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }*/

  Future<void> languagesDetailsAPICall() async {
    if (await Network.isConnected()) {
      try {
        if (context.mounted) {
          final response = await DashboardAPI.getLanguageDetailsAPICall(
              context,
              PreferenceUtils.getSystemLangCode(),
              PreferenceUtils.getDeviceId());

          if (response['StatusCode'] == 200) {
            setState(() {
              //List<dynamic> termsConditionList = response['data']['TermsAndConditionAndPrivacyPolicies'];

              isAPITermCondition = bool.parse(response['data']
                          ['TermsAndConditionAndPrivacyPolicies']
                      ['IsTermsAndConditionAccept']
                  .toString()
                  .toLowerCase());
              isAPIPrivacyPolicy = bool.parse(response['data']
                          ['TermsAndConditionAndPrivacyPolicies']
                      ['IsPrivacyPolicyAccept']
                  .toString()
                  .toLowerCase());
              tcUrl = response['data']['TermsAndConditionAndPrivacyPolicies']
                  ['TermsAndConditionLink'];
              ppUrl = response['data']['TermsAndConditionAndPrivacyPolicies']
                  ['PrivacyPolicyLink'];

              isTermCondition = isAPITermCondition!;
              isPrivacyPolicy = isAPIPrivacyPolicy!;

              PreferenceUtils.setTermsCondition(isTermCondition.toString());
              PreferenceUtils.setPrivacyPolicy(isPrivacyPolicy.toString());
            });

            //print("1" + isAPITermCondition.toString());
            //print("2" + isTermCondition.toString());
            //print("3" + isAPIPrivacyPolicy.toString());
            //print("4" + isPrivacyPolicy.toString());

            DatabaseHelper dbHelper = DatabaseHelper.instance;
            await dbHelper.deleteTable(DatabaseHelper.langTable);

            List<dynamic> languagesDetailsList =
                response['data']['LanguageWiseLabels'];
            List<LangModel> languagesData = languagesDetailsList
                .map((data) => LangModel.fromJson(data))
                .toList();
            await dbHelper.insertLang(languagesData);
            loginUserEmailLbl =
                await LanguageChange().strTranslatedValue('Useremail');
            loginUserPasswordLbl =
                await LanguageChange().strTranslatedValue('Password');
            loginUserBtnLbl =
                await LanguageChange().strTranslatedValue('Login');

            //loginTermsLbl =
            //    await LanguageChange().strTranslatedValue('Terms & Condition');
            //loginPPLbl =
            //    await LanguageChange().strTranslatedValue('Privacy Policy');

            loginCancelLbl =
                await LanguageChange().strTranslatedValue('Cancel');

            //loginAcceptLbl =
            //await LanguageChange().strTranslatedValue('Accept');

            setState(() {});
          } else {
            if (context.mounted) {
              snackBarErrorMsg(
                  context,
                  response != null
                      ? response['Message']
                      : 'Invalid response from server');
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          //snackBarErrorMsg(context, 'Please contact to system admin');
          snackBarErrorMsg(context, Constants.somethingWrongMsg);
        }
      }
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void errorLens() {
    try {
      if (userEmailController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter user email.");
      } else if (!isEmailValid(userEmailController.text)) {
        snackBarErrorMsg(context, "Please enter valid user email.");
      } else if (passwordController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter password.");
      } else if (!isTermCondition) {
        snackBarErrorMsg(context, "Please accept terms & condition");
      }
      /*else if (!isPrivacyPolicy) {
        snackBarErrorMsg(context, "Please accept privacy policy");
      }*/

      else {
        setState(() {
          isLoading = true;
        });

        //TODO : dio use API Call
        useDioLoginAPICall();

        //TODO : structures dio use API Call
        //_loginRequest(userEmailController.text, passwordController.text,
        //    PreferenceUtils.getFCMId(), PreferenceUtils.getDeviceId());
        //TODO : https use API Call
        //useHttpLoginAPICall();
      }
    } catch (e) {
      //print(e);
      snackBarErrorMsg(context, e.toString());
    }
  }

  void useDioLoginAPICall() async {
    if (await Network.isConnected()) {
      try {
        if (context.mounted) FocusScope.of(context).unfocus();
        if (context.mounted) {
          LoginAPI.loginAPICall(
                  context,
                  userEmailController.text,
                  passwordController.text,
                  PreferenceUtils.getFCMId(),
                  PreferenceUtils.getDeviceId(),
                  PreferenceUtils.getTermsCondition(),
                  PreferenceUtils.getPrivacyPolicy())
              .then((value) async {
            if (value['StatusCode'] == 200) {
              setState(() {
                isLoading = false;
              });

              PreferenceUtils.setAuthToken('Bearer ${value['data']['token']}');
              dynamic userIdValue = value['data']['Id'];
              String userIdAsString =
                  userIdValue != null ? userIdValue.toString() : '';
              PreferenceUtils.setLoginUserId(userIdAsString);
              PreferenceUtils.setLoginEmail(value['data']['Email']);
              PreferenceUtils.setLoginUserName(value['data']['TenantName']);
              PreferenceUtils.setLoginPassword(passwordController.text);

              insertDBLoginData(
                  context,
                  value['data']['TenantName'],
                  userEmailController.text,
                  passwordController.text,
                  userIdAsString,
                  value['Message']);
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
            handleError(error); // Handle any errors caught in the API call
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        handleError(e); // Handle any unexpected errors here
      }
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void useHttpLoginAPICall() {
    LoginAPI()
        .validUserAPI(
            email: userEmailController.text, password: passwordController.text)
        .then((value) => {
              if (value['StatusCode'] == 200)
                {
                  PreferenceUtils.setAuthToken(
                      'Bearer ${value['data']['token']}'),
                  PreferenceUtils.setLoginUserId(value['data']['Id']),
                  PreferenceUtils.setLoginEmail(value['data']['Email']),
                  PreferenceUtils.setLoginUserName(value['data']['TenantName']),
                  PreferenceUtils.setLoginPassword(passwordController.text),
                  Navigation.pushRemoveUntil(context, const DashboardPage()),
                  snackBarSuccessMsg(context, value['message']),
                }
              else
                {
                  snackBarErrorMsg(context, value['message']),
                },
            });
  }

  void handleError(error) {
    setState(() {
      isLoading = false;
    });

    if (error is BadRequestException) {
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
      snackBarErrorMsg(context, 'Unexpected error occurred.');
    }
  }

  void insertDBLoginData(BuildContext context, String username,
      String userEmail, String password, String userId, String msg) async {
    /*bool tableExists = await DatabaseHelper.instance.tableExists();

      print(tableExists);
      if (!tableExists) {
        // Create the table if it doesn't exist
        await DatabaseHelper.instance.createTable();
        // Perform other necessary tasks upon the first login
      }

      DatabaseHelper dbHelper = DatabaseHelper.instance;

      Map<String, dynamic> user = {
        DatabaseHelper.columnLoginUserName: username,
        DatabaseHelper.columnLoginUserEmail: userEmail,
        DatabaseHelper.columnLoginUserPassword: password,
        DatabaseHelper.columnLoginUserId: userId,
      };

      await dbHelper.insertUser(user);
      Navigation.pushRemoveUntil(context, const DashboardPage());
      snackBarSuccessMsg(context, msg);*/

    /*DatabaseHelper dbHelper = DatabaseHelper.instance;
      List<Map<String, dynamic>> existingUsers =
          await dbHelper.getUserByUserId(userId);

      if (existingUsers.isNotEmpty) {
        // Username already exists, show an error message or handle the scenario accordingly
        print('Username already exists!');
        Navigation.pushRemoveUntil(context, const DashboardPage());
        snackBarSuccessMsg(context, msg);
      } else {
        // Username doesn't exist, proceed with inserting the new user
        Map<String, dynamic> user = {
          DatabaseHelper.columnLoginUserName: username,
          DatabaseHelper.columnLoginUserEmail: userEmail,
          DatabaseHelper.columnLoginUserPassword: password,
          DatabaseHelper.columnLoginUserId: userId,
        };

        await dbHelper.insertUser(user);
        Navigation.pushRemoveUntil(context, const DashboardPage());
        snackBarSuccessMsg(context, msg);
      }*/

    DatabaseHelper dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> user = {
      DatabaseHelper.columnLoginUserName: username,
      DatabaseHelper.columnLoginUserEmail: userEmail,
      DatabaseHelper.columnLoginUserPassword: password,
      DatabaseHelper.columnLoginUserId: userId,
    };

    await dbHelper.insertUser(user).then((value) => {
          Navigation.pushRemoveUntil(context, const DashboardPage()),
          snackBarSuccessMsg(context, msg),
        });
    //Navigation.pushRemoveUntil(context, const DashboardPage());
    //snackBarSuccessMsg(context, msg);
  }

  void showWebView(BuildContext context) {
    final controller = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams())
      ..loadRequest(
          Uri.parse('https://pcfitmenttest.partsconnect.co/terms-condition'));

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Scaffold(
        body: WebViewWidget(
          controller: controller,
          gestureRecognizers: {Factory(() => EagerGestureRecognizer())},
        ),
      ),
    );
  }

  void termsConditionBottomDialog(BuildContext context) {
    final webViewController = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams())
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(tcUrl));

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
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
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Text(
                              loginTermsLbl.isNotEmpty
                                  ? loginTermsLbl
                                  : 'Terms & Condition',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 24,
                              color: Colors.black, // Adjust color as needed
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      LimitedBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: WebViewWidget(
                                controller: webViewController,
                                gestureRecognizers: {
                                  /*Factory<VerticalDragGestureRecognizer>(() {
                                    var recognizer = VerticalDragGestureRecognizer()
                                      ..onDown = (details) {
                                        setState(() {
                                          print('test');
                                        });
                                      }
                                      ..onEnd = (details) {
                                        setState(() {
                                          print('Welcome Flutter');
                                        });
                                      };
                                    return recognizer;
                                  }),*/
                                  Factory(() => EagerGestureRecognizer())
                                },
                              ),
                            ),
                            Visibility(
                              visible: false,
                              child: ListTile(
                                leading: isTermCondition
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ) // Show a checkmark for the selected user
                                    : null,
                                onTap: () {
                                  setState(() {
                                    isTermCondition = !isTermCondition;
                                    Navigator.pop(context);
                                    PreferenceUtils.setTermsCondition(
                                        isTermCondition.toString());
                                    if (context.mounted) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  });
                                },
                                title: Text(
                                  loginAcceptLbl.isNotEmpty
                                      ? loginAcceptLbl
                                      : 'Accept',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                //trailing: isTermCondition
                                //   ? const Icon(
                                //       Icons.check_circle,
                                //       color: Colors.green,
                                //     ) // Show a checkmark for the selected user
                                //   : null,
                              ),
                            ),
                            TextButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // Aligns the text and icon to the start and end of the row
                                children: [
                                  Text(
                                    loginAcceptLbl.isNotEmpty
                                        ? loginAcceptLbl
                                        : 'Accept',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (isTermCondition)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  isTermCondition = !isTermCondition;
                                  Navigator.pop(context);
                                  PreferenceUtils.setTermsCondition(
                                      isTermCondition.toString());
                                  if (context.mounted) {
                                    FocusScope.of(context).unfocus();
                                  }
                                });
                              },
                            ),
                            Visibility(
                              visible: false,
                              child: CheckboxListTile(
                                //dense: false,
                                title: Text(loginAcceptLbl.isNotEmpty
                                    ? loginAcceptLbl
                                    : "Accept"),
                                value: isTermCondition,
                                onChanged: (value) {
                                  setState(() {
                                    isTermCondition = value!;
                                    Navigator.pop(context);
                                    PreferenceUtils.setTermsCondition(
                                        isTermCondition.toString());
                                    if (context.mounted) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(
                                    horizontal: -4.0, vertical: -4.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void privacyPolicyBottomDialog(BuildContext context) {
    final controller = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams())
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(ppUrl));

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
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
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Text(
                              loginPPLbl.isNotEmpty
                                  ? loginPPLbl
                                  : 'Privacy Policy',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 24,
                              color: Colors.black, // Adjust color as needed
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      LimitedBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                        child: Column(
                          children: [
                            Expanded(
                              child: WebViewWidget(
                                controller: controller,
                                gestureRecognizers: {
                                  Factory(() => EagerGestureRecognizer())
                                },
                              ),
                            ),
                            TextButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    loginAcceptLbl.isNotEmpty
                                        ? loginAcceptLbl
                                        : 'Accept',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (isPrivacyPolicy)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  isPrivacyPolicy = !isPrivacyPolicy;
                                  Navigator.pop(context);
                                  PreferenceUtils.setPrivacyPolicy(
                                      isPrivacyPolicy.toString());
                                  if (context.mounted) {
                                    FocusScope.of(context).unfocus();
                                  }
                                });
                              },
                            ),
                            Visibility(
                              visible: false,
                              child: CheckboxListTile(
                                //dense: false,
                                title: Text(loginAcceptLbl.isNotEmpty
                                    ? loginAcceptLbl
                                    : "Accept"),
                                value: isPrivacyPolicy,
                                onChanged: (value) {
                                  setState(() {
                                    isPrivacyPolicy = value!;
                                    Navigator.pop(context);
                                    PreferenceUtils.setPrivacyPolicy(
                                        isPrivacyPolicy.toString());
                                    if (context.mounted) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(
                                    horizontal: -4.0, vertical: -4.0),
                              ),
                            )
                          ],
                        ),
                      ),
                      /*TextButton(
                        child: Text(
                          loginCancelLbl.isNotEmpty
                              ? loginCancelLbl
                              : AppLocalizations.of(context)!.dialogBtnMlYesLb,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
