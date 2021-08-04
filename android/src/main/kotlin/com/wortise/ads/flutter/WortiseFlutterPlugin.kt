package com.wortise.ads.flutter

import android.content.Context
import com.wortise.ads.WortiseSdk
import com.wortise.ads.flutter.BannerAd.Companion.CHANNEL_BANNER
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class WortiseFlutterPlugin : ActivityAware, FlutterPlugin, MethodCallHandler {

    private val activityAwarePlugins: List<ActivityAware>
        get() = plugins.mapNotNull { it as? ActivityAware }

    private val plugins = listOf<FlutterPlugin>(
            ConsentManager(),
            DataManager   (),
            InterstitialAd()
    )


    private lateinit var channel : MethodChannel

    private lateinit var context: Context


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityAwarePlugins.forEach { it.onAttachedToActivity(binding) }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_MAIN)
        channel.setMethodCallHandler(this)

        plugins.forEach { it.onAttachedToEngine(binding) }

        binding.platformViewRegistry.registerViewFactory(CHANNEL_BANNER, BannerAd(binding.binaryMessenger))
    }

    override fun onDetachedFromActivity() {
        activityAwarePlugins.forEach { it.onDetachedFromActivity() }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityAwarePlugins.forEach { it.onDetachedFromActivityForConfigChanges() }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

        plugins.forEach { it.onDetachedFromEngine(binding) }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "getVersion"    -> result.success(WortiseSdk.version)

            "initialize"    -> initialize(call, result)

            "isInitialized" -> result.success(WortiseSdk.isInitialized)

            "isReady"       -> result.success(WortiseSdk.isReady)

            "start"         -> start(result)

            "stop"          -> stop(result)

            "wait"          -> wait(result)

            else            -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityAwarePlugins.forEach { it.onReattachedToActivityForConfigChanges(binding) }
    }


    private fun initialize(call: MethodCall, result: Result) {
        val assetKey = call.argument<String> ("assetKey")
        val start    = call.argument<Boolean>("start") ?: true

        require(!assetKey.isNullOrEmpty())

        WortiseSdk.initialize(context, assetKey, start)

        result.success(null)
    }

    private fun start(result: Result) {
        WortiseSdk.start(context)

        result.success(null)
    }

    private fun stop(result: Result) {
        WortiseSdk.stop(context)

        result.success(null)
    }

    private fun wait(result: Result) {
        WortiseSdk.wait { result.success(null) }
    }


    companion object {
        const val CHANNEL_MAIN = "wortise"
    }
}
