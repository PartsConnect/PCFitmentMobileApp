import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewPage extends StatefulWidget {
  final String toolbarTitle;
  final String url;

  const PDFViewPage({super.key, required this.toolbarTitle, required this.url});

  @override
  State<PDFViewPage> createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> with WidgetsBindingObserver {
  String titleLbl = '';
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
    dataLableFetch();

    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            SfPdfViewer.network(
              widget.url,
              enableDoubleTapZooming: true,
              //enableAnnotationToolbar: true,
              canShowScrollHead: true,
            );
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
        actions: [
          IconButton(
            onPressed: () async {
              final directory = await getExternalStorageDirectory();
              final externalDirPath = directory?.path;

              await FlutterDownloader.enqueue(
                url: widget.url,
                savedDir: externalDirPath.toString(),
                saveInPublicStorage: true,
                showNotification: true,
                openFileFromNotification: true,
              );
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      /*body: SfPdfViewer.network(
        widget.url,
        enableDoubleTapZooming: true,
        //enableAnnotationToolbar: true,
        canShowScrollHead: true,
      ),*/
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
              PDFViewPage(
                toolbarTitle: widget.toolbarTitle,
                url: widget.url,
              ));
        },
      );
    } else {
      // If there is internet, show the main content
      return SfPdfViewer.network(
        widget.url,
        enableDoubleTapZooming: true,
        //enableAnnotationToolbar: true,
        canShowScrollHead: true,
      );
    }
  }

  Future<void> dataLableFetch() async {
    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }
}
