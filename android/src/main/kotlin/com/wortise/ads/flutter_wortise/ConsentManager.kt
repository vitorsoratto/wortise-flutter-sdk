package com.wortise.ads.flutter_wortise

import android.app.Activity
import android.content.Context
import com.wortise.ads.consent.ConsentActivity
import com.wortise.ads.consent.ConsentManager
import com.wortise.ads.flutter_wortise.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ConsentManager : ActivityAware, FlutterPlugin, MethodCallHandler {

    private var activity: Activity? = null

    private lateinit var channel : MethodChannel

    private lateinit var context: Context


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_CONSENT)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "canCollectData" -> result.success(ConsentManager.canCollectData(context))

            "isGranted"      -> result.success(ConsentManager.isGranted(context))

            "isReplied"      -> result.success(ConsentManager.isReplied(context))

            "request"        -> request(call, result)

            "requestOnce"    -> requestOnce(call, result)

            "set"            -> set(call, result)

            else             -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }


    private fun request(call: MethodCall, result: Result) {
        val activity = requireNotNull(activity)

        val withOptOut = call.argument<Boolean>("withOptOut") ?: false

        result.success(ConsentActivity.request(activity, withOptOut))
    }

    private fun requestOnce(call: MethodCall, result: Result) {
        val activity = requireNotNull(activity)

        val withOptOut = call.argument<Boolean>("withOptOut") ?: false

        result.success(ConsentActivity.requestOnce(activity, withOptOut))
    }

    private fun set(call: MethodCall, result: Result) {
        val granted = call.argument<Boolean>("granted")

        requireNotNull(granted)

        ConsentManager.set(context, granted)

        result.success(null)
    }


    companion object {
        const val CHANNEL_CONSENT = "${CHANNEL_MAIN}/consentManager"
    }
}