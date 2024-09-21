import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:everlink_sdk/everlink_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MainApp();
}


class MainApp extends State<MyApp>  {

    @override
  void initState() {
    super.initState();
    setEvents();
  }

    final everlinkSdk = EverlinkSdk("test");

    Future<void> everlinkStartDetecting() async {
      everlinkSdk.startDetecting();
    }
    Future<void> everlinkStopDetecting() async {
      everlinkSdk.startDetecting();
    }
    Future<void> everlinkNewToken(String date) async {
      everlinkSdk.newToken(date);
    }
    Future<void> everlinSaveTokens(List<String> tokens) async {
      everlinkSdk.saveTokens(tokens);
    }
    Future<void> everlinkClearTokens() async {
      everlinkSdk.clearTokens();
    }
    Future<void> everlinkStartEmitting() async {
      everlinkSdk.startEmitting();
    }
    Future<void> everlinkStartEmittingToken(String token) async {
      everlinkSdk.startEmittingToken(token);
    }
    Future<void> everlinkStopEmitting() async {
      everlinkSdk.stopEmitting();
    }
    Future<void> everlinkPlayVolume(double volume, bool loudSpeaker) async {
      everlinkSdk.playVolume(volume, loudSpeaker);
    }

static const eventChannel = EventChannel('myplugin_event');


  void setEvents() { 
    eventChannel.receiveBroadcastStream().listen((dynamic event) {
      try {
      final parsedJson = jsonDecode(event.toString());
      var msgType = parsedJson['msg_type'].toString();
      var data = parsedJson['data'];

      switch (msgType) {
        case 'newToken':
          
          break;
        default:
      }
      } on Exception catch (e) {
  // Anything else that is an exception
  print('Unknown exception: $e');
} catch (e) {
  // No specified type, handles all
  print('Something really unknown: $e');
}
      print("*****Event repeat from native******: $event");
    }, onError: (dynamic error) {
      print("Error: $error");
    });

  }

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
           appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('Test'),
            ),
      body: Column(
        children: [
          const Text('Everlink Plugin'),
          ElevatedButton(
            onPressed: () {
              everlinkStartDetecting();
            },
            child: const Text('Start Detecting'),
          ),
          ElevatedButton(
            onPressed: () {
              everlinkStopDetecting();
            },
            child: const Text('Stop Detecting'),
          ),
           ElevatedButton(
            onPressed: () {
              const date = "2024";
              everlinkNewToken(date);
            },
            child: const Text('New Token'),
          ),
           ElevatedButton(
            onPressed: () {
              const tokensList = [ 'token', 'token' ];
              everlinSaveTokens(tokensList);

            },
            child: const Text('Save Tokens'),
          ),
           ElevatedButton(
            onPressed: () {
              everlinkClearTokens();
            },
            child: const Text('Clear Tokens'),
          ),
            ElevatedButton(
            onPressed: () {
              everlinkStartEmitting();
            },
            child: const Text('Start Emitting'),
          ),
            ElevatedButton(
            onPressed: () {
              const token = "token";
              everlinkStartEmittingToken(token);
            },
            child: const Text('Start Emitting Token'),
          ),
                    ElevatedButton(
            onPressed: () {
              everlinkStopEmitting();
            },
            child: const Text('Stop Emitting'),
          ),
                    ElevatedButton(
            onPressed: () {
              const volume = 0.9;
              const useLoudSpeaker = true;
              everlinkPlayVolume(volume, useLoudSpeaker);
            },
            child: const Text('Play Volume'),
          ),
        ],
      ),
    ));
  
}
}

