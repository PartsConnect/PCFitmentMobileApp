import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BatchUploadNewPage extends StatefulWidget {
  final String toolbarTitle;

  const BatchUploadNewPage({
    super.key,
    required this.toolbarTitle,
  });

  @override
  State<BatchUploadNewPage> createState() => _BatchUploadPageNewState();
}

class _BatchUploadPageNewState extends State<BatchUploadNewPage> {
  String titleLbl = '';
  String last5Lbl = '';
  String dtLbl = '';
  String nameLbl = '';
  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  bool isLoading = false;
  bool isDownloadLoading = true;
  bool isAddDataLoading = false;

  List<dynamic> batchUploadList = [];
  int currentPage = 1;
  int totalPages = 0;
  final ScrollController _scrollController = ScrollController();

  late List<bool> isDownloadLoadingStates;
  late List<bool> downloadLoadingStates;
  late List<bool> addDataLoadingStates;

  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  @override
  void initState() {
    super.initState();
    dataLabelFetch();
    checkAndRequestPermissions();

    internetConnectionManager.checkInternetConnection(() {
      setState(() {
        internetConnectionCheck = internetConnectionManager.internetCheck;
        if (internetConnectionCheck != null && internetConnectionCheck!) {
          batchUploadAPICall();
        }
      });
    });

    //batchUploadAPICall();
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
      body: buildUIContentMain(),
      //_buildBatchUploadContent(batchUploadList),
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
              BatchUploadNewPage(
                toolbarTitle:
                    titleLbl.isNotEmpty ? titleLbl : widget.toolbarTitle,
              ));
        },
      );
    } else {
      // If there is internet, show the main content
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              last5Lbl.isNotEmpty ? last5Lbl : 'Last 5 Submitted Fitment Files',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          buildAllContent(),
        ],
      );
    }
  }

  Widget loading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    );
  }

  Widget buildAllContent() {
    return Expanded(
      child: Stack(
        //alignment: Alignment.center,
        children: [
          ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: batchUploadList.length,
            itemBuilder: (context, index) {
              final part = batchUploadList[index];
              return buildUIContent1(
                  part['userfilesid'],
                  part['createddate'],
                  part['filename'],
                  part['reason'],
                  part['filepath'],
                  part['IsAddData'],
                  index);
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
      ),
    );
  }

  // ignore: unused_element
  Widget buildUIContent(String userfilesid, String date, String name,
      String reason, String path, String strAddData, int index) {
    bool isAddData = (strAddData.toLowerCase() == 'yes');
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print(name);
          print(path);
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Text(
                                dtLbl.isNotEmpty ? dtLbl : 'Date',
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
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Text(
                                nameLbl.isNotEmpty ? nameLbl : 'File Name',
                              ),
                            ),
                            const Text(
                              ' : ',
                            ),
                            Expanded(
                              child: Text(
                                name,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isDownloadLoadingStates[index],
                    child: IconButton(
                      onPressed: () async {
                        //final String savedDir =
                        //await _createFolderInDownloadsDirectory(
                        //    'PCFitement');

                        setState(() {
                          isDownloadLoadingStates[index] = false;
                          downloadLoadingStates[index] = true;
                        });

                        final directory = await getExternalStorageDirectory();
                        final externalDirPath = directory?.path;

                        await FlutterDownloader.enqueue(
                          url: path,
                          savedDir: externalDirPath.toString(),
                          fileName: name,
                          saveInPublicStorage: true,
                          showNotification: true,
                          openFileFromNotification: true,
                        );

                        Future.delayed(const Duration(seconds: 5), () {
                          setState(() {
                            isDownloadLoadingStates[index] = true;
                            downloadLoadingStates[index] = false;
                          });
                        });

                        /*FlutterDownloader.registerCallback((id, status, progress) {
                          if (status == DownloadTaskStatus.failed) {
                            // Handle download failure here
                            print('Download failed for task: $id');
                          }else{
                            print('Download success: $id');
                          }
                        });*/

                        /*await FlutterDownloader.enqueue(
                          url: path,
                          savedDir: savedDir,
                          fileName: name,
                          //headers: {},
                          saveInPublicStorage: true,
                          showNotification: true,
                          // show download progress in status bar (for Android)
                          openFileFromNotification:
                          true, // click on notification to open downloaded file (for Android)
                        );*/

                        //DownloadManager().downloadFile(
                        //    context, path, name);
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ),
                  if (downloadLoadingStates[index])
                    const SizedBox(
                      width: 30 * 0.8,
                      // Adjust the progress indicator size here
                      height: 30 * 0.8,
                      // Adjust the progress indicator size here
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        strokeWidth: 3,
                      ),
                    )
                ],
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: isAddData,
                child: SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        //isDownloadLoading = true;
                        addDataLoadingStates[index] = true;
                      });

                      batchUploadAddDataAPICall(userfilesid, index);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return addDataLoadingStates[index]
                              ? Colors.grey
                              : Colors.red;
                        },
                      ),
                    ),
                    child: addDataLoadingStates[index]
                        ? const SizedBox(
                            width: 30 * 0.8,
                            // Adjust the progress indicator size here
                            height: 30 * 0.8,
                            // Adjust the progress indicator size here
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          )
                        : const Center(
                            child: Text('Add Data'),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUIContent1(String userfilesid, String date, String name,
      String reason, String path, String strAddData, int index) {
    bool isAddData = (strAddData.toLowerCase() == 'yes');
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print(name);
          print(path);
        }
      },
      child: Container(
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
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text(
                      dtLbl.isNotEmpty ? dtLbl : 'Date',
                    ),
                  ),
                  const Text(' : '),
                  Expanded(
                    child: Text(
                      date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text(
                      nameLbl.isNotEmpty ? nameLbl : 'File Name',
                    ),
                  ),
                  const Text(' : '),
                  Expanded(
                    child: Text(
                      name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          //isDownloadLoading = true;
                          downloadLoadingStates[index] = true;
                        });

                        final directory = await getExternalStorageDirectory();
                        final externalDirPath = directory?.path;

                        await FlutterDownloader.enqueue(
                          url: path,
                          savedDir: externalDirPath.toString(),
                          fileName: name,
                          saveInPublicStorage: true,
                          showNotification: true,
                          openFileFromNotification: true,
                        );

                        Future.delayed(const Duration(seconds: 5), () {
                          setState(() {
                            downloadLoadingStates[index] = false;
                          });
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return downloadLoadingStates[index]
                                ? Colors.grey
                                : Colors.red;
                          },
                        ),
                      ),
                      child: downloadLoadingStates[index]
                          ? const SizedBox(
                              width: 30 * 0.8,
                              // Adjust the progress indicator size here
                              height: 30 * 0.8,
                              // Adjust the progress indicator size here
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : const Center(
                              child: Text('Download File'),
                            ),
                    ),
                  )),
                  /*Expanded(
                    child: SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: 'Download File',
                        onPressed: () async {
                          setState(() {
                            //isDownloadLoading = true;
                            downloadLoadingStates[index] = true;
                          });

                          final directory = await getExternalStorageDirectory();
                          final externalDirPath = directory?.path;

                          await FlutterDownloader.enqueue(
                            url: path,
                            savedDir: externalDirPath.toString(),
                            fileName: name,
                            saveInPublicStorage: true,
                            showNotification: true,
                            openFileFromNotification: true,
                          );

                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              downloadLoadingStates[index] = false;
                            });
                          });
                        },
                        isLoading: downloadLoadingStates[index],
                      ),
                    ),
                  ),*/
                  const SizedBox(width: 10),
                  Visibility(
                    visible: isAddData,
                    child: Expanded(
                        child: SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            //isDownloadLoading = true;
                            addDataLoadingStates[index] = true;
                          });

                          batchUploadAddDataAPICall(userfilesid, index);

                          /*Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              addDataLoadingStates[index] = false;
                            });
                          });*/
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              return addDataLoadingStates[index]
                                  ? Colors.grey
                                  : Colors.red;
                            },
                          ),
                        ),
                        child: addDataLoadingStates[index]
                            ? const SizedBox(
                                width: 30 * 0.8,
                                // Adjust the progress indicator size here
                                height: 30 * 0.8,
                                // Adjust the progress indicator size here
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 3,
                                ),
                              )
                            : const Center(
                                child: Text('Add Data'),
                              ),
                      ),
                    )),
                  ),
                  /*Expanded(
                    child: SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: 'Add Data',
                        onPressed: () {
                          // Handle onPressed for 'Add Data' button
                        },
                        isLoading: false,
                      ),
                    ),
                  ),*/
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /*Future<String> _createFolderInDownloadsDirectory(String folderName) async {
    final Directory? downloadsDirectory = await getExternalStorageDirectory();
    final String newPath = '${downloadsDirectory!.path}/$folderName';

    final Directory newDirectory = Directory(newPath);
    if (!newDirectory.existsSync()) {
      await newDirectory.create(recursive: true);
    }

    return newPath;
  }*/

  Future<void> dataLabelFetch() async {
    //titleLbl = await LanguageChange().strTranslatedValue('Batch Upload');

    last5Lbl = await LanguageChange()
        .strTranslatedValue('Last 5 Submitted Fitment Files');
    dtLbl = await LanguageChange().strTranslatedValue('Date');
    nameLbl = await LanguageChange().strTranslatedValue('File Name');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  Future<void> checkAndRequestPermissions() async {
    final List<Permission> permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ];

    bool allGranted = true;
    for (Permission permission in permissions) {
      if (!(await permission.isGranted)) {
        allGranted = false;
        break;
      }
    }

    if (!allGranted) {
      await requestPermissions(permissions);
    }
  }

  Future<void> requestPermissions(List<Permission> permissions) async {
    bool showRationale = false;
    for (Permission permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted && await permission.shouldShowRequestRationale) {
        showRationale = true;
        break;
      }
    }

    if (showRationale) {
      // Show rationale dialog explaining why permissions are required
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
                'Please grant the required permissions to continue.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await permissions.request();
                  checkAndRequestPermissions();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      await permissions.request();
      checkAndRequestPermissions();
    }
  }

  Future<void> batchUploadAPICall() async {
    if (await Network.isConnected()) {
      batchUploadList.clear();

      setState(() {
        isLoading = true;
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
          .getQueryParam(batchUploadUrl, queryParams: param)
          .then((value) {
        if (value['StatusCode'] == 200) {
          setState(() {
            isLoading = false;
            //totalPages = value['totalPages'];
            batchUploadList.addAll(value['data']);
            isDownloadLoadingStates =
                List.generate(batchUploadList.length, (index) => true);
            downloadLoadingStates =
                List.generate(batchUploadList.length, (index) => false);
            addDataLoadingStates =
                List.generate(batchUploadList.length, (index) => false);
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
      setState(() {
        isLoading = false;
      });
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
        await batchUploadAPICall();

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

  void batchUploadAddDataAPICall(String userFilesId, int index) async {
    if (await Network.isConnected()) {
      if (context.mounted) FocusScope.of(context).unfocus();

      Map<String, dynamic> param = {
        'userfilesid': userFilesId,
        'tenantID': PreferenceUtils.getLoginUserId(),
      };

      //TODO : Without Then Check
      /*var response = await DioClient()..post(batchUploadAddDataUrl,param);
    // If the response status code is 200
    if (response.statusCode == 200) {
    } else {

    }*/

      //TODO : Then Check
      DioClient().post(batchUploadAddDataUrl, param).then((value) {
        if (value['StatusCode'] == 200 && value['Status'] == 'OK') {
          setState(() {
            addDataLoadingStates[index] = false;
          });

          snackBarSuccessMsg(context, value['Message']);
          batchUploadAPICall();
          //getSubmitToAmazonAPICall();
          //Navigator.pop(context);
        } else {
          setState(() {
            addDataLoadingStates[index] = false;
          });
          snackBarErrorMsg(
              context,
              value != null
                  ? value['Message']
                  : 'Invalid response from server');
        }
      }).catchError((error) {
        setState(() {
          addDataLoadingStates[index] = false;
        });
        handleError(error);
      });
    } else {
      setState(() {
        addDataLoadingStates[index] = false;
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
