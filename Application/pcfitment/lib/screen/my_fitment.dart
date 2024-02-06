import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pcfitment/api/my_parts_and_fitment_api.dart';
import 'package:pcfitment/apihandle/app_exceptions.dart';
import 'package:pcfitment/apihandle/dio_client.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/screen/my_fitment_info.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/utils/url.dart';
import 'package:pcfitment/widgets/navigation.dart';
import 'package:pcfitment/widgets/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPatsAndFitmentPage extends StatefulWidget {
  const MyPatsAndFitmentPage({super.key});

  @override
  State<MyPatsAndFitmentPage> createState() => _MyPatsAndFitmentPageState();
}

class _MyPatsAndFitmentPageState extends State<MyPatsAndFitmentPage> {
  List<dynamic> partsList = [];
  int currentPage = 1;
  int totalPages = 0;

  bool isCheckAmazonFit = true;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  String dropdownValue = 'All Parts';
  String searchText = '';
  String ddlItemId = '1';
  String searchValue = '';

  String myPartAndFitmentLbl = '';
  String searchLbl = '';
  String allPartsLbl = '';
  String finalAllParts = '';
  String finalErrorParts = '';
  String partsWithErrorLbl = '';
  String partNumberLbl = '';
  String partTypeLbl = '';
  String partASINLbl = '';
  String partPartTerminologyIDLbl = '';
  String partBrandIDLbl = '';
  String partTotalLbl = '';
  String partSavedLbl = '';
  String partErrorLbl = '';
  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  Timer? debounce;

  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    dataLableFetch();

    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            fetchData();
          }
        });
      }
    });

    //fetchData();
    _scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            myPartAndFitmentLbl.isNotEmpty
                ? myPartAndFitmentLbl
                : AppLocalizations.of(context)!.drawerMyPartsAndFitmentLb,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
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
          Navigation.pushReplacement(context, const MyPatsAndFitmentPage());
        },
      );
    } else {
      // If there is internet, show the main content
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: true,
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0),
              child: TextField(
                controller: textEditingController,
                onChanged: onSearchTextChanged,
                decoration: InputDecoration(
                  hintText: searchLbl.isNotEmpty ? searchLbl : 'Search...',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            margin: const EdgeInsets.only(
                left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey), // Border color
              borderRadius: BorderRadius.circular(8.0), // Border radius
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValue,
                      onChanged: onDropdownChanged,
                      items: <String>['All Parts', 'Parts With Error']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (partsList.isNotEmpty)
                  Flexible(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: partsList.length,
                      itemBuilder: (context, index) {
                        final part = partsList[index];
                        return buildUIContent(
                            part['PartNumber'],
                            part['PartTypeName'],
                            part['ASIN'],
                            part['PartTerminologyID'],
                            part['BrandID'],
                            part['Fitmentsnum'],
                            part['SavedFitmentsCount'],
                            part['ErrorFitmentsCount'],
                            part['IsAmazonFit'],
                            index);
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
            ),
          ),
        ],
      );
    }
  }

  Widget buildUIContent(
      String partNumber,
      String partType,
      String aSIN,
      String partId,
      String brandId,
      String totalFitment,
      String savedFitement,
      String errorFitment,
      String strIsAmazonFit,
      int index) {
    bool isAmazonFit = (strIsAmazonFit.toLowerCase() == 'true');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPartsAndFitmentInfoPage(
              partNumber: partsList[index]['PartNumber'],
              partTypeName: partsList[index]['PartTypeName'],
              asin: partsList[index]['ASIN'],
              partTerminologyID: partsList[index]['PartTerminologyID'],
              brandID: partsList[index]['BrandID'],
              manufactureLabel: partsList[index]['ManufactureLabel'],
              partDescription: partsList[index]['PartDescription'],
              fitments: partsList[index]['Fitmentsnum'],
              partID: partsList[index]['ID'],
              savedFitmentsCount: partsList[index]['SavedFitmentsCount'],
              errorFitmentsCount: partsList[index]['ErrorFitmentsCount'],
            ),
          ),
        );

        /*Get.to(() => const MyPartsAndFitmentInfoPage(), arguments: [
          partsList[index]['PartNumber'],
          partsList[index]['PartTypeName'],
          partsList[index]['ASIN'],
          partsList[index]['PartTerminologyID'],
          partsList[index]['BrandID'],
          'Manufacture Label',
          'Part Description',
          'Fitments #'
        ]);*/
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
                      partNumberLbl.isNotEmpty ? partNumberLbl : 'Part No',
                    ),
                  ),
                  const Text(
                    ' : ',
                  ),
                  Expanded(
                    child: Text(
                      partNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
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
                      partTypeLbl.isNotEmpty ? partTypeLbl : 'PT Name',
                    ),
                  ),
                  const Text(
                    ' : ',
                  ),
                  Expanded(
                    child: Text(
                      partType,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
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
              GestureDetector(
                onTap: () async {
                  String url = 'https://www.amazon.com/dp/$aSIN';
                  if (!await launchUrl(Uri.parse(url))) {
                    throw Exception('Could not launch $url');
                  }
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(
                        partASINLbl.isNotEmpty ? partASINLbl : 'ASIN',
                      ),
                    ),
                    const Text(
                      ' : ',
                    ),
                    Expanded(
                      child: Text(
                        aSIN,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
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
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            partPartTerminologyIDLbl.isNotEmpty
                                ? partPartTerminologyIDLbl
                                : 'PT ID',
                          ),
                        ),
                        const Text(
                          ' : ',
                        ),
                        Text(
                          partId,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    color: Colors.red, // Replace with your desired color
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          partBrandIDLbl.isNotEmpty
                              ? partBrandIDLbl
                              : 'Brand ID',
                          textAlign: TextAlign.start,
                        ),
                        const Text(
                          ' : ',
                        ),
                        Text(
                          brandId,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
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
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                            partTotalLbl.isNotEmpty ? partTotalLbl : 'Total',
                          ),
                        ),
                        const Text(
                          ' : ',
                        ),
                        Text(
                          totalFitment,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    color: Colors.red, // Replace with your desired color
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          partSavedLbl.isNotEmpty ? partSavedLbl : 'Saved',
                        ),
                        const Text(
                          ' : ',
                        ),
                        Text(
                          savedFitement,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    color: Colors.red, // Replace with your desired color
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          partErrorLbl.isNotEmpty ? partErrorLbl : 'Error',
                        ),
                        const Text(
                          ' : ',
                        ),
                        Text(
                          errorFitment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: false,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  // Remove default padding for ListTile
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Checkbox(
                        //value: isCheckAmazonFit,
                        value: true,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckAmazonFit = value!;
                          });
                        },
                      ),
                      Image.asset(
                        'assets/images/ic_amzon_fit.png',
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: isAmazonFit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /*Container(
                      height: 0.25,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: Colors.red, // Replace with your desired color
                    ),*/
                    Visibility(
                      visible: false,
                      child: Checkbox(
                        //value: isCheckAmazonFit,
                        value: true,
                        onChanged: (bool? value) {
                          setState(() {
                            isCheckAmazonFit = value!;
                          });
                        },
                      ),
                    ),
                    Image.asset(
                      'assets/images/ic_amzon_fit.png',
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    if (await Network.isConnected()) {
      try {
        setState(() {
          isLoading = true;
        });

        // Fetching data
        if (context.mounted) {
          final response =
              await MyPartsAndFitmentAPI.getMyPartsAndFitmentAPICall(
                  context,
                  currentPage.toString(),
                  ddlItemId,
                  searchValue,
                  PreferenceUtils.getLoginUserId());

          if (response['StatusCode'] == 200) {
            setState(() {
              totalPages = response['totalPages'];
              /*if (currentPage == 1) {
            partsList = response['data']['MyPartsAndFitmentList'];
          } else {
            partsList.addAll(response['data']['MyPartsAndFitmentList']);
          }*/
              partsList.addAll(response['data']['MyPartsAndFitmentList']);
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
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          handleError(e);
        }
      }
    } else {
      if (context.mounted) snackBarErrorMsg(context, Constants.networkMsg);
    }
  }

  Future<void> loadMoreData() async {
    try {
      if (!isLoading /*&& currentPage < totalPages*/) {
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

  Future<void> fetchData1() async {
    if (await Network.isConnected()) {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> param = {
        'pageNumber': currentPage,
        'ddlItemId': ddlItemId,
        'tenantID': PreferenceUtils.getLoginUserId(),
        'searchValue': searchValue
      };

      try {
        var value = await DioClient().getQueryParam(
          getMyPartsAndFitmentUrl,
          queryParams: param,
        );

        if (value != null) {
          if (value['StatusCode'] == 200) {
            setState(() {
              isLoading = false;
              totalPages = value['totalPages'];
              partsList.addAll(value['data']['MyPartsAndFitmentList']);
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

  Future<void> dataLableFetch() async {
    myPartAndFitmentLbl =
        await LanguageChange().strTranslatedValue('My Parts Fitment');
    searchLbl = await LanguageChange().strTranslatedValue('Search');
    allPartsLbl = await LanguageChange().strTranslatedValue('All Parts');
    partsWithErrorLbl =
        await LanguageChange().strTranslatedValue('Parts With Error');

    partNumberLbl = await LanguageChange().strTranslatedValue('Part No');
    partTypeLbl = await LanguageChange().strTranslatedValue('PT Name');
    partASINLbl = await LanguageChange().strTranslatedValue('ASIN');
    partPartTerminologyIDLbl =
        await LanguageChange().strTranslatedValue('PT ID');
    partBrandIDLbl = await LanguageChange().strTranslatedValue('Brand ID');
    partTotalLbl = await LanguageChange().strTranslatedValue('Total');
    partSavedLbl = await LanguageChange().strTranslatedValue('Saved');
    partErrorLbl = await LanguageChange().strTranslatedValue('Error');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    finalAllParts = allPartsLbl.isNotEmpty ? allPartsLbl : 'All Parts';
    //dropdownValue = allPartsLbl.isNotEmpty ? allPartsLbl : 'All Parts';
    finalErrorParts =
        partsWithErrorLbl.isNotEmpty ? partsWithErrorLbl : 'Parts With Error';
    setState(() {});
  }

  void onSearchTextChanged(String text) {
    setState(() {
      partsList.clear();
      currentPage = 1;
      ddlItemId = '1';
      searchValue = text.toLowerCase();

      //searchValue = textEditingController.text.toLowerCase();

      /*partsList = originalPartsList.where((part) {
        String partNumber = part['PartNumber'].toString().toLowerCase();
        String partType = part['PartTypeName'].toString().toLowerCase();

        return partNumber.contains(searchValue) ||
            partType.contains(searchValue);
      }).toList();*/

      if (searchValue.isEmpty) {
        searchValue = '';
        FocusScope.of(context).unfocus();
      }

      if (!isLoading) {
        isLoading = true; // Set flag to indicate data loading
        if (debounce?.isActive ?? false) debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 750), () {
          fetchData().then((_) {
            isLoading = false; // Reset flag when data loading is done
          });
        });
      }

      /*if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 750), () {
        fetchData();
      });*/
    });
  }

  void onDropdownChanged(String? newValue) {
    setState(() {
      partsList.clear();
      currentPage = 1;
      searchValue = '';
      textEditingController.text = '';
      FocusScope.of(context).unfocus();
      dropdownValue = newValue!;
      if (dropdownValue == 'All Parts') {
        ddlItemId = '1';
        fetchData();
      } else if (dropdownValue == 'Parts With Error') {
        ddlItemId = '2';
        fetchData();
      }
    });
  }

  void scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      loadMoreData();
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
