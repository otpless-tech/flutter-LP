package com.otpless.flutterlp

import com.otpless.loginpage.model.CustomTabParam
import com.otpless.loginpage.model.LoginPageParams
import io.flutter.plugin.common.MethodCall

internal fun parseLoginParams(call: MethodCall): LoginPageParams? {
    val params = call.argument<Map<String, Any>>("loginPageParams") ?: return null
    val waitTime = (params["waitTime"] as? Int)?.toLong() ?: 2_000
    val loadingUrl: String? = params["loadingUrl"] as? String
    val extraQueryParams: Map<String, String> = params["extraQueryParams"]?.let {
        if (it is Map<*, *>) {
            val map = mutableMapOf<String, String>()
            for ((key, value) in it) {
                if (key !is String) continue
                if (value !is String) continue
                map[key] = value
            }
            map
        } else emptyMap()
    } ?: emptyMap()
    val customTabParam: CustomTabParam = params["customTabParam"]?.let {
        if (it is Map<*, *>) {
            CustomTabParam(
                toolbarColor = it["toolbarColor"] as? String ?: "",
                secondaryToolbarColor = it["secondaryToolbarColor"] as? String ?: "",
                navigationBarColor = it["navigationBarColor"] as? String ?: "",
                navigationBarDividerColor = it["navigationBarDividerColor"] as? String ?: "",
                backgroundColor = it["backgroundColor"] as? String ?: ""
            )
        } else CustomTabParam()
    } ?: CustomTabParam()
    return LoginPageParams(waitTime = waitTime, loadingUrl = loadingUrl, extraQueryParams = extraQueryParams, customTabParam = customTabParam)
}