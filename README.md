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

### iOS
- In Terminal, navigate to the project’s `ios/` directory
- Install project dependencies using CocoaPods

    ```console
      $ cd your_flutter_project/ios/
    ```
    ```console
      $ pod install
    ```
 - In Xcode, edit file `Info.plist` located in Runner > Runner. Add Privacy - Microphone Usage Description in the `info.plist` file for microphone access.

## Usage

- Import `everlink_sdk.dart` and `everlink_sdk_event.dart`
       
   ```dart
   import 'package:everlink_sdk/everlink_sdk.dart';
   import 'package:everlink_sdk/everlink_sdk_event.dart';
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
    everlinkSdk.onEvent.listen((event) {
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
      await everlinkSdk.startDetecting();
  }
  Future<void> everlinkStopDetecting() async {
      await everlinkSdk.stopDetecting();
  }
  ```
  
  *Note users will be prompted to grant microphone permission.*

  On successful detection we will return the identifying token of the detected device via the **everlink_sdk_event** EventChannel broadcast stream. You will need to call startDetecting() again to detect another audiocode.

  ‍You can now search your database or locally using the returned Everlink unique identifying token to find the detected user. 
  
  You might have some code like this:

  ```sql
  "SELECT * FROM employees WHERE everlink_token = token";
  }
  ```

- Send code
  ```dart
  Future<void> everlinkStartEmitting() async {
      await everlinkSdk.startEmitting();
  }
  Future<void> everlinkStopEmitting() async {
      await everlinkSdk.stopEmitting();
  }
  ```

  This will cause the device to start emitting the audiocode of the latest token generated on the device.

  You can alternatively pass a token as an argument and its audiocode will play, as shown below:

  ```dart
  Future<void> everlinkStartEmittingToken(String token) async {
      await everlinkSdk.startEmittingToken(token);
  }
  ```

- Volume settings

  Function playVolume(volume, loudspeaker) allows you to set the volume and whether the audio should default to the loudspeaker.

  ```dart
  Future<void> everlinkPlayVolume(double volume, bool loudSpeaker) async {
      await everlinkSdk.playVolume(volume, loudSpeaker);
  }
  ```

  We can detect if headphones are in use, and route the audio to the device’s loud speaker. Though users might experience a short pause in any audio they are listening to, while the audiocode is played, before we automatically resume playing what they were listening to before the interruption.

- Create token

  If you wish to manually generate a new user token. *Otherwise one will be automatically generated.*

  ```dart
  Future<void> everlinkNewToken(String date, [int? validityPeriod]) async {
      await everlinkSdk.newToken(date, validityPeriod);
  }
  ```

  On successful detection we will return the identifying token of the heard device via the **everlink_sdk_event** EventChannel broadcast stream.

  *Function newToken(startDate, validityPeriod) takes a validity start date in the form 'YYYY-MM-DD’. If no validity date is provided then it will be the current date. You also can provide an optional token validity period between 1 and 30 days. If no token validity period is provided this will be set to 30 days. Once a device token is expired it will automatically refresh.*

- Downloading tokens (needed if you want the SDK to work offline)

  ```dart
  Future<void> everlinkSaveTokens(List<String> tokens) async {
      await everlinkSdk.saveTokens(tokens);
  }
  ```

  For situations where it is possible to download your users' tokens prior to detecting, we strongly recommend that you do. This will reduce latency and make the verification faster and more reliable.

## Error Handling

The Everlink SDK provides robust error handling using the `EverlinkError` class, which encapsulates the error code and message for easier debugging and consistency. Errors from platform calls are converted to `EverlinkError` using the `toEverlinkError` extension.

#### Example: Handling Errors When Starting Detection

Here’s an example of how to handle errors:


#### Setup Everlink
```dart
void setupEverlink() async {
  try {
    await everlinkSdk.setupEverlink('yourAppID');
    print('Setup completed successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Start Detecting
```dart
void startDetection() async {
  try {
    await everlinkSdk.startDetecting();
    print('Detection started successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Stop Detecting
```dart
void stopDetection() async {
  try {
    await everlinkSdk.stopDetecting();
    print('Detection stopped successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Generate New Token
```dart
void generateNewToken(String date) async {
  try {
    await everlinkSdk.newToken(date);
    print('New token generated successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Save Tokens
```dart
void saveTokens(List<String> tokens) async {
  try {
    await everlinkSdk.saveTokens(tokens);
    print('Tokens saved successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Clear Tokens
```dart
void clearTokens() async {
  try {
    await everlinkSdk.clearTokens();
    print('Tokens cleared successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Start Emitting
```dart
void startEmitting() async {
  try {
    await everlinkSdk.startEmitting();
    print('Started emitting successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Start Emitting Token
```dart
void startEmittingToken(String token) async {
  try {
    await everlinkSdk.startEmittingToken(token);
    print('Started emitting token successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Stop Emitting
```dart
void stopEmitting() async {
  try {
    await everlinkSdk.stopEmitting();
    print('Stopped emitting successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

#### Change Play Volume
```dart
void changeVolume(double volume, bool loudSpeaker) async {
  try {
    await everlinkSdk.playVolume(volume, loudSpeaker);
    print('Volume changed successfully.');
  } on EverlinkError catch (e) {
    print('Error occurred: ${e.toString()}');
  } catch (e) {
    print('Unexpected error: $e');
  }
}

```
---

To learn more, **[general documentation](https://developer.everlink.co/developer-documention/android)**,
**[error codes documentation](https://everlinkdev.github.io/everlink-error-handling/)**.