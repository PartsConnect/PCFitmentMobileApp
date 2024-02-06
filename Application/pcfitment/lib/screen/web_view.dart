import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String toolbarTitle;
  final String url;

  const WebViewPage({super.key, required this.toolbarTitle, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String titleLbl = '';

  //late InAppWebViewController _webViewController;

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

      /*body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStart: (controller, url) {
          // Implement logic if needed when page starts loading
        },
        onLoadStop: (controller, url) {
          // Implement logic when page finishes loading
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url;
          // Implement custom logic for URL loading if needed
          return NavigationActionPolicy.ALLOW;
        },
        onDownloadStart: (controller, url) async {
          // Handle download of attachments here
          // For example, you can use url to download files
        },
      ),*/

      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel('FilePicker',
              onMessageReceived: (JavaScriptMessage message) async {
            //String? filePath =
            //    await yourFilePickerMethod(); // Implement file picking logic
            //WebViewController().evaluateJavascript(
            //  'receivedFilePathFromFlutter("$filePath")',
            //);
          })
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
          ..loadRequest(Uri.parse(widget.url)),
      ),
    );
  }

  Future<String?> yourFilePickerMethod() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String filePath = result.files.single.path!;
        return filePath; // Return the selected file path
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking file: $e');
      }
    }
    return null; // Return null if no file is selected or an error occurs
  }
}
