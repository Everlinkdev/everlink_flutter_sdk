import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'everlink_sdk_event.dart';

// Key constants used throughout the code
const everlinkSdkKey = "everlink_sdk";
const everlinkSdkEventKey = "everlink_sdk_event";
const appIDKey = "appID";
const setupMethodKey = "setup";
const startDateKey = "start_date";
const tokensKey = "tokens";
const tokenKey = "token";
const volumeKey = "volume";
const loudSpeakerKey = "loudSpeaker";
const appIdKey = "testAppID";
const msgTypeKey = 'msg_type';
const dataKey = 'data';
const oldTokenKey = 'old_token';
const newTokenKey = 'new_token';

// Method key constants to handle specific method calls
const startDetectingMethodKey = "startDetecting";
const stopDetectingMethodKey = "stopDetecting";
const createNewTokenMethodKey = "createNewToken";
const saveTokenMethodKey = "saveTokens";
const clearTokensMethodKey = "clearTokens";
const startEmittingMethodKey = "startEmitting";
const startEmittingTokenMethodKey = "startEmittingToken";
const stopEmittingMethodKey = "stopEmitting";
const playVolumeMethodKey = "playVolume";

class EverlinkSdk {
  static const methodChannel = MethodChannel(everlinkSdkKey);
  static const eventChannel = EventChannel(everlinkSdkEventKey);

  final StreamController<EverlinkSdkEvent> _eventController =
      StreamController<EverlinkSdkEvent>.broadcast();

  EverlinkSdk(String appID) {
    _setupEverlink(appID);
    _initializeEventChannel();
  }

  Future<void> _setupEverlink(String appID) async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(setupMethodKey, {appIDKey: appID});
      printString = 'Everlink plugin successfully setup.';
    } on PlatformException catch (e) {
      printString = "Everlink plugin unable to be setup: '${e.message}'.";
    }
    log(printString);
  }

  void _initializeEventChannel() {
    eventChannel.receiveBroadcastStream().listen((dynamic event) {
      try {
        final parsedJson = jsonDecode(event.toString());
        var msgType = parsedJson[msgTypeKey];
        var data = parsedJson[dataKey];

        switch (msgType) {
          case 'generated_token':
            var oldToken = data[oldTokenKey];
            var newToken = data[newTokenKey];
            _eventController.add(GeneratedTokenEvent(oldToken, newToken));
            break;
          case 'detection':
            var detectedToken = data[tokenKey];
            _eventController.add(DetectionEvent(detectedToken));
            break;
          default:
            break;
        }
      } on Exception catch (e) {
        log('Unknown exception: $e');
      } catch (e) {
        log('Something really unknown: $e');
      }
    }, onError: (dynamic error) {
      log("Error: $error");
    });
  }

  // Public API to get the event stream
  Stream<EverlinkSdkEvent> get onEvent => _eventController.stream;

  Future<void> startDetecting() async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(startDetectingMethodKey);
      printString = 'Everlink started detecting.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to start detecting: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> stopDetecting() async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(stopDetectingMethodKey);
      printString = 'Everlink stopped detecting.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to stop detecting: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> newToken(String date) async {
    String printString;
    try {
      await methodChannel
          .invokeMethod<void>(createNewTokenMethodKey, {startDateKey: date});
      printString = 'Everlink created new token.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to create new token: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> saveTokens(List<String> tokens) async {
    String printString;
    try {
      await methodChannel
          .invokeMethod<void>(saveTokenMethodKey, {tokensKey: tokens});
      printString = 'Everlink saved tokens array.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to save tokens array: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> clearTokens() async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(clearTokensMethodKey);
      printString = 'Everlink cleared tokens array.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to clear tokens array.: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> startEmitting() async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(startEmittingMethodKey);
      printString = 'Everlink started emitting.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to start emitting.: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> startEmittingToken(String token) async {
    String printString;
    try {
      await methodChannel
          .invokeMethod<void>(startEmittingTokenMethodKey, {tokenKey: token});
      printString = 'Everlink started emitting.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to start emitting.: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> stopEmitting() async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(stopEmittingMethodKey);
      printString = 'Everlink stopped emitting.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to stop emitting.: '${e.message}'.";
    }
    log(printString);
  }

  Future<void> playVolume(double volume, bool loudSpeaker) async {
    String printString;
    try {
      await methodChannel.invokeMethod<void>(playVolumeMethodKey,
          {volumeKey: volume, loudSpeakerKey: loudSpeaker});
      printString = 'Everlink changed play volume.';
    } on PlatformException catch (e) {
      printString = "Everlink unable to change play volume.: '${e.message}'.";
    }
    log(printString);
  }

  void dispose() {
    _eventController.close();
  }
}
