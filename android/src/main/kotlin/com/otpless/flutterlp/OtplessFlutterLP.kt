package com.otpless.flutterlp

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.lifecycle.lifecycleScope
import com.otpless.loginpage.main.OtplessController
import com.otpless.loginpage.model.OtplessResult
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
  private lateinit var context: Context
  private lateinit var activity: FlutterFragmentActivity
  private lateinit var otplessController: OtplessController

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "otpless_flutter_lp")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        val appId = call.argument<String>("appId") ?: ""
        val secret = call.argument<String>("secret") ?: ""
        otplessController = OtplessController.getInstance(activity)
        otplessController.initializeOtpless(appId) {

        }
        result.success("")
      }

      "start" -> {
        start()
        result.success("")
      }

      "setResponseCallback" -> {
        otplessController.registerResultCallback(this::onAuthResponse)
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
    sendResponse(response)
  }

  private fun sendResponse(result: OtplessResult) {

    val json = when(result) {
      is OtplessResult.Success -> JSONObject().also {
        it.put("token", result.token)
        it.put("traceId", result.traceId)
      }
      is OtplessResult.Error -> JSONObject().also {
        it.put("traceId", result.traceId)
        it.put("errorCode",result.errorCode)
        it.put("errorType",result.errorType)
        it.put("errorMessage" ,result.errorMessage)
      }
    }

    channel.invokeMethod("otpless_callback_event", json.toString())
  }

  private fun start() {
    activity.lifecycleScope.launch(Dispatchers.IO) {
      otplessController.startOtplessWithLoginPage()
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
