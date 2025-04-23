import Flutter
import UIKit
import OtplessSwiftLP

public class SwiftOtplessFlutterLP: NSObject, FlutterPlugin, ConnectResponseDelegate {
    
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
            OtplessSwiftLP.shared.start(vc: viewController)
            result("")
        case "initialize":
            guard let _ = UIApplication.shared.delegate?.window??.rootViewController else {
                result("")
                return
            }
            if let args = call.arguments as? [String: Any],
               let appId = args["appId"] as? String,
               let secret = args["secret"] as? String {
                OtplessSwiftLP.shared.initialize(appId: appId, secret: secret)
            }
            result("")
        case "setResponseCallback":
            OtplessSwiftLP.shared.setResponseDelegate(self)
            result("")
        case "stop":
            OtplessSwiftLP.shared.cease()
            result("")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func onConnectResponse(_ response: [String: Any]) {
        sendResponse(dict: response)
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
