package com.example.everlink_sdk


import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
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

/** MypluginPlugin */
class MypluginPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel : EventChannel
  private var eventSink: EventChannel.EventSink? = null
  lateinit var everlink: Everlink
  private lateinit var context : Context
  private lateinit var activity: FlutterActivity
  private var everlinkClassSet: Boolean = false

  //todo add everlink class, set app id, set listeners, ask for permissions, hook up functions
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "myplugin")
    channel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "myplugin_event")
    eventChannel.setStreamHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.getActivity() as FlutterActivity
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.getActivity() as FlutterActivity
  }

  private fun setUpEverlinkClass(appID: String) {
    if(!everlinkClassSet) {
      everlinkClassSet = true;
      everlink = Everlink(context, activity, appID)
      everlink.setAudioListener(object : Everlink.audioListener {
        override fun onAudiocodeReceived(token: String) {
          val jsonDataString = "{\"token\":${token}}"
          val jsonString = "{msg_type:detection, data:\":${jsonDataString}}"
          eventSink?.success(jsonString)
        }

        override fun onMyTokenGenerated(oldToken: String, newToken: String) {
          val jsonDataString = "{\"oldToken\":${oldToken}, \"newToken\":${newToken}}"
          val jsonString = "{msg_type:detection, data:\":${jsonDataString}}"
          eventSink?.success(jsonString)
        }
      })
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "setup") {
      val appID = call.argument<String>("appID")
      if(appID != null) {
        setUpEverlinkClass(appID)
      }
    } else if (call.method == "startDetecting") {

        everlink.startDetecting() //request permissions here


    } else if (call.method == "stopDetecting") {

        everlink.stopDetecting()

    } else if (call.method == "createNewToken") {
      try {
        val startDate = call.argument<String>("start_date")
        everlink.createNewToken(startDate)
      } catch (err: EverlinkError) {
        result.error(err.code.toString(), err.message.toString(), "Everlink error")
      }

    } else if (call.method == "saveTokens") {

        val tokens = call.argument<List<String>>("tokens")
        if(tokens != null) {
          everlink.saveSounds(tokens.toTypedArray())
        }

    } else if (call.method == "clearTokens") {


        everlink.clearSounds()


    } else if (call.method == "startEmitting") {

      try {
        everlink.startEmitting()
      } catch (err: EverlinkError) {
        result.error(err.code.toString(), err.message.toString(), "Everlink error")
      }

    } else if (call.method == "startEmittingToken") {

      try {
        val token = call.argument<String>("token")
        everlink.startEmittingToken(token)
      } catch (err: EverlinkError) {
        result.error(err.code.toString(), err.message.toString(), "Everlink error")
      }

    } else if (call.method == "stopEmitting") {

        everlink.stopEmitting()


    } else if (call.method == "playVolume") {


        val volume = call.argument<Double>("volume")
        val speaker = call.argument<Boolean>("loudSpeaker")
        if (volume != null && speaker != null) {
          everlink.playVolume(volume, speaker)
        }


    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }


  private fun startDetecting() {
    try {
      everlink.startDetecting()
    } catch (err: EverlinkError) {

    }
  }


}