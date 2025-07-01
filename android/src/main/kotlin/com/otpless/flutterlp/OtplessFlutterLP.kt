package com.otpless.flutterlp

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.lifecycle.lifecycleScope
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
import com.otpless.loginpage.main.OtplessController
import com.otpless.loginpage.model.CctSupportConfig
import com.otpless.loginpage.model.CctSupportType
import com.otpless.loginpage.model.LoginPageParams
import com.otpless.loginpage.model.OtplessResult


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
        // create the instance of OtplessController if not create
        otplessController = OtplessController.getInstance(activity)
        initOtplessLoginPage(call, result)
      }

      "start" -> {
        val loginPageParams = parseLoginParams(call)
        start(loginPageParams)
        result.success("")
      }

      "setResponseCallback" -> {
        otplessController.registerResultCallback(this::onOtplessResult)
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

  private fun initOtplessLoginPage(call: MethodCall, result: Result) {
    val appId = call.argument<String>("appId") ?: ""
    val map = call.argument<Map<String, Any>>("config") ?: emptyMap()
    val origin: Uri? = (map["origin"] as? String)?.let { Uri.parse(it) }
    val type: String? = map["type"] as? String
    val cctType = when (type) {
      "cCt" -> CctSupportType.Cct
      else -> CctSupportType.Twa
    }
    val config = CctSupportConfig(cctType, origin)
    otplessController.initializeOtpless(appId, config) {
      result.success(it)
    }
  }

  private fun onOtplessResult(result: OtplessResult) {
    Log.d(Tag, "callback onAuthResponse with response $result")
    // convert the result object into result map object
    val map = when (result) {
      is OtplessResult.Success -> mapOf(
        "status" to "success",
        "traceId" to result.traceId,
        "token" to result.token
      )

      is OtplessResult.Error -> mapOf(
        "status" to "error",
        "traceId" to result.traceId,
        "errorCode" to result.errorCode,
        "errorMessage" to result.errorMessage,
        "errorType" to result.errorType.name
      )
    }
    channel.invokeMethod("otpless_callback_event", map)
  }

  private fun start(loginPageParams: LoginPageParams?) {
    activity.lifecycleScope.launch(Dispatchers.IO) {
      // if login page params are null then
      if (loginPageParams == null)
        otplessController.startOtplessWithLoginPage()
      else
        otplessController.startOtplessWithLoginPage(loginPageParams)
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
