import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveStreamPage extends StatefulWidget {
  @override
  _LiveStreamPageState createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  Timer? _timer;
  String? _result = 'Waiting for detection...';
  // add the voive package code here
  final FlutterTts flutterTts = FlutterTts();

  bool _isSpeaking = false; // flag to track if TTS is currently speaking

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initTTS(); // initi the TTS func HERE
  }

  // add initials for TTS
  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Set completion handler to reset _isSpeaking flag
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    setState(() {}); // to update UI

    _startStreaming();
  }

  void _startStreaming() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized ||
          _isDetecting)
        return;

      try {
        _isDetecting = true;

        final image = await _cameraController!.takePicture();
        final file = File(image.path);

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.43.240:5000/api'),
          // http://158.220.103.185:5482/api this the IP of the server is static
        );

        request.files.add(
          await http.MultipartFile.fromPath('image', file.path),
        );

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(responseData);

          /// create a final for output
          final output = jsonResponse['output'];

          // Format output for display with two decimal places for distance
          String formattedOutput = output.toString();
          try {
            if (output is List) {
              List<String> formattedItems = [];
              for (var item in output) {
                if (item is Map<String, dynamic>) {
                  String object = item['class'] ?? 'object';
                  double distance = 0.0;
                  if (item['distance'] != null) {
                    distance =
                        (item['distance'] is double)
                            ? item['distance']
                            : double.tryParse(item['distance'].toString()) ??
                                0.0;
                  }
                  formattedItems.add(
                    "{'class': '$object', 'distance': ${distance.toStringAsFixed(2)}}",
                  );
                } else {
                  formattedItems.add(item.toString());
                }
              }
              formattedOutput = "[${formattedItems.join(', ')}]";
            }
          } catch (e) {
            print('Error formatting output for display: $e');
          }

          setState(() {
            //_result = jsonResponse['output'].toString();
            _result = formattedOutput;
          });
          // Convert output to JSON string if it is a List or Map before passing to _speakResult
          String outputString;
          if (output is String) {
            outputString = output;
          } else {
            outputString = jsonEncode(output);
          }
          await _speakResult(outputString);

          /// here it spuose to speak the result
          //_speakResult(_result!); //// to turn on the text to speech auto
        } else {
          setState(() {
            _result = 'Error: ${response.statusCode}';
          });
        }
      } catch (e) {
        print("Error streaming: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  // now we will convert the result to a speach
  Future<void> _speakResult(String output) async {
    try {
      if (_isSpeaking) {
        print('TTS is currently speaking. Skipping new speech.');
        return;
      }
      _isSpeaking = true;

      print('Server output for TTS: $output'); // Debug log for server output

      // Try to parse the output as JSON list
      List<dynamic> parsedList = [];
      try {
        parsedList = jsonDecode(output);
        print('Parsed output as JSON list: $parsedList');
      } catch (e) {
        print('Failed to parse output as JSON: $e');
      }

      if (parsedList.isNotEmpty) {
        var firstItem = parsedList[0];
        if (firstItem is Map<String, dynamic>) {
          String object = firstItem['class'] ?? 'object';
          double distance = 0.0;
          if (firstItem['distance'] != null) {
            distance =
                (firstItem['distance'] is double)
                    ? firstItem['distance']
                    : double.tryParse(firstItem['distance'].toString()) ?? 0.0;
          }
          String message =
              "Take care , there is a $object at ${distance.round()} cm ahead of you";
          print('Constructed TTS message: $message');
          await flutterTts.speak(message);
          return;
        }
      }

      // If parsing failed or list empty, fallback to speaking raw output
      String cleanedOutput = output.replaceAll(',', '.').trim();
      await flutterTts.speak(cleanedOutput);
    } catch (e) {
      print('Error in speech synthesis: $e');
      await flutterTts.speak('Error reading detection result');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff213555),
        title: Text(
          "Live Video Detection",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: Image.asset("assets/icons/object.png", color: Colors.blue),
      ),
      backgroundColor: Color(0xff3E5879),
      body: Column(
        children: [
          _cameraController != null && _cameraController!.value.isInitialized
              ? Expanded(
                child: AspectRatio(
                  aspectRatio: _cameraController!.value.aspectRatio,
                  child: CameraPreview(_cameraController!),
                ),
              )
              : Center(child: CircularProgressIndicator()),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            color: Colors.black.withOpacity(0.7),
            padding: EdgeInsets.all(10),
            child: Text(
              "Result : $_result",
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          // Text("Result: $_result", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
