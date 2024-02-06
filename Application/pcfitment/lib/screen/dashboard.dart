import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pcfitment/api/dashboard_api.dart';
import 'package:pcfitment/api/login_api.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/button.dart';
import 'package:pcfitment/component/dashboard_icon.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/component/theme_provider.dart';
import 'package:pcfitment/component/themes.dart';
import 'package:pcfitment/database/database_helper.dart';
import 'package:pcfitment/model/lang_model.dart';
import 'package:pcfitment/screen/batch_upload_new.dart';
import 'package:pcfitment/screen/help.dart';
import 'package:pcfitment/screen/amazon.dart';
import 'package:pcfitment/screen/login.dart';
import 'package:pcfitment/screen/my_account.dart';
import 'package:pcfitment/screen/my_fitment.dart';
import 'package:pcfitment/screen/notification.dart';
import 'package:pcfitment/screen/ebay.dart';
import 'package:pcfitment/screen/walmart.dart';
import 'package:pcfitment/services/notification_services.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

enum SelectedLanguage { english, chinese }

class _DashboardPageState extends State<DashboardPage> {
  SelectedLanguage? selectedLanguage;

  final dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> users = [];
  List mostRecentList = [];
  List planList = [];
  List fitmentList = [];
  List<dynamic> languagesList = [];
  List<dynamic> languagesDetailsList = [];

  DateTime? currentBackPressTime;

  bool _isMounted = false;
  bool isMostRecentExpo = false;
  bool isAddAnotherACLoading = false;
  bool isDashContentLoading = false;

  String version = '';
  String buildNumber = '';

  String strRunningPlan = '';
  String strEbayPlan = '';

  String strFitInfoParts = '';
  String strFitInfoFitment = '';
  String strFitInfoPartsType = '';
  String strFitInfoCollection = '';
  String strFitInfoCollectionWithoutParts = '';
  String strFitInfoUniParts = '';

  String strUpdateFitInfoParts = '';
  String strUpdateFitInfoFitment = '';
  String strUpdateFitInfoPartsType = '';

  String myPanLbl = '';
  String fitmentInfoLbl = '';
  String totalPartsLbl = '';
  String totalFitmentLbl = '';
  String totalPartsTypeLbl = '';
  String totalCollectionLbl = '';
  String totalCollectionWithoutPartsLbl = '';
  String totalUniversalPartsLbl = '';
  String updateFitmentInfoLbl = '';
  String mostRecentExportLbl = '';
  String mostRecentExportDtLbl = '';
  String mostRecentExportTypeLbl = '';

  String homeLbl = '';
  String myPartAndFitmentLbl = '';
  String batchUploadLbl = '';
  String submitToAmzLbl = '';
  String submitToWallmartLbl = '';
  String submitToEbayLbl = '';
  String submitTicketLbl = '';
  String helpLbl = '';
  String myAccountLbl = '';
  String languageLbl = '';
  String selectLanguageLbl = '';
  String logoutLbl = '';
  String versionLbl = '';
  String poweredByLbl = '';
  String poweredByNameLbl = '';

  String logoutDlLbl = '';
  String logoutDlContentLbl = '';
  String logoutDlNoLbl = '';
  String logoutDlYesLbl = '';

  String multipleAcLbl = '';
  String multipleAcCancelLbl = '';
  String multipleAcAddLbl = '';

  String addMultipleAcLbl = '';
  String addMultipleAcUserEmailLbl = '';
  String addMultipleAcPasswordLbl = '';
  String addMultipleAcBtnLbl = '';

  String planAccountExpiredTitleLbl = '';
  String planAccountExpiredBodyLbl = '';
  String upgradePlanTitleLbl = '';
  String upgradePlanBodyLbl = '';

  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  String? isPlanExpiredCheck;

  NotificationServices notificationServices = NotificationServices();

  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  AppUpdateInfo? _updateInfo;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    checkForUpdate();

    _isMounted = true;

    //requestManageExternalStoragePermission();

    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setUpInterMsg(context);
    //notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) => {});

    PreferenceUtils.setIsLogin('true');
    dataLableFetch();
    initSelectedLanguage();
    multipleUserList();
    appInfo();

    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            setState(() {
              isDashContentLoading = true;
            });
            multipleCall();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //_showInternetToast(context); // Show the SnackBar when the widget builds

