package com.wortise.ads.flutter_wortise

import android.app.Activity
import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.flutter_wortise.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.interstitial.InterstitialAd
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class InterstitialAd : ActivityAware, FlutterPlugin, MethodCallHandler {

    private var activity: Activity? = null

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private lateinit var channel : MethodChannel

    private lateinit var context: Context

    private val instances = mutableMapOf<String, InterstitialAd>()


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding

        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_INTERSTITIAL)
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

            "destroy"     -> destroy(call, result)

            "isAvailable" -> isAvailable(call, result)

            "isDestroyed" -> isDestroyed(call, result)

            "loadAd"      -> loadAd(call, result)

            "showAd"      -> showAd(call, result)

            else          -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }


    private fun createInstance(adUnitId: String): InterstitialAd {
        val activity = requireNotNull(activity)

        val adChannel = MethodChannel(binding.binaryMessenger, "${CHANNEL_INTERSTITIAL}_$adUnitId")

        return InterstitialAd(activity, adUnitId).also {

            it.listener = InterstitialAdListener(adChannel)

            instances[adUnitId] = it
        }
    }

    private fun destroy(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        instances.remove(adUnitId)?.destroy()

        result.success(null)
    }

    private fun isAvailable(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        result.success(instances[adUnitId]?.isAvailable == true)
    }

    private fun isDestroyed(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        result.success(instances[adUnitId]?.isDestroyed == true)
    }

    private fun loadAd(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val interstitialAd = instances[adUnitId] ?: createInstance(adUnitId)

        interstitialAd.loadAd()

        result.success(null)
    }

    private fun showAd(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val interstitialAd = instances[adUnitId]

        if (interstitialAd?.isAvailable != true) {
            result.success(false)
            return
        }

        interstitialAd.showAd()

        result.success(true)
    }


    private class InterstitialAdListener(private val channel: MethodChannel) : InterstitialAd.Listener {

        override fun onInterstitialClicked(ad: InterstitialAd) {
            channel.invokeMethod("clicked", null)
        }

        override fun onInterstitialDismissed(ad: InterstitialAd) {
            channel.invokeMethod("dismissed", null)
        }

        override fun onInterstitialFailed(ad: InterstitialAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failed", values)
        }

        override fun onInterstitialLoaded(ad: InterstitialAd) {
            channel.invokeMethod("loaded", null)
        }

        override fun onInterstitialShown(ad: InterstitialAd) {
            channel.invokeMethod("shown", null)
        }
    }


    companion object {
        const val CHANNEL_INTERSTITIAL = "${CHANNEL_MAIN}/interstitialAd"
    }
}