import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  final picker = ImagePicker();
  String result = 'N/A';
  String calculation = 'N/A';
  String No = 'N/A';
  String num_of_no = 'N/A';
  String num_of_yes = 'N/A';
  String total = 'N/A';
  String yes = 'N/A';
  List<String> resultsOfSample = [];
  List<String> resultsOfSampleCopy = [];
  bool loading = false;
  int imgCount = 5;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  List<File> fileImageArray = [];

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: imgCount,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Column(
          children: [
            AssetThumb(
              asset: asset,
              width: 340,
              height: 300,
            ),
            Text(
              resultsOfSample[index],
              style: TextStyle(fontSize: 6),
            ),
          ],
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    resultsOfSampleCopy.clear();
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      print("hello : " + resultList.length.toString());
    } on Exception catch (e) {
      error = e.toString();
    }
    resultList.forEach((imageAsset) async {
      final filePath =
          await FlutterAbsolutePath.getAbsolutePath(imageAsset.identifier);
      File tempFile = File(filePath);
      if (tempFile.existsSync()) {
        fileImageArray.add(tempFile);
      }
    });
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
      for (int i = 0; i < imgCount; i++) {
        resultsOfSampleCopy.add("result : ");
      }
      ;
      resultsOfSample = resultsOfSampleCopy;
    });
  }

  void _upload(List<File> imgs) async {
    setState(() {
      loading = true;
    });
    try {
      FormData formData = FormData.fromMap({
        "file": "",
      });
      for (File item in fileImageArray) {
        formData.files.addAll([
          MapEntry("file", await MultipartFile.fromFile(item.path)),
        ]);
      }
      Dio dio = new Dio();
      dio
          .post("https://deploy-rbc-test.herokuapp.com/api/predict_multiple",
              data: formData)
          .then((response) {
        print(response.data);
        setState(() {
          resultsOfSampleCopy.clear();
          loading = false;
          result = response.data[0]['Result'].toString();
          for (String item in response.data[0]['Result']) {
            resultsOfSampleCopy.add(item);
          }
          resultsOfSample = resultsOfSampleCopy;
          No = response.data[1]['calculation']['no'].toString();
          num_of_no = response.data[1]['calculation']['num_of_no'].toString();
          num_of_yes = response.data[1]['calculation']['num_of_yes'].toString();
          total = response.data[1]['calculation']['total'].toString();
          yes = response.data[1]['calculation']['yes'].toString();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Malaria Detection',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                child: _image == null
                    ? Image.asset('assets/blood.png')
                    : Image.file(_image),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text('add photo'),
                onPressed: () {
                  loadAssets();
                },
                color: Colors.green,
              ),
              RaisedButton(
                child: Text('see result'),
                onPressed: () {
                  _upload(fileImageArray);
                },
                color: Colors.green,
              ),
              Expanded(
                child: buildGridView(),
              ),
              Container(
                height: 200,
                width: 300,
                color: Colors.teal,
                child: loading == true
                    ? Container(
                        child: Image.asset('assets/loading2.png'),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Total Calculation : ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'No : $No',
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'num_of_no : $num_of_no',
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'num_of_yes : $num_of_yes',
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'total : $total',
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'yes : $yes',
                              ),
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
}
