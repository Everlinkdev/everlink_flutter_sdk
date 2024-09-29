abstract class EverlinkSdkEvent {
  const EverlinkSdkEvent();
}

class GeneratedTokenEvent extends EverlinkSdkEvent {
  final String oldToken;
  final String newToken;

  const GeneratedTokenEvent(this.oldToken, this.newToken);
}

class DetectionEvent extends EverlinkSdkEvent {
  final String detectedToken;

  const DetectionEvent(this.detectedToken);
}
