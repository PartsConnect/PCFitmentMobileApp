import 'package:flutter/material.dart';
import 'package:pcfitment/component/color_confing.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/date_format.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String notificationLbl = '';
  String notificationDtLbl = '';
  String notificationTitleLbl = '';
  String notificationDecLbl = '';
  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  List<dynamic> notificationList = [];
  int currentPage = 1;
  int totalPages = 0;
  int? _expandedIndex;

  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dataLableFetch();

    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            notificationAPICall();
          }
        });
      }
    });

    //notificationAPICall();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              notificationLbl.isNotEmpty ? notificationLbl : 'Notification',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ),
        body: buildUIContent());
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
          Navigation.pushReplacement(context, const NotificationPage());
        },
      );
    } else {
      // If there is internet, show the main content
      return buildAllContent();
    }
  }

  Widget buildAllContent() {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: notificationList.length,
          itemBuilder: (context, index) {
            final part = notificationList[index];
            return customUI(
              part['NotificationTitle'],
              part['NotificationMessage'],
              part['CreateDate'],
              index,
            );
          },
        ),
        if (isLoading)
          Container(
            alignment: Alignment.center,
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
          ),
      ],
    );
  }

  Widget customUI(String title, String message, String date, int index) {
    final List<Color> circleColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
    ];

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      background: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        color: ColorConfing.accentColor,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        color: ColorConfing.accentColor,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        deleteNotificationAPICall(
            notificationList[index]['App_NotificationHistoryID']);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: circleColors[index % circleColors.length],
              child: Text(title.characters.first), // Example: Display initials
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_expandedIndex == index) {
                      _expandedIndex =
                      null; // Collapse the currently expanded item
                    } else {
                      _expandedIndex = index; // Expand the tapped item
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _expandedIndex == index
                                ? title
                                : truncateText(title),
                            overflow: _expandedIndex == index
                                ? null
                                : TextOverflow.ellipsis,
                            maxLines: _expandedIndex == index ? null : 1,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          convertDateFormat(
                              date, 'MM/dd/yyyy hh:mm:ss a', 'dd MMM'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4), // Adjust spacing as needed
                    Text(
                      _expandedIndex == index ? message : truncateText(message),
                      overflow: _expandedIndex == index
                          ? null
                          : TextOverflow.ellipsis,
                      maxLines: _expandedIndex == index ? null : 1,
                    ),
                    const SizedBox(height: 4), // Adjust spacing as needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> dataLableFetch() async {
    notificationLbl = await LanguageChange().strTranslatedValue('Notification');
    internetTitleLbl =
    await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
    await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  String truncateText(String text) {
    const maxLength =
        50; // Change this to the desired max length before truncating.
    return text.length <= maxLength
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  Future<void> notificationAPICall() async {
    if (await Network.isConnected()) {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> param = {
        'tenantID': PreferenceUtils.getLoginUserId(),
      };

      try {
        var value = await DioClient().getQueryParam(
          getNotificationHistoryDetailsUrl,
          queryParams: param,
        );

        if (value != null) {
          if (value['StatusCode'] == 200) {
            setState(() {
              isLoading = false;
              notificationList = value['data'];
            });
          } else {
            setState(() {
              isLoading = false;
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
            isLoading = false;
          });
          if (context.mounted) {
            snackBarErrorMsg(context, 'Invalid response from server');
          }
        }
      } on FetchDataException catch (e) {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) snackBarErrorMsg(context, e.message!);
      } on ApiNotRespondingException catch (e) {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) snackBarErrorMsg(context, e.message!);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        handleError(e);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  void deleteNotificationAPICall(String notificationId) async {
    if (await Network.isConnected()) {
      Map<String, dynamic> param = {
        'tenantID': PreferenceUtils.getLoginUserId(),
        'NotificationHistoryID': notificationId,
      };

      //TODO : Without Then Check
      /*var response = await DioClient()..post(deleteNotificationUrl,param);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

      //TODO : Then Check
      DioClient().post(deleteNotificationUrl, param).then((value) {
        if (value['StatusCode'] == 200 && value['Status'] == 'OK') {
          snackBarSuccessMsg(context, value['Message']);
          //notificationAPICall();
        } else {
          snackBarErrorMsg(
              context,
              value != null
                  ? value['Message']
                  : 'Invalid response from server');
        }
      }).catchError((error) {
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
