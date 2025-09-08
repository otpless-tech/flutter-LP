import Flutter
import UIKit
import OtplessSwiftLP

public class SwiftOtplessFlutterLP: NSObject, FlutterPlugin, ConnectResponseDelegate {
    public func onConnectResponse(_ response: OtplessResult) {
        if response.status == "success" {
            sendResponse(dict: OtplessResult.successMap(from: response)!)
        } else {
            sendResponse(dict: OtplessResult.errorMap(from: response)!)
        }
       
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "otpless_flutter_lp", binaryMessenger: registrar.messenger())
        let instance = SwiftOtplessFlutterLP()
        registrar.addMethodCallDelegate(instance, channel: channel)
        ChannelManager.shared.setMethodChannel(channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            guard let viewController = UIApplication.shared.delegate?.window??.rootViewController else {
                result("")
                return
            }
            let args = call.arguments as? [String: Any]
            let extraParams: [String: String]? = args?["extraQueryParams"] as? [String: String]
            if let loadingUrl = args?["loadingUrl"] as? String {
                OtplessSwiftLP.shared.start(baseUrl: loadingUrl, vc: viewController,extras: extraParams ?? [:])
            } else {
                OtplessSwiftLP.shared.start( vc: viewController, extras: extraParams ?? [:])
            }
            result("")
        case "initialize":
            guard let _ = UIApplication.shared.delegate?.window??.rootViewController else {
                result("")
                return
            }
            if let args = call.arguments as? [String: Any],
               let appId = args["appId"] as? String {
                OtplessSwiftLP.shared.initialize(appId: appId, merchantLoginUri: nil) { traceId in
                    result(traceId)
                }
            }
            
            result("")
        case "setResponseCallback":
            OtplessSwiftLP.shared.setResponseDelegate(self)
            result("")
        case "stop":
            OtplessSwiftLP.shared.cease()
            result("")
        case "isWhatsAppInstalled": result(false)
        case "setEventListener" :
            OtplessSwiftLP.shared.setEventDelegate(self)
            result("")
        case "setDebugLogging":
            OtplessSwiftLP.shared.enableSocketLogging()
            result("")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    static func filterParamsCondition(_ call: FlutterMethodCall, on onHaving: ([String: Any]) -> Void, off onNotHaving: () -> Void) {
        if let args = call.arguments as? [String: Any],
           let jsonString = args["arg"] as? String,
           let params = convertToDictionary(text: jsonString) {
            onHaving(params)
        } else {
            onNotHaving()
        }
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("JSON parse error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    private func sendResponse(dict: [String: Any]) {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        
        guard let jsonData else {
            print("Failed to parse JSON data")
            return
        }
        ChannelManager.shared.invokeMethod(method: "otpless_callback_event", arguments: String(data: jsonData, encoding: .utf8))
    }
}

// MARK: - Channel Manager

class ChannelManager {
    static let shared = ChannelManager()
    private var methodChannel: FlutterMethodChannel?
    
    private init() {}
    
    func setMethodChannel(_ channel: FlutterMethodChannel) {
        methodChannel = channel
    }
    
    func invokeMethod(method: String, arguments: Any?) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
}

/// implementation of OnEventDelegate
/// response is passed to otpless_event in dart
extension SwiftOtplessFlutterLP: OnEventDelegate {
    
    public func onEvent(_ event: OtplessEventData) {
        let eventMap: [String: Any] = [
            "category": event.category.name.uppercased(),
            "eventType": event.eventType.name.uppercased(),
            "metaData": event.metaData
        ]
        // byte steam of serialzied
        guard let bytesData = try? JSONSerialization.data(withJSONObject: eventMap),
              let jsonString = String(data: bytesData, encoding: .utf8) else { return }
        ChannelManager.shared.invokeMethod(method: "otpless_event", arguments: jsonString)

    }
}

