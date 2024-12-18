import 'package:flutter/services.dart';

class EverlinkError implements Exception {
  final String errorCode;
  final String message;

  EverlinkError(this.errorCode, this.message);

  @override
  String toString() {
    return "EverlinkError(code: $errorCode, message: $message)";
  }
}

extension ExEverlink on PlatformException {
  EverlinkError toEverlinkError() {
    return EverlinkError(code, message ?? "Unknown Error Occurred");
  }
}
