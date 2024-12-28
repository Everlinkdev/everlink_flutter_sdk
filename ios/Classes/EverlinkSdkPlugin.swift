// EverlinkSdkPlugin.swift

import Flutter
import UIKit
import AVFoundation
import EverlinkBroadcastSDK
import EverlinkBroadcastSDK.ObjCErrorHandle


@objc public class EverlinkSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    // Method and EventChannel keys
    private let everlinkSdkKey = "everlink_sdk"
    private let everlinkSdkEventKey = "everlink_sdk_event"
    private let appIDKey = "appID"
    private let setupMethodKey = "setup"
    private let startDateKey = "start_date"
    private let validityPeriodKey = "validity_period"
    private let tokensKey = "tokens"
    private let tokenKey = "token"
    private let volumeKey = "volume"
    private let loudSpeakerKey = "loudSpeaker"
    private let startDetectingMethodKey = "startDetecting"
    private let stopDetectingMethodKey = "stopDetecting"
    private let createNewTokenMethodKey = "createNewToken"
    private let saveTokenMethodKey = "saveTokens"
    private let clearTokensMethodKey = "clearTokens"
    private let startEmittingMethodKey = "startEmitting"
    private let startEmittingTokenMethodKey = "startEmittingToken"
    private let stopEmittingMethodKey = "stopEmitting"
    private let playVolumeMethodKey = "playVolume"
    private let everlinkError = "Everlink Error"

    // Method and EventChannel references
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    // Everlink SDK instance placeholder
    private var everlink: Everlink?

    private var isPermissionGranted: Bool = false

    // Plugin setup
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = EverlinkSdkPlugin()
        instance.methodChannel = FlutterMethodChannel(name: "everlink_sdk", binaryMessenger: registrar.messenger())
        instance.eventChannel = FlutterEventChannel(name: "everlink_sdk_event", binaryMessenger: registrar.messenger())
        
        if (instance.methodChannel != nil) {
            registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
        }
        if (instance.eventChannel != nil) {
            instance.eventChannel!.setStreamHandler(instance)
        }
    }
    
    // Handle method calls from Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case setupMethodKey:
            if let args = call.arguments as? [String: Any],
               let appID = args[appIDKey] as? String {
                setupEverlink(appID: appID)
                result(nil)
            } else {
                result(FlutterError(code: "-1", message: "AppID is required", details: nil))
            }
            
        case startDetectingMethodKey:
            checkPermission {
                self.startDetecting()
            }
            result(nil)
            
        case stopDetectingMethodKey:
            everlink?.stopDetecting()
            result(nil)
            
        case createNewTokenMethodKey:
            if let args = call.arguments as? [String: Any],
               let startDate = args[startDateKey] as? String {
                do {
                    if let validityPeriod = args[validityPeriodKey] as? Int {
                        try everlink?.createNewToken(startDate: startDate, validityPeriod: validityPeriod)
                    } else {
                        try everlink?.createNewToken(startDate: startDate)
                    }
                } catch let error as EverlinkError {
                    result(FlutterError(code: String(error.getErrorCode()), message: error.getErrorMessage(), details: nil))
                } catch let error {
                    result(FlutterError(code: "-1", message: error.localizedDescription, details: error))
                }
            }
            result(nil)
            
        case saveTokenMethodKey:
            if let args = call.arguments as? [String: Any],
               let tokens = args[tokensKey] as? [String] {
                everlink?.saveSounds(tokensArray: tokens)
                result(nil)
            }
            
        case clearTokensMethodKey:
            everlink?.clearSounds()
            result(nil)
            
        case startEmittingMethodKey:
            everlink?.startEmitting() { error in
               if let error = error {
                   result(FlutterError(code: String(error.getErrorCode()), message: error.getErrorMessage(), details: error.localizedDescription))
               }
           }
            result(nil)
            
        case startEmittingTokenMethodKey:
            if let args = call.arguments as? [String: Any],
               let token = args[tokenKey] as? String {
                everlink?.startEmittingToken(token: token) { error in
                   if let error = error {
                       result(FlutterError(code: String(error.getErrorCode()), message: error.getErrorMessage(), details: error.localizedDescription))
                   }
               }
            }
            result(nil)
            
        case stopEmittingMethodKey:
            everlink?.stopEmitting()
            result(nil)
            
        case playVolumeMethodKey:
            if let args = call.arguments as? [String: Any],
               let volume = args[volumeKey] as? Float,
               let speaker = args[loudSpeakerKey] as? Bool {
                everlink?.playVolume(volume: volume, loudspeaker: speaker)
                result(nil)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Setup Everlink SDK
    private func setupEverlink(appID: String) {
        everlink = Everlink(appID: appID)
        everlink?.playVolume(volume: 0.8, loudspeaker: true)
        //TODO: Delcare delegate here
        everlink?.delegate = self
    }

    // Send events to Flutter
    private func sendEvent(type: String, data: [String: Any]) {
        guard let eventSink = eventSink else { return }
        let event = ["msg_type": type, "data": data] as [String: Any]

       // Event is sent on the main thread
       DispatchQueue.main.async {
           eventSink(event)
       }
   }

    // StreamHandler methods
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    // Permission handling
    private func checkPermission(completion: @escaping () -> Void) {
        let audioStatus = AVAudioSession.sharedInstance().recordPermission
        switch audioStatus {
        case .granted:
            DispatchQueue.main.async {
            completion()
        }
        case .denied:
        DispatchQueue.main.async {
            self.eventSink?(FlutterError(code: "-1", message: "Microphone permission denied", details: nil))
        }
    case .undetermined:
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    completion()
                } else {
                    self.eventSink?(FlutterError(code: "-1", message: "Microphone permission denied", details: nil))
                }
            }
        }
    @unknown default:
        DispatchQueue.main.async {
            self.eventSink?(FlutterError(code: "-1", message: "Unknown permission status", details: nil))
        }
    }
}

// Start detecting audio codes
private func startDetecting() {
    do {
        try everlink?.startDetecting()
    } catch let error as EverlinkError {
        DispatchQueue.main.async {
            self.eventSink?(FlutterError(code: String(error.getErrorCode()), message: error.getErrorMessage(), details: nil))
        }
    } catch let error {
        DispatchQueue.main.async {
            self.eventSink?(FlutterError(code: "-1", message: "Unknown error", details: error))
        }
    }
}
    }

// Conform to EverlinkEventDelegate
extension EverlinkSdkPlugin: EverlinkBroadcastSDK.EverlinkEventDelegate {

      public func onAudiocodeReceived(token: String) {

        let jsonDataString = "{\"token\":\"\(token)\"}"
        let jsonString = "{ \"msg_type\":\"detection\", \"data\":\(jsonDataString)}"

        // Ensure the event is sent on the main thread
        DispatchQueue.main.async {
            self.eventSink?(jsonString)
        }
    }

    public func onMyTokenGenerated(token: String, oldToken: String) {
        let jsonDataString = "{\"old_token\": \"\(oldToken)\", \"new_token\": \"\(token)\"}"
        let jsonString = "{ \"msg_type\":\"generated_token\", \"data\":\(jsonDataString) }"

        // Ensure the event is sent on the main thread
        DispatchQueue.main.async {
            self.eventSink?(jsonString)
        }
    }
}
