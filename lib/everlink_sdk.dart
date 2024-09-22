
import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:developer';


class EverlinkSdk {

static const methodChannel = MethodChannel('everlink_sdk');

EverlinkSdk(String appID) {
  _setupEverlink(appID); 
}

  Future<void> _setupEverlink(String appID) async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('setup', {"appID":appID});
    printString = 'Everlink plugin successfully setup.';
  } on PlatformException catch (e) {
      printString = "Everlink plugin unable to be setup: '${e.message}'.";
  }
  log(printString);
  }


  Future<void> startDetecting() async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('startDetecting');
    printString = 'Everlink started detecting.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to start detecting: '${e.message}'.";
  }
  log(printString);
  }
  
  Future<void> stopDetecting() async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('stopDetecting');
    printString = 'Everlink stopped detecting.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to stop detecting: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> newToken(String date) async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('createNewToken', {"start_date":date});
    printString = 'Everlink created new token.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to create new token: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> saveTokens(List<String> tokens) async {  
  String printString;

  try {
    await methodChannel.invokeMethod<void>('saveTokens', {"tokens":tokens});
    printString = 'Everlink saved tokens array.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to save tokens array: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> clearTokens() async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('clearTokens');
    printString = 'Everlink cleared tokens array.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to clear tokens array.: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> startEmitting() async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('startEmitting');
    printString = 'Everlink started emitting.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to start emitting.: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> startEmittingToken(String token) async {  
  String printString;

  try {
    await methodChannel.invokeMethod<void>('startEmittingToken', {"token":token});
    printString = 'Everlink started emitting.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to start emitting.: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> stopEmitting() async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('stopEmitting');
    printString = 'Everlink stopped emitting.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to stop emitting.: '${e.message}'.";
  }
  log(printString);
  }

  Future<void> playVolume(double volume, bool loudSpeaker) async {  
  String printString;
  try {
    await methodChannel.invokeMethod<void>('playVolume', {"volume":volume, "loudSpeaker":loudSpeaker});
    printString = 'Everlink changed play volume.';
  } on PlatformException catch (e) {
      printString = "Everlink unable to change play volume.: '${e.message}'.";
  }
  log(printString);
  }


}
