// the code below is using the mobile camera that  take a shot and send it to the server to procces it

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rabea2/LiveStreamPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  String? _result;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://158.220.103.185:5482/api'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      // تحويل الاستجابة إلى JSON
      Map<String, dynamic> jsonResponse = jsonDecode(responseData);
      setState(() {
        _result = jsonResponse['output'].toString(); // عرض النتائج
      });
    } else {
      setState(() {
        _result = 'Error: ${response.statusCode}';
      });
    }
  }

  /// now we comment the whole function that are not response the data from the server and we will create another function to handle the data from the server
  //Future<void> _uploadImage() async {
  /// this code that we commen it is not response any data from the server
  // if (_image == null) return;

  // var request = http.MultipartRequest(
  //   'POST',
  //   Uri.parse('http://10.14.7.151:5000/api'),
  // );

  // request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

  // var response = await request.send();
  // var responseData = await response.stream.bytesToString();

  // if (response.statusCode == 200) {
  //   setState(() {
  //     _result = responseData;
  //     print('server response : $responseData');
  //   });
  // } else {
  //   setState(() {
  //     _result = 'Error: ${response.statusCode}';
  //   });
  // }
  // print('server response : $responseData');
  //}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seeing Through Sound ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: Image.asset("assets/icons/object.png", color: Colors.blue),
        backgroundColor: Color(0xff3E5879),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_image!, height: 260),
                )
                : Text(
                  'No image selected',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              label: Text(
                'Take Picture',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff3E5879),
                minimumSize: Size(double.infinity, 50),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.videocam, color: Colors.white, size: 20),
              label: Text(
                'Start Live Detection',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LiveStreamPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff3E5879),
                minimumSize: Size(double.infinity, 50),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),

            SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _result != null ? 'Result: $_result' : 'No result yet',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
