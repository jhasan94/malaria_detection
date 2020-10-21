import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  bool loading = false;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _upload(File file) async {
    setState(() {
      loading = true;
    });
    String fileName = file.path.split('/').last;
    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    Dio dio = new Dio();
    dio
        .post("https://deploy-rbc-test.herokuapp.com/api/predict_multiple",
            data: data)
        .then((response) {
      print(response.data);
      setState(() {
        loading = false;
        result = response.data[0]['Result'][0].toString();
        //calculation = response.data[1]['calculation'].toString();
        No = response.data[1]['calculation']['no'].toString();
        num_of_no = response.data[1]['calculation']['num_of_no'].toString();
        num_of_yes = response.data[1]['calculation']['num_of_yes'].toString();
        total = response.data[1]['calculation']['total'].toString();
        yes = response.data[1]['calculation']['yes'].toString();
      });
    }).catchError((error) => print(error));
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
                  getImage();
                },
                color: Colors.green,
              ),
              RaisedButton(
                child: Text('see result'),
                onPressed: () {
                  _upload(_image);
                },
                color: Colors.green,
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
                                'Result : $result',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'calculation : ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
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