    return Scaffold(
      /*appBar: CustomAppBar().appBar(context, 'Dashboard', press: () {
        print("Multiple Account");
      }),*/

      /*appBar: BaseAppBar(
        title: Text(PreferenceUtils.getLoginEmail(),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        appBar: AppBar(),
        widgets: [
          IconButton(
            onPressed: () {
              _showMultipleAddAccountDialog(context);
            },
            icon: const Icon(Icons.multiple_stop),
          ),
          Visibility(
            visible: false,
            child: IconButton(
              onPressed: () {
                _showLanguagesDialog(context);
              },
              icon: const Icon(Icons.language),
            ),
          ),
          Consumer<LanguageChange>(builder: (context, provider, child) {
            return PopupMenuButton(
                onSelected: (SelectedLanguage item) async {
                  setState(() {
                    selectedLanguage =
                        item; // Update selected language when changed
                  });
                  await PreferenceUtils.setSelectedLanguage(
                      selectedLanguage.toString());

                  */ /*if (SelectedLanguage.english.name == item.name) {
                    provider.changeLanguage(const Locale('en'));
                  } else {
                    provider.changeLanguage(const Locale('zh'));
                  }*/ /*

                  if (SelectedLanguage.chinese.name == item.name) {
                    provider.changeLanguage(const Locale('zh'));
                  } else {
                    provider.changeLanguage(const Locale('en'));
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SelectedLanguage>>[
                      PopupMenuItem(
                          value: SelectedLanguage.english,
                          enabled: selectedLanguage != SelectedLanguage.english,
                          child: const Text('English')),
                      PopupMenuItem(
                          value: SelectedLanguage.chinese,
                          enabled: selectedLanguage != SelectedLanguage.chinese,
                          child: const Text('Chinese')),
                    ]);
          })
        ],
      ),*/

      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            //_showMultipleAddAccountDialog(context);
            showMultipleAccountBottomDialog(context);
          },
          child: Text(
            PreferenceUtils.getLoginEmail(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //_showMultipleAddAccountDialog(context);
              showMultipleAccountBottomDialog(context);
            },
            icon: const Icon(Icons.multiple_stop),
          ),
          Visibility(
            visible: isPlanExpiredCheck == 'no',
            child: IconButton(
              onPressed: () {
                Navigation.push(context, const NotificationPage());
              },
              icon: const Icon(Icons.notifications),
            ),
          ),
          Visibility(
            visible: false,
            child: IconButton(
              onPressed: () {
                //_showLanguagesDialog(context);
                showLanguagesBottomDialog(context);
              },
              icon: const Icon(Icons.language),
            ),
          ),
        ],
      ),
      drawer: drawerFun(),
      // ignore: deprecated_member_use
      body: WillPopScope(
        onWillPop: onWillPop,
        //child: _buildAllContent(),
        child: buildUIContent(),
      ),
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
          Navigation.pushReplacement(context, const DashboardPage());
        },
      );
    } else {
      // If there is internet, show the main content
      return buildAllContent();
    }
  }

  Widget buildAllContent() {
    return isDashContentLoading
        //? CustomLoader()
        ? Center(
            // Show loading indicator at the center of the screen
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
            visible: isPlanExpiredCheck == 'no',
            replacement: buildUpgradePlan(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    dashMenuAllFunction(),
                    const SizedBox(height: 10),
                    myPlan(),
                    const SizedBox(height: 10),
                    fitmentInformation(),
                    const SizedBox(height: 10),
                    Visibility(
                      visible: isMostRecentExpo,
                      child: mostRecentExport(),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget dashMenuAllFunction() {
    return SingleChildScrollView(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          DashboardIcon(
            text: homeLbl.isNotEmpty
                ? homeLbl // Set labelText to loginUserEmail when it's not empty
                : 'Home',
            onPressed: () {
              Navigation.pushReplacement(context, const DashboardPage());
            },
            imagePath: 'assets/icon/ic_home_01.png',
            iconColor: Colors.red,
          ),
          DashboardIcon(
            text: myPartAndFitmentLbl.isNotEmpty
                ? myPartAndFitmentLbl // Set labelText to loginUserEmail when it's not empty
                : 'My Parts Fitment',
            onPressed: () {
              Navigation.push(context, const MyPatsAndFitmentPage());
            },
            imagePath: 'assets/icon/ic_fitment_01.png',
            iconColor: Colors.cyan,
          ),
          DashboardIcon(
            text: batchUploadLbl.isNotEmpty
                ? batchUploadLbl // Set labelText to loginUserEmail when it's not empty
                : 'Batch Upload',
            onPressed: () {
              Navigation.push(
                  context,
                  BatchUploadNewPage(
                    toolbarTitle: batchUploadLbl.isNotEmpty
                        ? batchUploadLbl
                        : 'Batch Upload',
                  ));
            },
            imagePath: 'assets/icon/ic_upload_01.png',
            //iconColor: Colors.amber,
            iconColor: Colors.lightBlueAccent[100],
          ),
          DashboardIcon(
            text: submitToAmzLbl.isNotEmpty
                ? submitToAmzLbl // Set labelText to loginUserEmail when it's not empty
                : 'Submit To Amazon',
            onPressed: () {
              Navigation.push(
                context,
                SubmitToAmazonPage(
                    toolbarTitle: submitToAmzLbl.isNotEmpty
                        ? submitToAmzLbl
                        : 'Submit To Amazon'),
              );
            },
            imagePath: 'assets/icon/ic_amazon_01.png',
            iconColor: Colors.blue,
          ),
          DashboardIcon(
            text: submitToWallmartLbl.isNotEmpty
                ? submitToWallmartLbl // Set labelText to loginUserEmail when it's not empty
                : 'Submit To Walmart',
            onPressed: () {
              Navigation.push(
                  context,
                  SubmitToWalmartPage(
                      toolbarTitle: submitToWallmartLbl.isNotEmpty
                          ? submitToWallmartLbl
                          : 'Submit To Walmart'));
            },
            imagePath: 'assets/icon/ic_walmart_01.png',
            iconColor: Colors.green,
          ),
          DashboardIcon(
            text: submitToEbayLbl.isNotEmpty
                ? submitToEbayLbl // Set labelText to loginUserEmail when it's not empty
                : 'Submit To eBay',
            onPressed: () {
              Navigation.push(
                  context,
                  SubmitToeBayPage(
                    toolbarTitle: submitToEbayLbl.isNotEmpty
                        ? submitToEbayLbl
                        : 'Submit To eBay',
                  ));
            },
            imagePath: 'assets/icon/ic_ebay_01.png',
            iconColor: Colors.orange,
          ),
          DashboardIcon(
            text: submitTicketLbl.isNotEmpty
                ? submitTicketLbl // Set labelText to loginUserEmail when it's not empty
                : 'Submit To Ticket',
            onPressed: () async {
              String url =
                  'https://partsconnect.zendesk.com/hc/en-us/requests/new';
              if (!await launchUrl(Uri.parse(url))) {
                throw Exception('Could not launch $url');
              }
              /*Navigation.push(
                            context,
                            WebViewPage(
                              toolbarTitle: submitTicketLbl.isNotEmpty
                                  ? submitTicketLbl
                                  : 'Submit Ticket',
                              url:
                                  'https://partsconnect.zendesk.com/hc/en-us/requests/new',
                            ));*/
            },
            imagePath: 'assets/icon/ic_submit_ticket_01.png',
            iconColor: Colors.pink,
          ),
          DashboardIcon(
            text: myAccountLbl.isNotEmpty
                ? myAccountLbl // Set labelText to loginUserEmail when it's not empty
                : 'My Account',
            onPressed: () {
              Navigation.push(context, const MyAccountPage());
            },
            imagePath: 'assets/icon/ic_user_01.png',
            iconColor: Colors.grey,
          ),
          DashboardIcon(
            text: helpLbl.isNotEmpty
                ? helpLbl // Set labelText to loginUserEmail when it's not empty
                : 'Help?',
            onPressed: () {
              Navigation.push(
                  context,
                  HelpPage(
                    toolbarTitle: helpLbl.isNotEmpty ? helpLbl : 'Help?',
                  ));
            },
            imagePath: 'assets/icon/ic_help_01.png',
            iconColor: Colors.purple[400],
          ),
          DashboardIcon(
            text: languageLbl.isNotEmpty
                ? languageLbl // Set labelText to loginUserEmail when it's not empty
                : 'Language',
            onPressed: () {
              showLanguagesBottomDialog(context);
            },
            imagePath: 'assets/icon/ic_language_01.png',
            iconColor: Colors.deepOrange,
          ),
          DashboardIcon(
            text: logoutLbl.isNotEmpty
                ? logoutLbl // Set labelText to loginUserEmail when it's not empty
                : 'Logout',
            onPressed: () {
              showLogoutBottomDialog(context);
            },
            imagePath: 'assets/icon/ic_logout_01.png',
            iconColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget buildUpgradePlan() {
    return Container(
      height: double.infinity,
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
      child: Center(
        child: SingleChildScrollView(
          // Wrap content with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_plan_expired.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              Text(
                planAccountExpiredTitleLbl.isNotEmpty
                    ? planAccountExpiredTitleLbl
                    : 'Your Account Has Expired',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                planAccountExpiredBodyLbl.isNotEmpty
                    ? planAccountExpiredBodyLbl
                    : 'Thank you for signing up for PCFitment! We hope you have enjoyed the free trial.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                upgradePlanTitleLbl.isNotEmpty
                    ? upgradePlanTitleLbl
                    : 'Ready to Upgrade?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                upgradePlanBodyLbl.isNotEmpty
                    ? upgradePlanBodyLbl
                    : 'Upgrading your PCFitment account is simple. Our basic plan starts just at \$15 per month for 150 SKU and includes help desk support and data submission to Amazon.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerFun() {
    String versionText = versionLbl.isNotEmpty
        ? '$versionLbl:$version($buildNumber)' // Set labelText to versionLbl when it's not empty
        : 'Version: $version ($buildNumber)';

    return Drawer(
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName:
                  //Text(PreferenceUtils.getLoginEmail().split('@').first),
                  Text(PreferenceUtils.getLoginUserName()),
              accountEmail: Text(PreferenceUtils.getLoginEmail()),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  PreferenceUtils.getLoginEmail()
                      .characters
                      .first
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  //TODO : Drawer Custom Header
                  /*Container(
                      padding: EdgeInsets.zero,
                      height: 225, // Adjust the height as needed
                      decoration: const BoxDecoration(
                        color: Colors.red, // Change background color as needed
                        // Add more BoxDecoration properties here if desired
                      ),
                      child: const DrawerHeader(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Make the DrawerHeader transparent
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage('https://images.pexels.com/photos/60597/dahlia-red-blossom-bloom-60597.jpeg'), // Replace with your image URL
                              ),
                              SizedBox(height: 10),
                              Text(
                                'John Doe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'john.doe@example.com',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),*/
                  //TODO : Drawer User Account Header
                  ListTile(
                    //leading: const Icon(Icons.home),
                    leading: Image.asset(
                      'assets/icon/ic_home.png',
                      width: 20, // Set the width of the icon
                      height: 20, // Set the height of the icon
                    ),
                    title: Text(
                      homeLbl.isNotEmpty
                          ? homeLbl // Set labelText to loginUserEmail when it's not empty
                          : AppLocalizations.of(context)!.drawerHomeLb,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigation.pushReplacement(
                          context, const DashboardPage());
                    },
                  ),
                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.six_ft_apart),
                      leading: Image.asset(
                        'assets/icon/ic_fitment.png',
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(myPartAndFitmentLbl.isNotEmpty
                          ? myPartAndFitmentLbl // Set labelText to loginUserEmail when it's not empty
                          : AppLocalizations.of(context)!
                              .drawerMyPartsAndFitmentLb),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(context, const MyPatsAndFitmentPage());
                      },
                    ),
                  ),

                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.batch_prediction),
                      leading: Image.asset(
                        'assets/icon/ic_upload.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(batchUploadLbl.isNotEmpty
                          ? batchUploadLbl // Set labelText to loginUserEmail when it's not empty
                          : 'Batch Upload'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(
                            context,
                            BatchUploadNewPage(
                              toolbarTitle: batchUploadLbl.isNotEmpty
                                  ? batchUploadLbl
                                  : 'Batch Upload',
                            ));
                      },
                    ),
                  ),
                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.six_ft_apart),
                      leading: Image.asset(
                        'assets/icon/ic_amazon.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(submitToAmzLbl.isNotEmpty
                          ? submitToAmzLbl // Set labelText to loginUserEmail when it's not empty
                          : 'Submit To Amazon'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(
                            context,
                            SubmitToAmazonPage(
                                toolbarTitle: submitToAmzLbl.isNotEmpty
                                    ? submitToAmzLbl
                                    : 'Submit To Amazon'));
                      },
                    ),
                  ),
                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.six_ft_apart),
                      leading: Image.asset(
                        'assets/icon/ic_walmart.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(submitToWallmartLbl.isNotEmpty
                          ? submitToWallmartLbl // Set labelText to loginUserEmail when it's not empty
                          : 'Submit To Walmart'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(
                            context,
                            SubmitToWalmartPage(
                                toolbarTitle: submitToWallmartLbl.isNotEmpty
                                    ? submitToWallmartLbl
                                    : 'Submit To Walmart'));
                      },
                    ),
                  ),
                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.six_ft_apart),
                      leading: Image.asset(
                        'assets/icon/ic_ebay.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(submitToEbayLbl.isNotEmpty
                          ? submitToEbayLbl // Set labelText to loginUserEmail when it's not empty
                          : 'Submit To eBay'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(
                            context,
                            SubmitToeBayPage(
                              toolbarTitle: submitToEbayLbl.isNotEmpty
                                  ? submitToEbayLbl
                                  : 'Submit To eBay',
                            ));
                      },
                    ),
                  ),
                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.airplane_ticket),
                      leading: Image.asset(
                        'assets/icon/ic_submit_ticket.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(submitTicketLbl.isNotEmpty
                          ? submitTicketLbl // Set labelText to loginUserEmail when it's not empty
                          : 'Submit Ticket'),
                      onTap: () async {
                        Navigator.pop(context);
                        String url =
                            'https://partsconnect.zendesk.com/hc/en-us/requests/new';
                        if (!await launchUrl(Uri.parse(url))) {
                          throw Exception('Could not launch $url');
                        }
                        /*Navigation.push(
                            context,
                            WebViewPage(
                              toolbarTitle: submitTicketLbl.isNotEmpty
                                  ? submitTicketLbl
                                  : 'Submit Ticket',
                              url:
                                  'https://partsconnect.zendesk.com/hc/en-us/requests/new',
                            ));*/
                      },
                    ),
                  ),

                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.person),
                      leading: Image.asset(
                        'assets/icon/ic_user.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(myAccountLbl.isNotEmpty
                          ? myAccountLbl // Set labelText to loginUserEmail when it's not empty
                          : AppLocalizations.of(context)!.drawerMyAccountLb),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(context, const MyAccountPage());
                        //Navigator.pushNamed(context, '/MyAccount');
                      },
                    ),
                  ),
                  Visibility(
                    visible: isPlanExpiredCheck == 'no',
                    child: ListTile(
                      //leading: const Icon(Icons.help),
                      leading: Image.asset(
                        'assets/icon/ic_help.png',
                        // Replace with your actual icon path
                        width: 20, // Set the width of the icon
                        height: 20, // Set the height of the icon
                      ),
                      title: Text(helpLbl.isNotEmpty
                          ? helpLbl // Set labelText to loginUserEmail when it's not empty
                          : 'Help?'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.push(
                            context,
                            HelpPage(
                              toolbarTitle:
                                  helpLbl.isNotEmpty ? helpLbl : 'Help?',
                            ));
                      },
                    ),
                  ),

                  ListTile(
                    //leading: const Icon(Icons.language),
                    leading: Image.asset(
                      'assets/icon/ic_language.png',
                      // Replace with your actual icon path
                      width: 20, // Set the width of the icon
                      height: 20, // Set the height of the icon
                    ),
                    title: Text(languageLbl.isNotEmpty
                        ? languageLbl // Set labelText to loginUserEmail when it's not empty
                        : 'Language'),
                    onTap: () {
                      Navigator.pop(context);
                      showLanguagesBottomDialog(context);
                    },
                  ),
                  Visibility(
                    visible: false,
                    child: ListTile(
                      title: Text(AppLocalizations.of(context)!.drawerThemeLb),
                      leading: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          IconData iconData = themeProvider.selectedTheme ==
                                  ThemeClass.darkTheme
                              ? Icons.nightlight_round
                              : Icons.wb_sunny;
                          Color iconColor = themeProvider.selectedTheme ==
                                  ThemeClass.darkTheme
                              ? Colors.white
                              : Colors.black;
                          return Icon(
                            iconData,
                            color: iconColor,
                          );
                        },
                      ),
                      trailing: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return Switch(
                            value: themeProvider.selectedTheme ==
                                ThemeClass.darkTheme,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          );
                        },
                      ),
                      /*onTap: () {
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          Navigator.pop(context); // Close the drawer
                        },*/
                    ),
                  ),
                  ListTile(
                    //leading: const Icon(Icons.logout),
                    leading: Image.asset(
                      'assets/icon/ic_logout.png',
                      // Replace with your actual icon path
                      width: 20, // Set the width of the icon
                      height: 20, // Set the height of the icon
                    ),
                    title: Text(logoutLbl.isNotEmpty
                        ? logoutLbl // Set labelText to loginUserEmail when it's not empty
                        : AppLocalizations.of(context)!.drawerLogoutLb),
                    onTap: () {
                      Navigator.pop(context);
                      //_logoutDialog(context);
                      showLogoutBottomDialog(context);
                    },
                  ),
                ],
              ),
            ),
            //Divider(),
            Container(
              height: 40.0,
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        versionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        poweredByLbl.isNotEmpty ? poweredByLbl : 'Powered By ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      const Text(
                        ' : ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        poweredByNameLbl.isNotEmpty
                            ? poweredByNameLbl
                            : 'Parts Connects',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 10.0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myPlan() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light gray background color
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0), // Top left radius
              topRight: Radius.circular(10.0), // Top right radius
            ),
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            myPanLbl.isNotEmpty
                ? myPanLbl // Set labelText to loginUserEmail when it's not empty
                : AppLocalizations.of(context)!.dashMyPlanLb,
            textAlign: TextAlign.start, // Aligns text to the left
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background color
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strRunningPlan,
                  textAlign: TextAlign.start, // Aligns text to the left
                  style: const TextStyle(
                    color: Colors.red,
                    /*fontWeight: FontWeight.w500,
                      fontSize: 12*/
                  )),
              Text(strEbayPlan,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.red,
                    /*fontWeight: FontWeight.w500,
                      fontSize: 12*/
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget fitmentInformation() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light gray background color
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0), // Top left radius
              topRight: Radius.circular(10.0), // Top right radius
            ),
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            fitmentInfoLbl.isNotEmpty
                ? fitmentInfoLbl // Set labelText to loginUserEmail when it's not empty
                : AppLocalizations.of(context)!.dashFitInfoLb,
            textAlign: TextAlign.start, // Aligns text to the left
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background color
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        totalPartsLbl.isNotEmpty
                            ? totalPartsLbl // Set labelText to loginUserEmail when it's not empty
                            : AppLocalizations.of(context)!
                                .dashFitInfoTlPartsLb,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.black), // Aligns text to the left
                      )),
                  Text(strFitInfoParts,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalFitmentLbl.isNotEmpty
                              ? totalFitmentLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashFitInfoTlFitmentLb,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              color: Colors.black) // Aligns text to the left
                          )),
                  Text(strFitInfoFitment,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalPartsTypeLbl.isNotEmpty
                              ? totalPartsTypeLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashFitInfoTlPartTypeLb,
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: Colors.black))),
                  Text(strFitInfoPartsType,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalCollectionLbl.isNotEmpty
                              ? totalCollectionLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashFitInfoTlCollectionLb,
                          textAlign: TextAlign.start, // Aligns text to the left
                          style: const TextStyle(color: Colors.black))),
                  Text(strFitInfoCollection,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalCollectionWithoutPartsLbl.isNotEmpty
                              ? totalCollectionWithoutPartsLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashFitInfoTlCollectionWithoutPartLb,
                          textAlign: TextAlign.start, // Aligns text to the left
                          style: const TextStyle(color: Colors.black))),
                  Text(strFitInfoCollectionWithoutParts,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalUniversalPartsLbl.isNotEmpty
                              ? totalUniversalPartsLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashFitInfoTlUniversalPartLb,
                          textAlign: TextAlign.start, // Aligns text to the left
                          style: const TextStyle(color: Colors.black))),
                  Text(strFitInfoUniParts,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
        updateInfo(),
      ],
    );
  }

  Widget updateInfo() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light gray background color
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0.0), // Top left radius
              topRight: Radius.circular(0.0), // Top right radius
            ),
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            updateFitmentInfoLbl.isNotEmpty
                ? updateFitmentInfoLbl // Set labelText to loginUserEmail when it's not empty
                : AppLocalizations.of(context)!.dashUpdateFitInfoLb,
            textAlign: TextAlign.start, // Aligns text to the left
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background color
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        totalPartsLbl.isNotEmpty
                            ? totalPartsLbl // Set labelText to loginUserEmail when it's not empty
                            : AppLocalizations.of(context)!
                                .dashUpdateFitInfoTlPartsLb,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.black), // Aligns text to the left
                      )),
                  Text(strUpdateFitInfoParts,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalFitmentLbl.isNotEmpty
                              ? totalFitmentLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashUpdateFitInfoTlFitmentLb,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              color: Colors.black) // Aligns text to the left
                          )),
                  Text(strUpdateFitInfoFitment,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey[200]!,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                          totalPartsTypeLbl.isNotEmpty
                              ? totalPartsTypeLbl // Set labelText to loginUserEmail when it's not empty
                              : AppLocalizations.of(context)!
                                  .dashUpdateFitInfoTlPartTypeLb,
                          textAlign: TextAlign.start,
                          style: const TextStyle(color: Colors.black))),
                  Text(strUpdateFitInfoPartsType,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget mostRecentExport() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light gray background color
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0), // Top left radius
              topRight: Radius.circular(10.0), // Top right radius
            ),
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Text(
            mostRecentExportLbl.isNotEmpty
                ? mostRecentExportLbl // Set labelText to loginUserEmail when it's not empty
                : AppLocalizations.of(context)!.dashMostRecentExportLb,
            textAlign: TextAlign.start, // Aligns text to the left
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        Container(
          //width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height * 0.8, // Set a fixed height or use relative height
          decoration: BoxDecoration(
            color: Colors.white, // White background color
            border: Border.all(
              color: Colors.grey[200]!, // Light gray border color
            ),
          ),
          //padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            //physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: mostRecentList.length,
            itemBuilder: (BuildContext context, int index) {
              return buildMRCardContent(
                mostRecentList[index]['ExportDate'] ?? '',
                mostRecentList[index]['ExportType'] ?? '',
                mostRecentList[index]['strFilePath'] ?? '',
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildMRCardContent(String exportDt, String exportType, String path) {
    return SingleChildScrollView(
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
              Row(children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Text(
                      mostRecentExportDtLbl.isNotEmpty
                          ? mostRecentExportDtLbl // Set labelText to loginUserEmail when it's not empty
                          : AppLocalizations.of(context)!
                              .dashMostRecentExportDtLb,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ),
                const Text(
                  ' : ',
                ),
                Expanded(
                  child: Text(exportDt,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black)),
                ),
              ]),
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
                        mostRecentExportTypeLbl.isNotEmpty
                            ? mostRecentExportTypeLbl // Set labelText to loginUserEmail when it's not empty
                            : AppLocalizations.of(context)!
                                .dashMostRecentExportTypeLb,
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.black)),
                  ),
                  const Text(
                    ' : ',
                  ),
                  Expanded(
                    child: Text(exportType,
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.black)),
                  ),
                ],
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
              Visibility(
                visible: false,
                child: SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        color: Colors.black,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        color: Colors.black,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> requestManageExternalStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isDenied) {}
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      snackBarErrorMsg(context, 'Press back again to exit app.');
      return Future.value(false);
    }
    return Future.value(true);
  }

  void multipleCall() async {
    if (await Network.isConnected()) {
      languagesAPICall();
      //dashboardMultipleAPICall();
      dashAPICall();
    } else {
      setState(() {
        isAddAnotherACLoading = false;
        isDashContentLoading = false;
      });

      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);

      /*CustomBottomSheet.showNoNetworkBottomSheet(
        context: context,
        onRetry: () {
          Navigator.pop(context);
          Navigation.pushReplacement(context, DashboardPage());
        },
      );*/
    }
  }

  void appInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      //String appName = packageInfo.appName;
      //String packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  void multipleUserList() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    users = await dbHelper.getUsers();
  }

  void initSelectedLanguage() async {
    selectedLanguage =
        (PreferenceUtils.getSelectedLanguage()) as SelectedLanguage;
    setState(() {});
  }

  void showMultipleAccountBottomDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        String prefUseremail = PreferenceUtils.getLoginEmail();
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
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
                      height: 10,
                    ),
                    Text(
                      multipleAcLbl.isNotEmpty
                          ? multipleAcLbl
                          : 'Multiple Account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        bool isSelectedUser =
                            users[index]['useremail'] == prefUseremail;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Text(
                              users[index]['useremail'][0].toUpperCase(),
                            ),
                          ),
                          title: Text(users[index]['useremail']),
                          trailing: isSelectedUser
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ) // Show a checkmark for the selected user
                              : null,
                          onTap: () {
                            if (users[index]['useremail'] ==
                                PreferenceUtils.getLoginEmail()) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                prefUseremail = users[index][
                                    'useremail']; // Update the selected username
                              });
                              // Perform actions when an account is selected
                              PreferenceUtils.setLoginUserName(
                                  users[index]['username']);
                              PreferenceUtils.setLoginEmail(
                                  users[index]['useremail']);
                              PreferenceUtils.setLoginPassword(
                                  users[index]['password']);
                              PreferenceUtils.setLoginUserId(
                                  users[index]['userid']);

                              //fetchDataFromAPI();
                              Navigator.of(context).pop();
                              Navigation.pushReplacement(
                                  context, const DashboardPage());
                            }

                            /*snackBarSuccessMsg(
                            context, 'Your data successfully update.');*/
                          },
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(multipleAcCancelLbl.isNotEmpty
                              ? multipleAcCancelLbl
                              : AppLocalizations.of(context)!.dialogBtnMlYesLb),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(multipleAcAddLbl.isNotEmpty
                              ? multipleAcAddLbl
                              : AppLocalizations.of(context)!.dialogBtnMlNoLb),
                          onPressed: () {
                            //userNameController.text = '';
                            //passwordController.text = '';
                            Navigator.of(context).pop();
                            showMultipleAddAccountBottomDialog(context);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showLogoutBottomDialog(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
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
                        height: 10,
                      ),
                      Text(
                        logoutLbl.isNotEmpty
                            ? logoutLbl
                            : AppLocalizations.of(context)!.dialogTitleLogoutLb,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        logoutDlContentLbl.isNotEmpty
                            ? logoutDlContentLbl
                            : AppLocalizations.of(context)!.dialogMsgLogoutLb,
                        textAlign: TextAlign.center,
                        //style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text(logoutDlNoLbl.isNotEmpty
                                ? logoutDlNoLbl
                                : AppLocalizations.of(context)!
                                    .dialogBtnNoLogoutLb),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(logoutDlYesLbl.isNotEmpty
                                ? logoutDlYesLbl
                                : AppLocalizations.of(context)!
                                    .dialogBtnYesLogoutLb),
                            onPressed: () async {
                              /*PreferenceUtils.setIsLogin('false');

                              await DatabaseHelper.instance.deleteTable(
                                  DatabaseHelper.multipleUserTable);

                              Navigation.pushRemoveUntil(
                                  context, const LoginPage());*/

                              logoutAPICall(PreferenceUtils.getDeviceId());
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> dashAPICall() async {
    if (await Network.isConnected()) {
      setState(() {
        isDashContentLoading = true;
      });

      Map<String, dynamic> param = {
        'tenantID': PreferenceUtils.getLoginUserId(),
      };

      try {
        var value = await DioClient().getQueryParam(
          dashboardUrl,
          queryParams: param,
        );

        if (value != null) {
          if (value['StatusCode'] == 200) {
            setState(() {
              isDashContentLoading = false;

              planList = value['data']['TenantPlanDetails'];
              fitmentList = value['data']['FitmentsSummary'];
              mostRecentList = value['data']['MostRecentExport'];

              strRunningPlan = planList[0]['RunningPlan'].toString();
              strEbayPlan = planList[0]['eBayPlan'].toString();

              strFitInfoParts = fitmentList[0]['TotalParts'].toString();
              strFitInfoFitment = fitmentList[0]['TotalFitments'].toString();
              strFitInfoPartsType = fitmentList[0]['TotalPartType'].toString();
              strFitInfoCollection =
                  fitmentList[0]['TotalCollection'].toString();
              strFitInfoCollectionWithoutParts =
                  fitmentList[0]['TotalCollectionWithoutParts'].toString();
              strFitInfoUniParts = fitmentList[0]['TotalUniParts'].toString();

              strUpdateFitInfoParts = fitmentList[0]['NewParts'].toString();
              strUpdateFitInfoFitment =
                  fitmentList[0]['NewFitments'].toString();
              strUpdateFitInfoPartsType =
                  fitmentList[0]['NewPartType'].toString();

              if (mostRecentList.isEmpty) {
                isMostRecentExpo = false;
              } else {
                isMostRecentExpo = true;
              }

              isPlanExpiredCheck =
                  value['data']['IsUserExpired'].toString().toLowerCase();
            });
          } else {
            setState(() {
              isDashContentLoading = false;
            });
            if (context.mounted) {
              snackBarErrorMsg(
                  context,
                  value != null
                      ? value['Message'] ?? 'Invalid response from server'
                      : 'Invalid response from server');
            }
          }
        } else {
          setState(() {
            isDashContentLoading = false;
          });
          if (context.mounted) {
            snackBarErrorMsg(context, 'Invalid response from server');
          }
        }
      } on FetchDataException catch (e) {
        setState(() {
          isDashContentLoading = false;
        });
        if (context.mounted) snackBarErrorMsg(context, e.message!);
      } on ApiNotRespondingException catch (e) {
        setState(() {
          isDashContentLoading = false;
        });
        if (context.mounted) snackBarErrorMsg(context, e.message!);
      } catch (e) {
        if (mounted) {
          setState(() {
            isDashContentLoading = false;
          });
          handleError(e);
        }
      }
    } else {
      setState(() {
        isDashContentLoading = false;
      });
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void dashboardMultipleAPICall() async {
    if (_isMounted) {
      try {
        List<Map<String, dynamic>>? data =
            await DashboardAPI.multipleAPIFetchData(
                context,
                PreferenceUtils.getLoginUserId(),
                PreferenceUtils.getAuthToken());
        if (data!.isNotEmpty) {
          if (_isMounted) {
            setState(() {
              //responseData = data;

              strRunningPlan = data[0]['RunningPlan'].toString();
              strEbayPlan = data[0]['eBayPlan'].toString();

              strFitInfoParts = data[1]['TotalParts'].toString();
              strFitInfoFitment = data[1]['TotalFitments'].toString();
              strFitInfoPartsType = data[1]['TotalPartType'].toString();
              strFitInfoCollection = data[1]['TotalCollection'].toString();
              strFitInfoCollectionWithoutParts =
                  data[1]['TotalCollectionWithoutParts'].toString();
              strFitInfoUniParts = data[1]['TotalUniParts'].toString();

              strUpdateFitInfoParts = data[1]['NewParts'].toString();
              strUpdateFitInfoFitment = data[1]['NewFitments'].toString();
              strUpdateFitInfoPartsType = data[1]['NewPartType'].toString();

              mostRecentList = data[2]['MostRecentExportsList'];

              if (mostRecentList.isEmpty) {
                isMostRecentExpo = false;
              } else {
                isMostRecentExpo = true;
              }

              isDashContentLoading = false;
            });

            /*for (var item in responseData) {
          print(item);
        }*/
          }
        } else {
          setState(() {
            isDashContentLoading = false;
          });
          if (context.mounted) snackBarErrorMsg(context, data.toString());
        }
      } on Exception catch (e) {
        setState(() {
          isDashContentLoading = false;
        });
        handleError(e);
      }
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
      logoutAPICall(PreferenceUtils.getDeviceId());
      //snackBarErrorMsg(context, 'Unauthorized request.');
    } else if (error is SocketException) {
      var message = error.message;
      snackBarErrorMsg(context, 'Socket error occurred: $message');
    } else {
      // Handle other unexpected errors
      snackBarErrorMsg(context, 'Unexpected error occurred.');
    }
  }

  Future<void> languagesAPICall() async {
    final response = await DashboardAPI.getLanguageAPICall(context);
    if (response['StatusCode'] == 200) {
      if (mounted) {
        setState(() {
          languagesList = response['data'];
        });
      }
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

  Future<void> languagesDetailsAPICall() async {
    if (await Network.isConnected()) {
      try {
        if (context.mounted) {
                final response = await DashboardAPI.getLanguageDetailsAPICall(context,
                    PreferenceUtils.getSystemLangCode(), PreferenceUtils.getDeviceId());
                if (response['StatusCode'] == 200) {
                  DatabaseHelper dbHelper = DatabaseHelper.instance;
                  await dbHelper.deleteTable(DatabaseHelper.langTable);

                  List<dynamic> languagesDetailsList =
                      response['data']['LanguageWiseLabels'];
                  List<LangModel> languagesData = languagesDetailsList
                      .map((data) => LangModel.fromJson(data))
                      .toList();
                  await dbHelper.insertLang(languagesData);

                  if (context.mounted) {
                    Navigation.pushReplacement(context, const DashboardPage());
                  }
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
        if (context.mounted) snackBarErrorMsg(context, Constants.contactMsg);
      }
    } else {
      setState(() {
        isAddAnotherACLoading = false;
        isDashContentLoading = false;
      });
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  Future<void> dataLableFetch() async {
    myPanLbl = await LanguageChange().strTranslatedValue('My Plan');
    fitmentInfoLbl =
        await LanguageChange().strTranslatedValue('Fitment Information');
    totalPartsLbl = await LanguageChange().strTranslatedValue('Total of Parts');
    totalFitmentLbl =
        await LanguageChange().strTranslatedValue('Total of Fitment');
    totalPartsTypeLbl =
        await LanguageChange().strTranslatedValue('Total of Part Type');
    totalCollectionLbl =
        await LanguageChange().strTranslatedValue('Total Collection');
    totalCollectionWithoutPartsLbl = await LanguageChange()
        .strTranslatedValue('Total Collection Without Parts');
    totalUniversalPartsLbl =
        await LanguageChange().strTranslatedValue('Total Universal Parts');
    updateFitmentInfoLbl = await LanguageChange()
        .strTranslatedValue('Updated Info Since Last Data Submission');
    mostRecentExportLbl =
        await LanguageChange().strTranslatedValue('Most Recent Export');
    mostRecentExportDtLbl =
        await LanguageChange().strTranslatedValue('Export Date');
    mostRecentExportTypeLbl =
        await LanguageChange().strTranslatedValue('Export Type');

    homeLbl = await LanguageChange().strTranslatedValue('Home');
    myPartAndFitmentLbl =
        await LanguageChange().strTranslatedValue('My Parts Fitment');

    batchUploadLbl = await LanguageChange().strTranslatedValue('Batch Upload');
    submitToAmzLbl =
        await LanguageChange().strTranslatedValue('Submit To Amazon');
    submitToWallmartLbl =
        await LanguageChange().strTranslatedValue('Submit To Walmart');
    submitToEbayLbl =
        await LanguageChange().strTranslatedValue('Submit To eBay');
    submitTicketLbl =
        await LanguageChange().strTranslatedValue('Submit Ticket');
    helpLbl = await LanguageChange().strTranslatedValue('Help?');

    myAccountLbl = await LanguageChange().strTranslatedValue('My Account');
    languageLbl = await LanguageChange().strTranslatedValue('Language');
    selectLanguageLbl =
        await LanguageChange().strTranslatedValue('Select Language');
    logoutLbl = await LanguageChange().strTranslatedValue('Logout');
    logoutDlContentLbl = await LanguageChange().strTranslatedValue('LogoutMsg');
    logoutDlNoLbl = await LanguageChange().strTranslatedValue('No');
    logoutDlYesLbl = await LanguageChange().strTranslatedValue('Yes');

    versionLbl = await LanguageChange().strTranslatedValue('Version');
    poweredByLbl = await LanguageChange().strTranslatedValue('Powered By');
    //poweredByNameLbl = await LanguageChange().strTranslatedValue('Parts Connects');

    multipleAcLbl =
        await LanguageChange().strTranslatedValue('Multiple Account');
    multipleAcCancelLbl = await LanguageChange().strTranslatedValue('Cancel');
    multipleAcAddLbl = await LanguageChange().strTranslatedValue('Add');

    addMultipleAcLbl =
        await LanguageChange().strTranslatedValue('Add Multiple Account');
    addMultipleAcUserEmailLbl =
        await LanguageChange().strTranslatedValue('Useremail');
    addMultipleAcPasswordLbl =
        await LanguageChange().strTranslatedValue('Password');
    addMultipleAcBtnLbl =
        await LanguageChange().strTranslatedValue('Add Another Account');

    planAccountExpiredTitleLbl =
        await LanguageChange().strTranslatedValue('Account Title');
    planAccountExpiredBodyLbl =
        await LanguageChange().strTranslatedValue('Account Body');
    upgradePlanTitleLbl =
        await LanguageChange().strTranslatedValue('Upgrade Title');
    upgradePlanBodyLbl =
        await LanguageChange().strTranslatedValue('Upgrade Body');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    if (mounted) {
      setState(() {});
    }
  }

  void showMultipleAddAccountBottomDialog(BuildContext context) {
    TextEditingController userNameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool obscured = true; // Initially hide the password

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    addMultipleAcLbl.isNotEmpty
                        ? addMultipleAcLbl
                        : 'Add Multiple Account',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: userNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: addMultipleAcUserEmailLbl.isNotEmpty
                          ? addMultipleAcUserEmailLbl
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
                      labelText: addMultipleAcPasswordLbl.isNotEmpty
                          ? addMultipleAcPasswordLbl
                          : AppLocalizations.of(context)!.loginPasswordLb,
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscured =
                                  !obscured; // Toggle password visibility
                              // Set focus to the password field after toggling visibility
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                          },
                          child: Icon(
                            obscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    obscureText: obscured,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                      buttonText: addMultipleAcBtnLbl.isNotEmpty
                          ? addMultipleAcBtnLbl
                          : 'Add Another Account',
                      onPressed: () {
                        if (userNameController.text.isEmpty) {
                          snackBarErrorMsg(context, "Please enter user name.");
                        } else if (passwordController.text.isEmpty) {
                          snackBarErrorMsg(context, "Please enter password.");
                        } else {
                          setState(() {
                            isAddAnotherACLoading = true;
                          });

                          useDioLoginAPICall(
                              userNameController.text, passwordController.text);
                        }
                      },
                      isLoading: isAddAnotherACLoading)
                  /*ElevatedButton(
                    onPressed: () {
                      //errorLens();
                      if (userNameController.text.isEmpty) {
                        snackBarErrorMsg(context, "Please enter user name.");
                      } else if (passwordController.text.isEmpty) {
                        snackBarErrorMsg(context, "Please enter password.");
                      } else {
                        useDioLoginAPICall(
                            userNameController.text, passwordController.text);
                      }
                    },
                    child: Text('Add Another Account'),
                  ),*/
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void useDioLoginAPICall(String userEmail, String password) async {
    if (await Network.isConnected()) {
      if (context.mounted) FocusScope.of(context).unfocus();
      if (context.mounted) {
        LoginAPI.loginAPICall(
                context,
                userEmail,
                password,
                PreferenceUtils.getFCMId(),
                PreferenceUtils.getDeviceId(),
                PreferenceUtils.getTermsCondition(),
                PreferenceUtils.getPrivacyPolicy())
            .then((value) async {
          if (value['StatusCode'] == 200) {
            setState(() {
              isAddAnotherACLoading = false;
            });

            PreferenceUtils.setAuthToken('Bearer ${value['data']['token']}');
            dynamic userIdValue = value['data']['Id'];
            String userIdAsString =
                userIdValue != null ? userIdValue.toString() : '';
            PreferenceUtils.setLoginUserId(userIdAsString);
            PreferenceUtils.setLoginEmail(value['data']['Email']);
            PreferenceUtils.setLoginUserName(value['data']['TenantName']);
            PreferenceUtils.setLoginPassword(password);

            insertDBLoginData(context, value['data']['TenantName'], userEmail,
                password, userIdAsString, value['Message']);
          } else {
            setState(() {
              isAddAnotherACLoading = false;
            });

            Navigator.pop(context);
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

  void insertDBLoginData(BuildContext context, String username,
      String userEmail, String password, String userId, String msg) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> existingUsers =
        await dbHelper.getUserByUserId(userId);
    if (existingUsers.isNotEmpty) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) snackBarSuccessMsg(context, 'User already exists!');
    } else {
      // Username doesn't exist, proceed with inserting the new user
      Map<String, dynamic> user = {
        DatabaseHelper.columnLoginUserName: username,
        DatabaseHelper.columnLoginUserEmail: userEmail,
        DatabaseHelper.columnLoginUserPassword: password,
        DatabaseHelper.columnLoginUserId: userId,
      };

      await dbHelper.insertUser(user).then((value) => {
            Navigation.pushReplacement(context, const DashboardPage()),
            snackBarSuccessMsg(context, msg),
          });

      //Navigation.pushRemoveUntil(context, const DashboardPage());
      //snackBarSuccessMsg(context, 'Add account successfully.');

      //fetchDataFromAPI();
    }
  }

  void showLanguagesBottomDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        String prefLang = PreferenceUtils.getSystemLangCode();
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
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
                      height: 10,
                    ),
                    Text(
                      selectLanguageLbl.isNotEmpty
                          ? selectLanguageLbl
                          : 'Selected Languages',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: languagesList.length,
                      itemBuilder: (context, index) {
                        bool isSelectedUser = languagesList[index]
                                    ['LanguageCode']
                                .toString()
                                .toLowerCase() ==
                            prefLang;
                        return ListTile(
                          title: Text(languagesList[index]['LanguageName']),
                          trailing: isSelectedUser
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ) // Show a checkmark for the selected user
                              : null,
                          onTap: () {
                            if (languagesList[index]['LanguageCode']
                                    .toString()
                                    .toLowerCase() ==
                                PreferenceUtils.getSystemLangCode()) {
                              Navigator.pop(context);
                            } else {
                              PreferenceUtils.setSystemLangCode(
                                  languagesList[index]['LanguageCode']
                                      .toString()
                                      .toLowerCase());

                              setState(() {
                                prefLang = languagesList[index][
                                    'LanguageCode']; // Update the selected username
                              });
                              Navigator.pop(context);
                              snackBarSuccessMsg(context,
                                  'Please wait some second your data is refresh...');
                              languagesDetailsAPICall();
                            }
                            //Navigator.pop(context);
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void logoutAPICall(String deviceId) async {
    Map<String, dynamic> param = {
      'DeviceId': deviceId,
    };

    //TODO : Without Then Check
    /*var response = await DioClient()..post(logoutUrl,param);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

    //TODO : Then Check
    DioClient().post(logoutUrl, param).then((value) async {
      if (value['StatusCode'] == 200 && value['Status'] == 'OK') {
        snackBarSuccessMsg(context, value['Message']);
        PreferenceUtils.clearAllPreferences();
        PreferenceUtils.setSystemCountryCode(WidgetsBinding.instance.platformDispatcher.locale.countryCode!);
        PreferenceUtils.setSystemLangCode(WidgetsBinding.instance.platformDispatcher.locale.languageCode);
        PreferenceUtils.setIsLogin('false');

        await DatabaseHelper.instance
            .deleteTable(DatabaseHelper.multipleUserTable);

        //await DatabaseHelper.closeDatabase();

        if (context.mounted) {
          Navigation.pushRemoveUntil(context, const LoginPage());
        }
      } else {
        snackBarErrorMsg(context,
            value != null ? value['Message'] : 'Invalid response from server');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });

      _updateInfo?.updateAvailability == UpdateAvailability.updateAvailable
          ? () {
              InAppUpdate.performImmediateUpdate().catchError((e) {
                showSnack(e.toString());
                return AppUpdateResult.inAppUpdateFailed;
              });
            }
          : null;
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }
}
