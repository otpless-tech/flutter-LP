package com.otpless.flutterlp

import com.otpless.loginpage.model.CustomTabParam
import com.otpless.loginpage.model.LoginPageParams
import com.otpless.loginpage.model.OtplessResult
import org.json.JSONObject


// Helpers
private fun stringStringMap(any: Any?): Map<String, String> =
    (any as? Map<*, *>)?.mapNotNull { (k, v) ->
        val key = k as? String
        val value = v as? String
        if (key != null && value != null) key to value else null
    }?.toMap().orEmpty()

private fun parseCustomTabParam(any: Any?): CustomTabParam? {
    val m = any as? Map<*, *> ?: return null
    val toolbarColor = m["toolbarColor"] as? String ?: ""
    val secondaryToolbarColor = m["secondaryToolbarColor"] as? String ?: ""
    val navigationBarColor = m["navigationBarColor"] as? String ?: ""
    val navigationBarDividerColor = m["navigationBarDividerColor"] as? String ?: ""
    val backgroundColor = m["backgroundColor"] as? String ?: ""


    return CustomTabParam(
        toolbarColor = toolbarColor,
        secondaryToolbarColor = secondaryToolbarColor,
        navigationBarColor = navigationBarColor,
        navigationBarDividerColor = navigationBarDividerColor,
        backgroundColor = backgroundColor
    )
}

// Main converter
internal fun convertToLoginPageParams(input: Map<String, Any?>): LoginPageParams {
    val waitTime = (input["waitTime"] as? Number)?.toLong() ?: 2000L
    val extraQueryParams = stringStringMap(input["extraQueryParams"])
    val customTabParam = parseCustomTabParam(input["customTabParam"])
    val loadingUrl = input["loadingUrl"] as? String

    return LoginPageParams(
        waitTime = waitTime,
        extraQueryParams = extraQueryParams,
        customTabParam = customTabParam ?: CustomTabParam(),
        loadingUrl = loadingUrl
    )
}


fun OtplessResult.toJson(): JSONObject {
    return when (this) {
        is OtplessResult.Success -> JSONObject().apply {
            put("type", "success")
            put("token", token)
            put("traceId", traceId)
            put("jwtToken", jwtToken)
        }

        is OtplessResult.Error -> JSONObject().apply {
            put("type", "error")
            put("errorType", errorType.name) // assuming ErrorType is an enum
            put("errorCode", errorCode)
            put("errorMessage", errorMessage)
            put("traceId", traceId)
        }
    }
}