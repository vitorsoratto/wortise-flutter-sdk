package com.wortise.ads.flutter

import android.content.Context
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BannerAd(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return BannerAdView(context, viewId, args as Map<*, *>, messenger)
    }


    companion object {
        const val CHANNEL_BANNER = "${CHANNEL_MAIN}/bannerAd"
    }
}