import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:everlink_sdk/everlink_sdk.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static const eventChannel = EventChannel(everlinkSdkEventKey);
  final _everlinkSdk = EverlinkSdk(appIdKey);

  // Colors
  Color _currentBackgroundColor = const Color.fromRGBO(38, 40, 74, 1.0);
  // Constant Colors for Background
  final _buttonColor = const Color.fromRGBO(255, 107, 107, 1.0);
  final _doSomethingBackgroundColor = const Color.fromRGBO(7, 250, 52, 1.0);
  final _defaultBackgroundColor = const Color.fromRGBO(38, 40, 74, 1.0);

  @override
  void initState() {
    super.initState();
    _setEvents();
  }

  void _setEvents() {
    eventChannel.receiveBroadcastStream().listen((dynamic event) {
      try {
        final parsedJson = jsonDecode(event.toString());
        var msgType = parsedJson[msgTypeKey];
        var data = parsedJson[dataKey];

        switch (msgType) {
          case 'generated_token':
            //extract both and send to function
            var oldToken = data[oldTokenKey];
            var newToken = data[newTokenKey];
            break;
          case 'detection':
            var detectedToken = data[tokenKey];
            doSomethingWithDetectedToken(detectedToken);
          default:
        }
      } on Exception catch (e) {
        log('Unknown exception: $e');
      } catch (e) {
        // No specified type, handles all
        log('Something really unknown: $e');
      }
      //  print("event from native code $event");
    }, onError: (dynamic error) {
      log("Error: $error");
    });
  }

  Future<void> _everlinkStartDetecting() async =>
      await _everlinkSdk.startDetecting();

  Future<void> _everlinkStopDetecting() async =>
      await _everlinkSdk.stopDetecting();

  Future<void> _everlinkNewToken(String date) async =>
      await _everlinkSdk.newToken(date);

  Future<void> _everlinkSaveTokens(List<String> tokens) async =>
      await _everlinkSdk.saveTokens(tokens);

  Future<void> _everlinkClearTokens() async => await _everlinkSdk.clearTokens();

  Future<void> _everlinkStartEmitting() async =>
      await _everlinkSdk.startEmitting();

  Future<void> _everlinkStartEmittingToken(String token) async =>
      await _everlinkSdk.startEmittingToken(token);

  Future<void> _everlinkStopEmitting() async =>
      await _everlinkSdk.stopEmitting();

  Future<void> _everlinkPlayVolume(double volume, bool loudSpeaker) async =>
      await _everlinkSdk.playVolume(volume, loudSpeaker);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(38, 40, 74, 1.0),
        title: const Text('Everlink Plugin',
            style: TextStyle(
              color: Colors.white,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Example project using Everlink plugin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    )),
                const SizedBox(
                  height: 10,
                ),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Start Detecting',
                    onPressed: () async {
                      setState(
                        () => _currentBackgroundColor = _defaultBackgroundColor,
                      );
                      await _everlinkStartDetecting();
                    }),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Stop Detecting',
                    onPressed: () async => await _everlinkStopDetecting()),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'New Token',
                    onPressed: () async {
                      const date = "2024";
                      await _everlinkNewToken(date);
                    }),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Save Tokens',
                    onPressed: () async {
                      const tokensList = [
                        'evpan1d9d38808c0dc626543920c58e9d903c',
                        'evpan9823a9bbe65b0ff54968d4638a55e352'
                      ];
                      await _everlinkSaveTokens(tokensList);
                    }),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Clear Tokens',
                    onPressed: () async => await _everlinkClearTokens()),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Start Emitting',
                    onPressed: () async => await _everlinkStartEmitting()),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Start Emitting Token',
                    onPressed: () async {
                      const token = "evpan9823a9bbe65b0ff54968d4638a55e352";
                      await _everlinkStartEmittingToken(token);
                    }),
                TriggerButton(
                  buttonColor: _buttonColor,
                  title: 'Stop Emitting',
                  onPressed: () async => await _everlinkStopEmitting(),
                ),
                TriggerButton(
                    buttonColor: _buttonColor,
                    title: 'Play Volume',
                    onPressed: () async {
                      const volume = 0.9;
                      const useLoudSpeaker = true;
                      await _everlinkPlayVolume(volume, useLoudSpeaker);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void doSomethingWithDetectedToken(String token) {
    // Change Background Color
    setState(
      () => _currentBackgroundColor = _doSomethingBackgroundColor,
    );

    // Show Dialog Box
    showDialog(
      context: context,
      // Mark is as no-dismissible to make it dismiss based on time
      barrierDismissible: false,
      builder: (context) {
        // This method will invoke after a second and will dismiss the alert dialog box
        // Adjust the seconds from here
        Future.delayed(const Duration(seconds: 5)).whenComplete(
          () => Navigator.pop(context),
        );
        return AlertDialog(
          backgroundColor: _doSomethingBackgroundColor,
          title: const Text(
            'User Detected!',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          content: Text(
            token,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
        );
      },
    );
  }
}

// A Separate Widget Class for similar set of Elevated Buttons
class TriggerButton extends StatelessWidget {
  const TriggerButton(
      {super.key,
      required this.buttonColor,
      required this.onPressed,
      required this.title});
  final Color buttonColor;
  final void Function() onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: ElevatedButton(
        style: ButtonStyle(
          fixedSize: WidgetStatePropertyAll(
              Size(MediaQuery.of(context).size.width * 0.5, 42)),
          backgroundColor: WidgetStatePropertyAll(
            buttonColor,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// Key Constants
const everlinkSdkEventKey = 'everlink_sdk_event';
const appIdKey = "testAppID";
const msgTypeKey = 'msg_type';
const dataKey = 'data';
const tokenKey = 'token';
const oldTokenKey = 'old_token';
const newTokenKey = 'new_token';