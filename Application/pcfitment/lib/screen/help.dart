import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/screen/vimeo_player.dart';
import 'package:pcfitment/screen/youtube_player.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';
import 'package:shimmer/shimmer.dart';

class HelpPage extends StatefulWidget {
  final String toolbarTitle;

  const HelpPage({super.key, required this.toolbarTitle});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String titleLbl = '';
  String videoPlayLbl = '';
  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  List<dynamic> videoList = [];
  int currentPage = 1;
  int totalPages = 0;

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
            setState(() {
              isLoading = true;
            });

            videoAPICall();
          }
        });
      }
    });
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
      body: buildUIContent(),
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
          Navigation.pushReplacement(
              context,
              HelpPage(
                  toolbarTitle:
                      titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle));
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
          itemCount: videoList.length,
          itemBuilder: (context, index) {
            final part = videoList[index];
            return customUI(
              part['VideoTitle'],
              part['LabelTitle'],
              part['VideoImage'],
              part['VideoLink'],
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

  Widget customUI(String videoTitle, String labelTitle, String imageUrl,
      String videoUrl, int index) {
    return GestureDetector(
      onTap: () {
        if (videoUrl.contains('https://www.youtube.com/')) {
          //videoUrl = 'https://www.youtube.com/watch?v=c4uJFbOe0Rc';

          Uri uri = Uri.parse(videoUrl);
          String videoId = uri.queryParameters['v'] ?? '';

          //String videoId = extractYouTubeId(videoUrl);
          Navigation.push(
              context,
              YoutubePlayerPage(
                toolbarTitle:
                    videoPlayLbl.isNotEmpty ? videoPlayLbl : 'Video Play',
                id: videoId,
              ));
        } else if (videoUrl.contains('https://player.vimeo.com/')) {
          final regex = RegExp(
              r'/(\d+)\??'); // Matches a sequence of digits after the last slash

          final match = regex.firstMatch(videoUrl);
          if (match != null && match.groupCount > 0) {
            String vimeoId = match.group(1).toString();
            Navigation.push(
                context,
                VimeoPlayerPage(
                  toolbarTitle:
                      videoPlayLbl.isNotEmpty ? videoPlayLbl : 'Video Play',
                  id: vimeoId,
                ));

            if (kDebugMode) {
              print('Vimeo Video ID: $vimeoId');
            }
          } else {
            if (kDebugMode) {
              print('Vimeo Video ID not found.');
            }
          }
        } else {
          snackBarErrorMsg(context, 'Video format not supported');
        }
      },
      child: buildContentWithShimmer(imageUrl, videoTitle, labelTitle),
      //child: buildContentWithoutShimmer(imageUrl, videoTitle, labelTitle),
    );
  }

  Widget buildContentWithoutShimmer(
      String imageUrl, String videoTitle, String labelTitle) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              videoTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 5),
            //padding: const EdgeInsets.all(5),
            child: Text(
              labelTitle,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContentWithShimmer(
      String imageUrl, String videoTitle, String labelTitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                // Error occurred while loading the image, show placeholder or error widget
                return Container(
                  color: Colors.grey[300], // Placeholder color
                  height: 150,
                  width: double.infinity,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                );
              },
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  // Image has finished loading, show the image
                  return child;
                } else {
                  // Image is still loading, show shimmer effect
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                      height: 150,
                      width: double.infinity,
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              videoTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 5),
            child: Text(
              labelTitle,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> dataLableFetch() async {
    //titleLbl = await LanguageChange().strTranslatedValue('Help?');
    videoPlayLbl = await LanguageChange().strTranslatedValue('Video Play');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  Future<void> videoAPICall() async {
    if (await Network.isConnected()) {
      videoList.clear();
      //TODO : Without Then Check
      /*var response = await DioClient().getQueryParam(getNotificationHistoryDetailsUrl);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

      //TODO : Then Check
      DioClient().getQueryParam(videoUrl).then((value) {
        if (value['StatusCode'] == 200) {
          setState(() {
            isLoading = false;
            videoList = value['data'];
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

  String extractYouTubeId(String url) {
    RegExp regExp = RegExp(r"/([a-zA-Z0-9_-]{11})\??");
    Match? match = regExp.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    } else {
      return ""; // Return an empty string or handle error
    }
  }
}
