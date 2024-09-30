# Everlink Flutter SDK

Allows apps developed using Flutter to use Everlink’s native SDKs to enable proximity verification via ultrasound.

## Installation

### Android

- Edit `android/build.gradle` to look like this

    ```diff
    allprojects {
        repositories {
            ...
            google()
            mavenCentral()
    +       maven {
    +           url "https://repo.everlink.co/repository/maven-releases/"
    +       }
        }
    }
    ```
  *Sync project if required*

## Usage

- Import `everlink_sdk.dart`
       
   ```dart
   import 'package:everlink_sdk/everlink_sdk.dart';
   ```

- Initialize EverlinkSdk class passing it your **appID key**

   ```dart
   final everlinkSdk = EverlinkSdk("your appID key");
   ```

- Set up event listener

  ```dart
  @override
  void initState() {
    super.initState();
    _listenToSdkEvents();
  }

  void _listenToSdkEvents() {
    _everlinkSdk.onEvent.listen((event) {
      if (event is GeneratedTokenEvent) {
        log('Generated token: Old - ${event.oldToken}, New - ${event.newToken}');
        //a new token generated, to save in your database
      } else if (event is DetectionEvent) {
        doSomethingWithDetectedToken(event.detectedToken);
        //you can now identify via the returned token what location/device was heard
      }
    }, onError: (error) {
      log('Error receiving SDK event: $error');
    });
  }
  ```

- Detect code
  ```dart
  Future<void> everlinkStartDetecting() async {
  everlinkSdk.startDetecting();
  }
  Future<void> everlinkStopDetecting() async {
  everlinkSdk.stopDetecting();
  }
  ```
  
  *Note users will be prompted to grant microphone permission.*

  On successful detection we will return the identifying token of the detected device via the **everlink_sdk_event** EventChannel broadcast stream.

  ‍You can now search your database or locally using the returned Everlink unique identifying token to find the detected user. 
  
  You might have some code like this:

  ```sql
  "SELECT * FROM employees WHERE everlink_token = token";
  }
  ```

- Send code
  ```dart
  Future<void> everlinkStartEmitting() async {
    everlinkSdk.startEmitting();
  }
  Future<void> everlinkStopEmitting() async {
    everlinkSdk.stopEmitting();
  }
  ```

  This will cause the device to start emitting the audiocode of the latest token generated on the device.

  You can alternatively pass a token as an argument and its audiocode will play, as shown below:

  ```dart
  Future<void> everlinkStartEmittingToken(String token) async {
    everlinkSdk.startEmittingToken(token);
  }
  ```

- Volume settings

  Function playVolume(volume, loudspeaker) allows you to set the volume and whether the audio should default to the loudspeaker.

  ```dart
  Future<void> everlinkPlayVolume(double volume, bool loudSpeaker) async {
    everlinkSdk.playVolume(volume, loudSpeaker);
  }
  ```

  We can detect if headphones are in use, and route the audio to the device’s loud speaker. Though users might experience a short pause in any audio they are listening to, while the audiocode is played, before we automatically resume playing what they were listening to before the interruption.

- Create token

  If you wish to manually generate a new user token. *Otherwise one will be automatically generated.*

  ```dart
  Future<void> everlinkNewToken(String date) async {
    everlinkSdk.newToken(date);
  }
  ```

  On successful detection we will return the identifying token of the heard device via the **everlink_sdk_event** EventChannel broadcast stream.

  *Function newToken(startDate) takes a validity start date in the form 'YYYY-MM-DD’. The token will be valid for two weeks after this date. If no validity date is provided then it will be the current date.  Once a device token is expired it will automatically refresh.*

- Downloading tokens (needed if you want the SDK to work offline)

  ```dart
  Future<void> everlinSaveTokens(List<String> tokens) async {
    everlinkSdk.saveTokens(tokens);
  }
  ```

  For situations where it is possible to download your users' tokens prior to detecting, we strongly recommend that you do. This will reduce latency and make the verification faster and more reliable.

---

To learn more, **[read this](https://developer.everlink.co/developer-documention/android)**.
