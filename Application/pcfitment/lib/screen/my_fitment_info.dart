import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pcfitment/api/my_parts_and_fitment_api.dart';
import 'package:pcfitment/component/internet_connection_manager.dart';
import 'package:pcfitment/component/language.dart';
import 'package:pcfitment/component/msg_show.dart';
import 'package:pcfitment/utils/constants.dart';
import 'package:pcfitment/utils/network.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/widgets/snackbar.dart';

class MyPartsAndFitmentInfoPage extends StatefulWidget {
  final String partNumber;
  final String partTypeName;
  final String asin;
  final String partTerminologyID;
  final String brandID;
  final String manufactureLabel;
  final String partDescription;
  final String fitments;
  final String partID;
  final String savedFitmentsCount;
  final String errorFitmentsCount;

  const MyPartsAndFitmentInfoPage({
    Key? key,
    required this.partNumber,
    required this.partTypeName,
    required this.asin,
    required this.partTerminologyID,
    required this.brandID,
    required this.manufactureLabel,
    required this.partDescription,
    required this.fitments,
    required this.partID,
    required this.savedFitmentsCount,
    required this.errorFitmentsCount,
  }) : super(key: key);

  @override
  State<MyPartsAndFitmentInfoPage> createState() =>
      _MyPartsAndFitmentInfoPageState();
}

