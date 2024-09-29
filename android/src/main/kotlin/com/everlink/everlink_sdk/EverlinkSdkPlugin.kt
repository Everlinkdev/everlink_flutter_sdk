package com.everlink.everlink_sdk

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.everlink.broadcast.Everlink
import com.everlink.broadcast.exceptions.EverlinkError
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

// Key constants used throughout the code for Flutter MethodChannel and EventChannel methods
private const val everlinkSdkKey = "everlink_sdk"
private const val everlinkSdkEventKey = "everlink_sdk_event"
private const val appIDKey = "appID"
private const val setupMethodKey = "setup"
private const val startDateKey = "start_date"
private const val tokensKey = "tokens"
private const val tokenKey = "token"
private const val volumeKey = "volume"
private const val loudSpeakerKey = "loudSpeaker"

// Method key constants to handle specific functionality in the plugin
private const val startDetectingMethodKey = "startDetecting"
private const val stopDetectingMethodKey = "stopDetecting"
private const val createNewTokenMethodKey = "createNewToken"
private const val saveTokenMethodKey = "saveTokens"
private const val clearTokensMethodKey = "clearTokens"
private const val startEmittingMethodKey = "startEmitting"
private const val startEmittingTokenMethodKey = "startEmittingToken"
private const val stopEmittingMethodKey = "stopEmitting"
private const val playVolumeMethodKey = "playVolume"

// Error constant for Everlink-related errors
private const val EVERLINK_ERROR = "Everlink Error"

// Permission code for requesting microphone permission
private const val myPermissionCode = 802

/** EverlinkSdkPlugin */
class EverlinkSdkPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  // Flutter MethodChannel and EventChannel for communication between Flutter and native Android
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel : EventChannel
  private var eventSink: EventChannel.EventSink? = null

  // Everlink SDK class instance
  lateinit var everlink: Everlink

  // Android activity and context references
  private lateinit var context : Context
  private lateinit var activity: FlutterActivity

  // Control flags and permission codes
  private var everlinkClassSet: Boolean = false
  private var permissionGranted: Boolean = false

  // Method to set up channels when the plugin is attached to the Flutter engine
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, everlinkSdkKey)
    channel.setMethodCallHandler(this) // Set method call handler
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, everlinkSdkEventKey)
    eventChannel.setStreamHandler(this) // Set event stream handler
    context = flutterPluginBinding.applicationContext // Set the Android context
  }

  // Called when the plugin is attached to an activity (Android lifecycle)
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.getActivity() as FlutterActivity // Reference to the activity
    binding.addRequestPermissionsResultListener(this) // Attach permission listener
  }

  override fun onDetachedFromActivity() {

  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  // Called when reattached to activity after configuration changes
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.getActivity() as FlutterActivity
    binding.addRequestPermissionsResultListener(this)
  }

  // Set up the Everlink class with the given appID and initialize listeners
  private fun setUpEverlinkClass(appID: String) {
    if(!everlinkClassSet) {
      everlinkClassSet = true;
      everlink = Everlink(context, activity, appID) // Initialize Everlink with context and appID
      everlink.playVolume(0.8, true)
      everlink.setAudioListener(object : Everlink.audioListener {
        override fun onAudiocodeReceived(token: String) {
          val jsonDataString = "{\"token\":\"${token}\"}"
          val jsonString = "{ \"msg_type\":\"detection\", \"data\":${jsonDataString} }"
          activity.runOnUiThread { // Send the event back to Flutter on the UI thread
            eventSink?.success(jsonString)
          }
        }

        // Callback when a new token is generated
        override fun onMyTokenGenerated(oldToken: String, newToken: String) {
          val jsonDataString = "{\"old_token\": \"${oldToken}\", \"new_token\": \"${newToken}\"}"
          val jsonString = "{ \"msg_type\":\"generated_token\", \"data\":${jsonDataString} }"
          activity.runOnUiThread { // Send the event back to Flutter on the UI thread
            eventSink?.success(jsonString)
          }
        }
      })
    }
  }

  // Handle different method calls from Flutter
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        setupMethodKey -> {
          val appID = call.argument<String>(appIDKey)
          if (appID != null) {
            setUpEverlinkClass(appID)
          }
        }

        startDetectingMethodKey -> {
          checkPermission() // Check and request permissions before starting detection
        }

        stopDetectingMethodKey -> {
          everlink.stopDetecting() // Stop detecting when the method is called
        }

        createNewTokenMethodKey -> {
          try {
            val startDate = call.argument<String>(startDateKey)
            everlink.createNewToken(startDate) // Create a new token
          } catch (err: EverlinkError) {
            result.error(err.code.toString(), err.message.toString(), EVERLINK_ERROR)
          }
        }

        saveTokenMethodKey -> {
          val tokens = call.argument<List<String>>(tokensKey)
          if (tokens != null) {
            everlink.saveSounds(tokens.toTypedArray()) // Save tokens
          }
        }

        clearTokensMethodKey -> {
          everlink.clearSounds() // Clear tokens
        }

        startEmittingMethodKey -> {
          try {
            everlink.startEmitting() // Start emitting sound
          } catch (err: EverlinkError) {
            result.error(err.code.toString(), err.message.toString(), EVERLINK_ERROR)
          }
        }

        startEmittingTokenMethodKey -> {
          try {
            val token = call.argument<String>(tokenKey)
            everlink.startEmittingToken(token)
          } catch (err: EverlinkError) {
            result.error(err.code.toString(), err.message.toString(), EVERLINK_ERROR)
          }
        }

        stopEmittingMethodKey -> {
          everlink.stopEmitting() // Stop emitting sound
        }

        playVolumeMethodKey -> {
          val volume = call.argument<Double>(volumeKey)
          val speaker = call.argument<Boolean>(loudSpeakerKey)
          if (volume != null && speaker != null) {
            everlink.playVolume(volume, speaker) // Play volume, loudspeaker
          }
        }

        else -> {
          result.notImplemented() // Handle unimplemented methods
      }
    }
  }

  // Called when the plugin is detached from the Flutter engine
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null) // Clear method call handler
  }

  // Event stream setup to listen for events from Flutter
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  // Cancel event stream
  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  // Helper function to start detecting audio codes
  private fun startDetecting() {
    try {
      everlink.startDetecting()
    } catch (err: EverlinkError) {
      // Handle error if detection fails
    }
  }

  // Check for microphone permissions before starting detection
  private fun checkPermission() {
    permissionGranted = ContextCompat.checkSelfPermission(context,
      android.Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
    if ( !permissionGranted ) {
      ActivityCompat.requestPermissions(activity,
        arrayOf(android.Manifest.permission.RECORD_AUDIO), myPermissionCode )
    }
    else {
      startDetecting() // If permission is granted, start detection
    }
  }

  // Handle the result of the permission request
  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray
  ): Boolean {
    when (requestCode) {
      myPermissionCode -> {
        permissionGranted = grantResults.isNotEmpty() &&
                grantResults.get(0) == PackageManager.PERMISSION_GRANTED
        startDetecting() // If permission is granted, start detecting
        return true
      }
    }
    return false
  }
}