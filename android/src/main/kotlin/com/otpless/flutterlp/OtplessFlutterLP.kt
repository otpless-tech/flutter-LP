package com.otpless.flutterlp

import android.content.Intent
import android.util.Log
import androidx.lifecycle.lifecycleScope
import com.otpless.loginpage.main.OtplessController
import com.otpless.loginpage.main.OtplessEventData
import com.otpless.loginpage.model.LoginPageParams
import com.otpless.loginpage.model.OtplessResult
import com.otpless.loginpage.util.InstallUtils
import com.otpless.loginpage.util.Utility
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject


class OtplessFlutterLP: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener, NewIntentListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity: FlutterFragmentActivity
  private lateinit var otplessController: OtplessController

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "otpless_flutter_lp")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        val appId = call.argument<String>("appId") ?: ""
        otplessController = OtplessController.getInstance(activity)
        otplessController.initializeOtpless(appId) {
          result.success(it)
        }
      }

      "setEventListener" -> {
        otplessController.addEventObserver(this::onOtplessEvent)
        result.success("")
      }

      "isWhatsAppInstalled" -> {
        result.success(InstallUtils.isWhatsAppInstalled(activity))
      }

      "start" -> {
        val request = convertToLoginPageParams(
          (call.arguments as? Map<*, *>)?.let {
            it.filterKeys { key -> key is String }
            emptyMap()
          } ?: emptyMap()
        )
        start(request)
        result.success("")
      }

      "setResponseCallback" -> {
        otplessController.registerResultCallback(this::onAuthResponse)
        result.success("")
      }

      "setDebugLogging" -> {
        val enable = call.argument<Boolean>("enable") ?: false
        Log.d("OTPLESS_CONN", "===debug logging: $enable")
        Utility.isLoggingEnabled = enable
        result.success("")
      }

      "stop" -> {
        otplessController.closeOtpless()
        result.success("")
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun onAuthResponse(response: OtplessResult) {
    Log.d(Tag, "callback onAuthResponse with response $response")
    sendResponse(response.toJson())
  }

  private fun onOtplessEvent(eventData: OtplessEventData) {
    val json = JSONObject().also {
      it.put("eventType", eventData.eventType.name)
      it.put("category", eventData.category.name)
      it.put("metaData", eventData.metaData)
    }
    activity.runOnUiThread {
      channel.invokeMethod("otpless_event", json.toString())
    }
  }

  private fun sendResponse(response: JSONObject) {
    channel.invokeMethod("otpless_callback_event", response.toString())
  }

  private fun start(params: LoginPageParams) {
    activity.lifecycleScope.launch(Dispatchers.IO) {
      otplessController.startOtplessWithLoginPage(params)
    }
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity as FlutterFragmentActivity
    binding.addActivityResultListener(this)
    binding.addOnNewIntentListener(this)
  }

  override fun onNewIntent(intent: Intent): Boolean {
    if (!this::otplessController.isInitialized) return false
    otplessController.onNewIntent(activity, intent)
    return true
  }

  override fun onDetachedFromActivityForConfigChanges() {
    return
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    return
  }

  override fun onDetachedFromActivity() {
    return
  }

  companion object {
    private const val Tag = "OtplessFlutterLP"
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    return false
  }
}
