package com.otpless.flutterlp

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.lifecycleScope
import com.otpless.loginpage.main.ConnectController
import com.otpless.loginpage.model.AuthResponse
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
import kotlinx.coroutines.CoroutineScope
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
  private lateinit var connectController: ConnectController

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
        connectController = ConnectController.getInstance(activity, appId, secret)
        connectController.initializeOtpless()
        result.success("")
      }

      "start" -> {
        start()
        result.success("")
      }

      "setResponseCallback" -> {
        connectController.registerResponseCallback(this::onAuthResponse)
        result.success("")
      }

      "stop" -> {
        connectController.closeOtpless()
        result.success("")
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun onAuthResponse(response: AuthResponse) {
    Log.d(Tag, "callback onAuthResponse with response $response")
    sendResponse(response.response)
  }

  private fun sendResponse(response: JSONObject) {
    channel.invokeMethod("otpless_callback_event", response.toString())
  }

  private fun start() {
    activity.lifecycleScope.launch(Dispatchers.IO) {
      connectController.startOtplessWithLoginPage()
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
    if (!this::connectController.isInitialized) return false
    connectController.onNewIntent(activity, intent)
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
