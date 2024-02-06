import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pcfitment/api/my_account_api.dart';
import 'package:pcfitment/component/button.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/screen/pdf_view.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage>
    with SingleTickerProviderStateMixin {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController weChatIdController = TextEditingController();

  TextEditingController passwordTabEmailController = TextEditingController();
  TextEditingController passwordTabCaptchaController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  List<dynamic> partsList = [];
  int currentPage = 1;
  int totalPages = 0;

  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  List<Tab> list = [
    const Tab(
      icon: Icon(Icons.person),
      text: 'Person',
    ),
    const Tab(
      icon: Icon(Icons.password),
      text: 'Password',
    ),
    const Tab(
      icon: Icon(Icons.subscriptions),
      text: 'Subscription Plan',
    ),
    const Tab(
      icon: Icon(Icons.subscript),
      text: 'Ebay Plan',
    ),
    const Tab(
      icon: Icon(Icons.history),
      text: 'Billing History',
    ),
  ];

  //final _configFormKey = GlobalKey<FormState>();
  //final _localCaptchaController = LocalCaptchaController();

  bool isOldObscured = true;
  bool isNewObscured = true;
  bool isConfirmObscured = true;

  bool isGetMyDetailsLoading = false;
  bool isUpdateMyDetailsLoading = false;
  bool isResetPasswordLoading = false;

  String myAccountLbl = '';
  String personLbl = '';
  String personFirstNameLbl = '';
  String personLastNameLbl = '';
  String personEmailLbl = '';
  String personPhoneNoLbl = '';
  String personWeChatIdLbl = '';
  String personUpdateInfoBtnLbl = '';
  String passwordLbl = '';
  String oldPasswordLbl = '';
  String newPasswordLbl = '';
  String confirmPasswordLbl = '';
  String resetPasswordLbl = '';
  String billingHistoryLbl = '';
  String billingDtLbl = '';
  String billingYourPlanLbl = '';

  String invoiceLbl = '';
  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';
  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Create TabController for getting the index of current tab
    //_tabController = TabController(length: 5, vsync: this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(handleTabSelection);

    emailController.text = PreferenceUtils.getLoginEmail();

    dataLableFetch();

    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            setState(() {
              isGetMyDetailsLoading = true;
            });

            getUserDetailsAPICall();
          }
        });
      }
    });

    /*setState(() {
      isGetMyDetailsLoading = true;
    });

    getUserDetailsAPICall();*/

    //fetchData();
    _scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    //_localCaptchaController.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNoController.dispose();
    weChatIdController.dispose();

    passwordTabEmailController.dispose();
    passwordTabCaptchaController.dispose();

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();

    //_emailFocusNode.dispose();
    //_captchaFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child:
            /*SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TabBar(
                isScrollable: true, // Allows horizontal scrolling
                controller: _tabController,
                tabs: TabValues.getTabs(context),
              ),
            ),*/

            TabBar(
              controller: _tabController,
              tabs: TabValues.getTabs(
                  context, personLbl, passwordLbl, billingHistoryLbl),
            ),
          ),
          title: Text(
              myAccountLbl.isNotEmpty
                  ? myAccountLbl
                  : AppLocalizations.of(context)!.myAcToolbarTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ),
        body: buildUIContent()
      /*TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          controller: _tabController,
          children: [
            _buildFirstTabContent(),
            _buildSecondTabContentChange(),
            _buildBillingTabContent(partsList),
            //_buildThirdTabContent(),
            //_buildFourthTabContent(),
            //_buildFifthTabContent(),
          ],
        )*/
    );
  }

  Widget buildUIContent() {
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
          Navigation.pushReplacement(context, const MyAccountPage());
        },
      );
    } else {
      // If there is internet, show the main content
      return TabBarView(
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        controller: _tabController,
        children: [
          buildFirstTabContent(),
          buildSecondTabContentChange(),
          buildBillingTabContent(partsList),
          //_buildThirdTabContent(),
          //_buildFourthTabContent(),
          //_buildFifthTabContent(),
        ],
      );
    }
  }

  Widget buildFirstTabContent() {
    return isGetMyDetailsLoading
        ? Container(
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
    )
        : SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: firstNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: personFirstNameLbl.isNotEmpty
                    ? personFirstNameLbl
                    : AppLocalizations.of(context)!
                    .myAcPersonTabFirstName,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: lastNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: personLastNameLbl.isNotEmpty
                    ? personLastNameLbl
                    : AppLocalizations.of(context)!.myAcPersonTabLastName,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: false,
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: personEmailLbl.isNotEmpty
                    ? personEmailLbl
                    : AppLocalizations.of(context)!.myAcPersonTabEmail,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneNoController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: personPhoneNoLbl.isNotEmpty
                    ? personPhoneNoLbl
                    : AppLocalizations.of(context)!.myAcPersonTabPhoneNo,
                prefixIcon: const Icon(Icons.phone_android_sharp),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: weChatIdController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: personWeChatIdLbl.isNotEmpty
                    ? personWeChatIdLbl
                    : AppLocalizations.of(context)!.myAcPersonTabWeChatId,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              buttonText: personUpdateInfoBtnLbl.isNotEmpty
                  ? personUpdateInfoBtnLbl
                  : AppLocalizations.of(context)!
                  .myAcPersonTabBtnUpdateInfo,
              onPressed: validationPersonTab,
              isLoading: isUpdateMyDetailsLoading,
            ),

            /*SizedBox(
              width: double.infinity, // Match parent width
              child: ElevatedButton(
                onPressed: () {
                  //updateUserDetailsAPICall();
                  validationPersonTab();
                },
                child: Text(
                    AppLocalizations.of(context)!.myAcPersonTabBtnUpdateInfo),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget buildSecondTabContentChange() {
    return SizedBox(
      child: SingleChildScrollView(
        //reverse: true, // To make the keyboard behavior smoother
        //padding: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: oldPasswordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: oldPasswordLbl.isNotEmpty
                      ? oldPasswordLbl
                      : AppLocalizations.of(context)!.myAcPasswordOld,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: oldToggleObscured,
                      child: Icon(
                        isOldObscured
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                obscureText: isOldObscured,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: newPasswordLbl.isNotEmpty
                      ? newPasswordLbl
                      : AppLocalizations.of(context)!.myAcPasswordNew,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: newToggleObscured,
                      child: Icon(
                        isNewObscured
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                obscureText: isNewObscured,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: confirmPasswordLbl.isNotEmpty
                      ? confirmPasswordLbl
                      : AppLocalizations.of(context)!.myAcPasswordConfirm,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: GestureDetector(
                      onTap: confirmToggleObscured,
                      child: Icon(
                        isConfirmObscured
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                obscureText: isConfirmObscured,
              ),
              const SizedBox(height: 20),
              CustomButton(
                  buttonText: resetPasswordLbl.isNotEmpty
                      ? resetPasswordLbl
                      : AppLocalizations.of(context)!.myAcPasswordBtnRP,
                  onPressed: validationResetPasswordTab,
                  isLoading: isResetPasswordLoading)

              /*SizedBox(
                width: double.infinity,
                child: isResetPasswordLoading
                    ? const CircularProgressIndicator() // Show circular progress indicator if _isLoading is true
                    : ElevatedButton(
                        onPressed: () {
                          // Call the method to handle password reset
                          // For example, here it's validationPasswordTab()
                          setState(() {
                            isResetPasswordLoading =
                                true; // Set loading state to true on button press
                          });
                          validationResetPasswordTab().then((success) {
                            // After the password reset logic completes
                            setState(() {
                              isResetPasswordLoading = false; // Set loading state to false
                            });
                            // Handle success message display or further actions
                          });
                        },
                        child: Text(
                            AppLocalizations.of(context)!.myAcPasswordBtnRP),
                      ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBillingTabContent(List<dynamic> fitmentsData) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (fitmentsData.isNotEmpty)
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: fitmentsData.length,
              itemBuilder: (context, index) {
                if (index < fitmentsData.length) {
                  final part = fitmentsData[index];
                  return buildFifthCardTabContent(
                      part['ActiveDate'],
                      part['PlanName'],
                      part['Amount'],
                      part['InvoiceUrl'],
                      index);
                } else {
                  // Handle the case when the index is out of bounds
                  return const SizedBox(); // or any other placeholder widget
                }
              },
            ),
          ),
        if (isLoading)
        /*const Center(
                  child: CircularProgressIndicator(),
                ),*/
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 3, // Adjust thickness of the progress bar
            ),
          ),
      ],
    );
  }

  Widget buildFifthCardTabContent(
      String date, String plan, String amount, String path, int index) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          if (kDebugMode) {
            print(amount);
            print(path);
          }
          if(path.isNotEmpty){
            Navigation.push(
                context,
                PDFViewPage(
                  toolbarTitle: invoiceLbl.isNotEmpty ? invoiceLbl : 'Invoice',
                  url: path,
                ));
          }else{
            snackBarErrorMsg(context, 'Invoice is not available');
          }
        },
        child: Container(
          //color: Theme.of(context).cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(
                        billingDtLbl.isNotEmpty
                            ? billingDtLbl
                            : AppLocalizations.of(context)!.myAcBHBillingDt,
                      ),
                    ),
                    const Text(
                      ' : ',
                    ),
                    Expanded(
                      child: Text(
                        date,
                      ),
                    ),
                  ],
                ),
                /*const Divider(
                  thickness: 0.25,
                  color: Colors.red,
                ),*/
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: false,
                  child: Container(
                    height: 0.25,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: Colors.red, // Replace with your desired color
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(
                        billingYourPlanLbl.isNotEmpty
                            ? billingYourPlanLbl
                            : AppLocalizations.of(context)!
                            .myAcBHBillingYourPlan,
                      ),
                    ),
                    const Text(
                      ' : ',
                    ),
                    Expanded(
                      child: Text(
                        plan,
                      ),
                    ),
                  ],
                ),
                /*const Divider(
                  thickness: 0.25,
                  color: Colors.red,
                ),*/
                Visibility(
                  visible: false,
                  child: Container(
                    height: 0.25,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: Colors.red, // Replace with your desired color
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> dataLableFetch() async {
    myAccountLbl = await LanguageChange().strTranslatedValue('My Account');

    personLbl = await LanguageChange().strTranslatedValue('Person');
    personFirstNameLbl =
    await LanguageChange().strTranslatedValue('First Name');
    personLastNameLbl = await LanguageChange().strTranslatedValue('Last Name');
    personEmailLbl = await LanguageChange().strTranslatedValue('Email');
    personPhoneNoLbl = await LanguageChange().strTranslatedValue('Phone No');
    personWeChatIdLbl = await LanguageChange().strTranslatedValue('WeChat ID');
    personUpdateInfoBtnLbl =
    await LanguageChange().strTranslatedValue('Update Info');

    passwordLbl = await LanguageChange().strTranslatedValue('Password');
    oldPasswordLbl = await LanguageChange().strTranslatedValue('Old Password');
    newPasswordLbl = await LanguageChange().strTranslatedValue('New Password');
    confirmPasswordLbl =
    await LanguageChange().strTranslatedValue('Confirm Password');
    resetPasswordLbl =
    await LanguageChange().strTranslatedValue('Reset Password');

    billingHistoryLbl =
    await LanguageChange().strTranslatedValue('Billing History');
    billingDtLbl = await LanguageChange().strTranslatedValue('Billing Date');
    billingYourPlanLbl = await LanguageChange().strTranslatedValue('Your Plan');
    invoiceLbl = await LanguageChange().strTranslatedValue('Invoice');

    internetTitleLbl =
    await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
    await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  void oldToggleObscured() {
    setState(() {
      isOldObscured = !isOldObscured;
    });
  }

  void newToggleObscured() {
    setState(() {
      isNewObscured = !isNewObscured;
    });
  }

  void confirmToggleObscured() {
    setState(() {
      isConfirmObscured = !isConfirmObscured;
    });
  }

  void validationPersonTab() {
    try {
      if (firstNameController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter first name.");
      } else if (lastNameController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter last name.");
      } else if (emailController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter email address.");
      } else if (phoneNoController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter phone no.");
      } else if (phoneNoController.text.length < 10) {
        snackBarErrorMsg(context, "Please enter valid phone no.");
      } else if (weChatIdController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter we chant id.");
      } else {
        setState(() {
          isUpdateMyDetailsLoading = true;
        });

        updateUserDetailsAPICall();
      }
    } catch (e) {
      //print(e);
      snackBarErrorMsg(context, e.toString());
    }
  }

  void validationResetPasswordTab() async {
    try {
      if (oldPasswordController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter old password.");
      } else if (newPasswordController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter new password.");
      } else if (confirmPasswordController.text.isEmpty) {
        snackBarErrorMsg(context, "Please enter confirm password.");
      } else if (newPasswordController.text != confirmPasswordController.text) {
        snackBarErrorMsg(
            context, "Confirm Password' And New Password Do Not Match...");
      } else {
        setState(() {
          isResetPasswordLoading = true;
        });

        resetPasswordAPICall();
      }
    } catch (e) {
      //print(e);
      snackBarErrorMsg(context, e.toString());
    }
  }

  void scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      loadMoreData();
    }
  }

  void getUserDetailsAPICall() async {
    if (await Network.isConnected()) {
      if (context.mounted) {
        await MyAccountAPI.personTabDetailsAPICall(context).then((value) {
          if (value['StatusCode'] == 200) {
            //fetchUserDetailsFromAPI(
            //    value['data']['FirstName'], value['data']['LastName'],
            //    value['data']['Email'], value['data']['Phone'],
            //    value['data']['WeChatID']);

            setState(() {
              firstNameController.text = value['data']['FirstName'];
              lastNameController.text = value['data']['LastName'];
              //emailController.text = value['data']['Email'];
              phoneNoController.text = value['data']['Phone'];
              weChatIdController.text = value['data']['WeChatID'];

              isGetMyDetailsLoading = false;
            });

            //snackBarSuccessMsg(context, value['Message']);
          } else {
            setState(() {
              isGetMyDetailsLoading = false;
            });

            snackBarErrorMsg(
                context,
                value != null
                    ? value['Message']
                    : 'Invalid response from server');
          }
        });
      }
    } else {
      setState(() {
        isGetMyDetailsLoading = false;
      });
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void fetchUserDetailsFromAPI(String firstName, String lastName, String email,
      String phone, String weChatId) {
    Future.delayed(const Duration(seconds: 2), () {
      Map<String, dynamic> userDetails = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNo': phone,
        'weChatId': weChatId
      };

      firstNameController.text = userDetails['firstName'];
      lastNameController.text = userDetails['lastName'];
      //emailController.text = userDetails['email'];
      phoneNoController.text = userDetails['phoneNo'];
      weChatIdController.text = userDetails['weChatId'];

      isGetMyDetailsLoading = false;
    });
  }

  void updateUserDetailsAPICall() async {
    if (await Network.isConnected()) {
      if (context.mounted) FocusScope.of(context).unfocus();
      if (context.mounted) {
        MyAccountAPI.updatePersonTabDetailsAPICall(
                context,
                PreferenceUtils.getLoginUserId(),
                firstNameController.text,
                lastNameController.text,
                phoneNoController.text,
                weChatIdController.text)
            .then((value) {
          if (value['StatusCode'] == 200) {
            snackBarSuccessMsg(context, value['Message']);
            getUserDetailsAPICall();

            setState(() {
              isUpdateMyDetailsLoading = false;
            });
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
        });
      }
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void resetPasswordAPICall() async {
    if (await Network.isConnected()) {
      if (context.mounted) FocusScope.of(context).unfocus();
      if (context.mounted) {
        MyAccountAPI.resetPasswordAPICall(
                context,
                PreferenceUtils.getLoginUserId(),
                oldPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text)
            .then((value) {
          if (value['StatusCode'] == 200) {
            setState(() {
              isResetPasswordLoading = false;
            });

            Navigator.pop(context);
            snackBarSuccessMsg(context, value['Message']);
          } else {
            setState(() {
              isResetPasswordLoading = false;
            });

            snackBarErrorMsg(
                context,
                value != null
                    ? value['Message']
                    : 'Invalid response from server');
          }
        });
      }
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          buildFirstTabContent();
          break;
        case 1:
          buildSecondTabContentChange();
          break;
        case 2:
          partsList.clear();
          fetchData();
          //loadMoreData();
          buildBillingTabContent(partsList);
          break;

        /*case 3:
          _buildFourthTabContent();
          break;
        case 4:
          //_buildFifthTabContent();
          _buildFifthCardTabContent();
          break;*/
      }
    }
  }

  Future<void> fetchData() async {
    if (await Network.isConnected()) {
      try {
        setState(() {
          isLoading = true;
        });
        if (context.mounted) {
          final response = await MyAccountAPI.getBillingHistoryAPICall(context,
              currentPage.toString(), PreferenceUtils.getLoginUserId());

          if (response['StatusCode'] == 200) {
            setState(() {
              totalPages = response['totalPages'];
              /*if (currentPage == 1) {
            partsList = response['data'];
          } else {
            partsList.addAll(response['data']);
          }*/

              partsList.addAll(response['data']);
            });
            // Dismiss the progress indicator after data is set
            setState(() {
              isLoading = false;
            });
          } else {
            if (context.mounted) {
              snackBarErrorMsg(
                  context,
                  response != null
                      ? response['Message']
                      : 'Invalid response from server');
            }
            setState(() {
              isLoading =
                  false; // Dismiss the progress indicator in case of error
            });
          }
        }
      } on DioError catch (e) {
        if (e.type == DioErrorType.connectTimeout) {
        } else {}
        setState(() {
          isLoading = false; // Dismiss the progress indicator in case of error
        });
      } catch (e) {
        setState(() {
          isLoading = false; // Dismiss the progress indicator in case of error
        });
        if (context.mounted) {
          snackBarErrorMsg(context, 'Error fetching data: $e');
        }
      }
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  Future<void> loadMoreData() async {
    try {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });

        currentPage++;
        await fetchData();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class ConfigFormData {
  String chars = 'abdefghnryABDEFGHNQRY3468';
  int length = 6;
  double fontSize = 0;
  bool caseSensitive = false;
  Duration codeExpireAfter = const Duration(minutes: 10);

  @override
  String toString() {
    return '$chars$length$caseSensitive${codeExpireAfter.inMinutes}';
  }
}

class TabValues {
  static List<Tab> getTabs(BuildContext context, String person, String password,
      String billingHistory) {
    return [
      Tab(
        icon: const Icon(Icons.person),
        text: person.isNotEmpty
            ? person
            : AppLocalizations.of(context)!.myAcPersonTabLb,
      ),
      Tab(
        icon: const Icon(Icons.password),
        text: password.isNotEmpty
            ? password
            : AppLocalizations.of(context)!.myAcPasswordTabLb,
      ),
      Tab(
        icon: const Icon(Icons.history),
        text: billingHistory.isNotEmpty
            ? billingHistory
            : AppLocalizations.of(context)!.myAcBillingHistoryTabLb,
      ),
      /*Tab(
        icon: const Icon(Icons.subscriptions),
        text: AppLocalizations.of(context)!.myAcSubscriptionPlanTabLb,
      ),
      Tab(
        icon: const Icon(Icons.subscript),
        text: AppLocalizations.of(context)!.myAcEbayPlanTabLb,
      ),
      */
    ];
  }
}