class _MyPartsAndFitmentInfoPageState extends State<MyPartsAndFitmentInfoPage>
    with SingleTickerProviderStateMixin {
  var bundleData = Get.arguments;

  late TabController _tabController;

  List<dynamic> partsList = [];
  List<dynamic> savedFitmentsData = [];
  List<dynamic> errorFitmentsData = [];
  int currentPage = 1;
  int totalPages = 0;

  bool isHeaderContent = true;
  bool isLoading = false;
  bool isInfoSaved = true;
  final ScrollController _scrollController = ScrollController();

  TextEditingController yearTextController = TextEditingController();
  TextEditingController makeTextController = TextEditingController();
  TextEditingController modelTextController = TextEditingController();

  String partAndFitmentLbl = '';
  String savedFitmentLbl = '';
  String errorFitmentLbl = '';
  String partNumberLbl = '';
  String partTypeLbl = '';
  String partASINLbl = '';
  String partBrandIDLbl = '';
  String partManufactureLbl = '';
  String partDescLbl = '';
  String partFitmentLbl = '';
  String yearSearchLbl = '';
  String makeSearchLbl = '';
  String modelSearchLbl = '';
  String internetTitleLbl = '';
  String internetMsgLbl = '';
  String retryBtnLbl = '';

  Timer? debounce;

  InternetConnectionManager internetConnectionManager =
      InternetConnectionManager();
  bool? internetConnectionCheck;

  void onYearSearchTextChanged(String text) {
    setState(() {
      partsList.clear();
      savedFitmentsData.clear();
      errorFitmentsData.clear();
      currentPage = 1;
      //searchValue = text.toLowerCase();

      //searchValue = textEditingController.text.toLowerCase();

      if (yearTextController.text.isEmpty) {
        yearTextController.text = '';
        FocusScope.of(context).unfocus();
      }

      if (!isLoading) {
        isLoading = true; // Set flag to indicate data loading
        if (debounce?.isActive ?? false) debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 1000), () {
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

  void onMakeSearchTextChanged(String text) {
    setState(() {
      partsList.clear();
      savedFitmentsData.clear();
      errorFitmentsData.clear();
      currentPage = 1;
      //searchValue = text.toLowerCase();

      //searchValue = textEditingController.text.toLowerCase();

      if (makeTextController.text.isEmpty) {
        makeTextController.text = '';
        FocusScope.of(context).unfocus();
      }

      if (!isLoading) {
        isLoading = true; // Set flag to indicate data loading
        if (debounce?.isActive ?? false) debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 1000), () {
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

  void onModelSearchTextChanged(String text) {
    setState(() {
      partsList.clear();
      savedFitmentsData.clear();
      errorFitmentsData.clear();
      currentPage = 1;
      //searchValue = text.toLowerCase();

      //searchValue = textEditingController.text.toLowerCase();

      if (modelTextController.text.isEmpty) {
        modelTextController.text = '';
        FocusScope.of(context).unfocus();
      }

      if (!isLoading) {
        isLoading = true; // Set flag to indicate data loading
        if (debounce?.isActive ?? false) debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 1000), () {
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

  Future<void> dataLableFetch() async {
    partAndFitmentLbl =
        await LanguageChange().strTranslatedValue('Parts Information');
    savedFitmentLbl =
        await LanguageChange().strTranslatedValue('Saved Fitments');
    errorFitmentLbl =
        await LanguageChange().strTranslatedValue('Error Fitments');

    partNumberLbl = await LanguageChange().strTranslatedValue('Part No');
    partTypeLbl = await LanguageChange().strTranslatedValue('PT Name');
    partASINLbl = await LanguageChange().strTranslatedValue('ASIN');
    partBrandIDLbl = await LanguageChange().strTranslatedValue('Brand ID');
    partManufactureLbl =
        await LanguageChange().strTranslatedValue('Manufacture Label');
    partDescLbl = await LanguageChange().strTranslatedValue('Part Description');
    partFitmentLbl = await LanguageChange().strTranslatedValue('Fitment');
    yearSearchLbl = await LanguageChange().strTranslatedValue('Year');
    makeSearchLbl = await LanguageChange().strTranslatedValue('Make');
    modelSearchLbl = await LanguageChange().strTranslatedValue('Model');

    internetTitleLbl =
        await LanguageChange().strTranslatedValue('Internet Title');
    internetMsgLbl =
        await LanguageChange().strTranslatedValue('Internet Message');
    retryBtnLbl = await LanguageChange().strTranslatedValue('Retry');

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataLableFetch();

    // Create TabController for getting the index of current tab
    //_tabController = TabController(length: 5, vsync: this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(handleTabSelection);

    internetConnectionManager.checkInternetConnection(() {
      if (mounted) {
        setState(() {
          internetConnectionCheck = internetConnectionManager.internetCheck;
          if (internetConnectionCheck != null && internetConnectionCheck!) {
            partsList.clear();
            savedFitmentsData.clear();
            errorFitmentsData.clear();
            currentPage = 1;
            fetchData();
          }
        });
      }
    });

    //fetchData();
    _scrollController.addListener(scrollListener11);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(scrollListener11);
    _scrollController.dispose();
    debounce?.cancel();
    yearTextController.dispose();
    makeTextController.dispose();
    modelTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          /*actions: [
            IconButton(
              onPressed: () {
                //_showPartInfoBottomDialog(context);
              },
              icon: const Icon(Icons.more_vert_sharp),
            ),
          ],*/
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _tabController,
              tabs: TabValues.getTabs(context, savedFitmentLbl, errorFitmentLbl,
                  widget.savedFitmentsCount, widget.errorFitmentsCount),
            ),
          ),
          title: Text(
              partAndFitmentLbl.isNotEmpty
                  ? partAndFitmentLbl
                  : 'Parts & Information',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
        ),
        body: _buildUIContent()

        /*SingleChildScrollView(
          child: Column(
            children: [
              _buildCardContent(),
              _buildContentSearchView(),
              //Expanded(child: child)
              const SizedBox(height: 10,),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  // Disable swipe
                  controller: _tabController,
                  children: [
                    // Saved Fitments content
                    buildFitmentsList(savedFitmentsData),
                    // Error Fitments content
                    buildFitmentsList(errorFitmentsData),
                  ],
                ),
              ),
            ],
          ),
        )*/

        /*Column(
          children: [
            _buildCardContent(),//TODO:Sized Box Crete UI
            */ /*const SizedBox(
              height: 10,
            ),*/ /*
            _buildContentSearchView(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                controller: _tabController,
                children: [
                  // Saved Fitments content
                  buildFitmentsList(savedFitmentsData),
                  // Error Fitments content
                  buildFitmentsList(errorFitmentsData),
                ],
              ),
            ),
          ],
        )*/
        );
  }

  Widget _buildUIContent() {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyPartsAndFitmentInfoPage(
                partNumber: widget.partNumber,
                partTypeName: widget.partTypeName,
                asin: widget.asin,
                partTerminologyID: widget.partTerminologyID,
                brandID: widget.brandID,
                manufactureLabel: widget.manufactureLabel,
                partDescription: widget.partDescription,
                fitments: widget.fitments,
                partID: widget.partID,
                savedFitmentsCount: widget.savedFitmentsCount,
                errorFitmentsCount: widget.errorFitmentsCount,
              ),
            ),
          );
        },
      );
    } else {
      // If there is internet, show the main content
      return Column(
        children: [
          buildCardContent(), //TODO:Sized Box Crete UI
          /*const SizedBox(
              height: 10,
            ),*/
          buildContentSearchView(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              controller: _tabController,
              children: [
                // Saved Fitments content
                buildFitmentsList(savedFitmentsData),
                // Error Fitments content
                buildFitmentsList(errorFitmentsData),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget buildContentSearchView() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 40,
            margin: const EdgeInsets.only(
              left: 5.0,
              right: 5.0,
            ),
            child: TextField(
              controller: yearTextController,
              onChanged: onYearSearchTextChanged,
              decoration: InputDecoration(
                hintText: yearSearchLbl.isNotEmpty ? yearSearchLbl : 'Year',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Visibility(
            visible: true,
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              child: TextField(
                controller: makeTextController,
                onChanged: onMakeSearchTextChanged,
                decoration: InputDecoration(
                  hintText:
                      makeSearchLbl.isNotEmpty ? makeSearchLbl : 'Make...',
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
        ),
        Expanded(
          flex: 3,
          child: Visibility(
            visible: true,
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              child: TextField(
                controller: modelTextController,
                onChanged: onModelSearchTextChanged,
                decoration: InputDecoration(
                  hintText:
                      modelSearchLbl.isNotEmpty ? modelSearchLbl : 'Model...',
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
        ),
      ],
    );
  }

  Widget buildFitmentsList(List<dynamic> fitmentsData) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (fitmentsData.isNotEmpty)
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              //physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: fitmentsData.length,
              itemBuilder: (context, index) {
                final part = fitmentsData[index];
                return buildUIContentWithoutCard(
                    part['Year'], part['Make'], part['Model'], part['Qty']);
              },
            ),
          ),
        if (isLoading)
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

  Widget buildCardContent1() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.32,
                  child: Text(
                      partNumberLbl.isNotEmpty ? partNumberLbl : 'Part Number',
                      textAlign: TextAlign.start),
                ),
                const Text(
                  ' : ',
                ),
                Expanded(
                  child: Text(widget.partNumber, textAlign: TextAlign.start),
                ),
              ],
            ),
          ),
          Visibility(visible: true, child: showHideContent1()),
        ],
      ),
    );
  }

  Widget buildCardContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isHeaderContent = !isHeaderContent;
                });
              },
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.32,
                    child: Text(
                        partNumberLbl.isNotEmpty
                            ? partNumberLbl
                            : 'Part Number',
                        textAlign: TextAlign.start),
                  ),
                  const Text(
                    ' : ',
                  ),
                  Expanded(
                    child: Text(widget.partNumber, textAlign: TextAlign.start),
                  ),
                  Visibility(
                    visible: false,
                    child: Icon(
                      isHeaderContent
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(visible: isHeaderContent, child: showHideContent()),
        ],
      ),
    );
  }

  Widget showHideContent1() {
    return Column(
      children: [
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(partTypeLbl.isNotEmpty ? partTypeLbl : 'Part Type',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.partTypeName, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(partASINLbl.isNotEmpty ? partASINLbl : 'ASIN',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.asin, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partBrandIDLbl.isNotEmpty ? partBrandIDLbl : 'Brand ID',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.brandID, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partManufactureLbl.isNotEmpty
                        ? partManufactureLbl
                        : 'Manufacture Label',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child:
                    Text(widget.manufactureLabel, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partDescLbl.isNotEmpty ? partDescLbl : 'Part Description',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.partDescription, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partFitmentLbl.isNotEmpty ? partFitmentLbl : 'Fitment #',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.fitments, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showHideContent() {
    return Column(
      children: [
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(partTypeLbl.isNotEmpty ? partTypeLbl : 'Part Type',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.partTypeName, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(partASINLbl.isNotEmpty ? partASINLbl : 'ASIN',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.asin, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partBrandIDLbl.isNotEmpty ? partBrandIDLbl : 'Brand ID',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.brandID, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partManufactureLbl.isNotEmpty
                        ? partManufactureLbl
                        : 'Manufacture Label',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child:
                    Text(widget.manufactureLabel, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partDescLbl.isNotEmpty ? partDescLbl : 'Part Description',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.partDescription, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        Container(
          height: 0.25,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.red, // Replace with your desired color
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                    partFitmentLbl.isNotEmpty ? partFitmentLbl : 'Fitment #',
                    textAlign: TextAlign.start),
              ),
              const Text(
                ' : ',
              ),
              Expanded(
                child: Text(widget.fitments, textAlign: TextAlign.start),
              ),
            ],
          ),
        ),
        const Divider(
          thickness: 5,
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget buildUIContentCard(
      String year, String make, String model, String qty) {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            children: [
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Year',
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Make',
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Model',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      year,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: Container(
                      height: 20,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      color: Colors.red, // Replace with your desired color
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      make,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: Container(
                      height: 20,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      color: Colors.red, // Replace with your desired color
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      model,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUIContentWithoutCard(
      String year, String make, String model, String qty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // Align content in the center horizontally
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Text(
                    year,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  height: 20,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  color: Colors.red, // Replace with your desired color
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 10.0,
                  ),
                  child: Text(
                    make,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  height: 20,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  color: Colors.red, // Replace with your desired color
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 10.0,
                  ),
                  child: Text(
                    model,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: true,
            child: Container(
              height: 0.5,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.red, // Replace with your desired color
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFitmentsList1(List<dynamic> fitmentsData) {
    return Column(
      children: [
        Container(
          // Container for the header containing 'Year', 'Make', 'Model'
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Center(child: Text('Year'))),
                  Expanded(child: Center(child: Text('Make'))),
                  Expanded(child: Center(child: Text('Model'))),
                ],
              ),
              Container(
                height: 0.25,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: Colors.red,
              ),
            ],
          ),
        ),
        if (fitmentsData.isNotEmpty)
          Expanded(
            // Flexible or Expanded to make the list scrollable
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: fitmentsData.length,
              itemBuilder: (context, index) {
                final part = fitmentsData[index];
                return buildUIContentWithoutCard(
                  part['Year'],
                  part['Make'],
                  part['Model'],
                  part['Qty'],
                );
              },
            ),
          ),
        if (isLoading)
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 3,
            ),
          ),
      ],
    );
  }

  // ignore: unused_element
  void scrollListener1() {
    setState(() {
      isHeaderContent = false;
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        loadMoreData();
      }
    });
  }

  void scrollListener11() {
    setState(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          isHeaderContent) {
        isHeaderContent = false;
        loadMoreData();
      } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          !_scrollController.position.outOfRange &&
          !isHeaderContent) {
        isHeaderContent = true;
      }
    });
  }

  // ignore: unused_element
  void scrollListener() {
    setState(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          isHeaderContent) {
        isHeaderContent = false;
        loadMoreData();
      } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          !_scrollController.position.outOfRange &&
          !isHeaderContent) {
        isHeaderContent = true;
      }
    });
  }

  void handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          setState(() {
            yearTextController.text = '';
            makeTextController.text = '';
            modelTextController.text = '';
            isInfoSaved = true;
            partsList.clear();
            savedFitmentsData.clear();
            errorFitmentsData.clear();
            currentPage = 1;
            fetchData();
          });
          break;
        case 1:
          setState(() {
            yearTextController.text = '';
            makeTextController.text = '';
            modelTextController.text = '';
            isInfoSaved = false;
            partsList.clear();
            savedFitmentsData.clear();
            errorFitmentsData.clear();
            currentPage = 1;
            fetchData();
          });
          break;
      }
    }
  }

  // ignore: unused_element
  void showPartInfoBottomDialog(BuildContext context) {
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
                      height: 5,
                    ),
                    Text(
                      partAndFitmentLbl.isNotEmpty
                          ? partAndFitmentLbl
                          : 'Parts & Information',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    buildCardContent1()
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchData() async {
    if (await Network.isConnected()) {
      try {
        setState(() {
          isLoading = true;
        });

        // Fetching data
        // ignore: prefer_typing_uninitialized_variables
        if (context.mounted) {
          dynamic response;

          if (isInfoSaved) {
            response =
                await MyPartsAndFitmentAPI.getSavedMyPartsAndFitmentAPICall(
                    context,
                    PreferenceUtils.getLoginUserId(),
                    widget.partID,
                    currentPage.toString(),
                    yearTextController.text,
                    makeTextController.text,
                    modelTextController.text);
          } else {
            response =
                await MyPartsAndFitmentAPI.getErrorMyPartsAndFitmentAPICall(
                    context,
                    PreferenceUtils.getLoginUserId(),
                    widget.partID,
                    currentPage.toString(),
                    yearTextController.text,
                    makeTextController.text,
                    modelTextController.text);
          }

          if (response['StatusCode'] == 200) {
            /*setState(() {
          totalPages = response['totalPages'];
          if (currentPage == 1) {
            partsList = response['data'];
          } else {
            partsList.addAll(response['data']);
          }
        });*/

            setState(() {
              totalPages = response['totalPages'];
              /*if (currentPage == 1) {
            if (isInfoSaved) {
              savedFitmentsData = response['data'];
            } else {
              errorFitmentsData =
                  response['data']; // Assign data to errorFitmentsData
            }
          } else {
            if (isInfoSaved) {
              savedFitmentsData
                  .addAll(response['data']); // Add to savedFitmentsData
            } else {
              errorFitmentsData
                  .addAll(response['data']); // Add to errorFitmentsData
            }
          }*/

              if (isInfoSaved) {
                savedFitmentsData
                    .addAll(response['data']); // Add to savedFitmentsData
              } else {
                errorFitmentsData
                    .addAll(response['data']); // Add to errorFitmentsData
              }
            });

            // Dismiss the progress indicator after data is set
            setState(() {
              isLoading = false;
            });
          } else if (response['StatusCode'] == 204) {
            setState(() {
              isLoading = false;
            });

            if (context.mounted) {
              snackBarErrorMsg(
                  context,
                  response != null
                      ? response['Message']
                      : 'Invalid response from server');
            }
            //CustomBottomSheet.showNoRecordBottomSheet(context: context);
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
          //snackBarErrorMsg(context, 'Please contact to system admin');
          snackBarErrorMsg(context, Constants.somethingWrongMsg);
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
}

class TabValues {
  static List<Tab> getTabs(BuildContext context, String saved, String error,
      String savedFitmentsCount, String errorFitmentsCount) {
    return [
      Tab(
        icon: const Icon(Icons.save),
        text: '$saved($savedFitmentsCount)',
      ),
      Tab(
        icon: const Icon(Icons.error),
        text: '$error($errorFitmentsCount)',
      ),
    ];
  }
}
