package com.wortise.ads.flutter.banner

import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.AdSize
import com.wortise.ads.banner.BannerAd
import com.wortise.ads.flutter.banner.BannerAd.Companion.CHANNEL_BANNER
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class BannerAdView(context: Context, viewId: Int, args: Map<*, *>, messenger: BinaryMessenger) : BannerAd.Listener, PlatformView {

    private val adHeight = args["adHeight"] as? Int ?: -1

    private val adSize: AdSize
        get() = when {

            (adHeight >= 280) -> AdSize.HEIGHT_280

            (adHeight >= 250) -> AdSize.HEIGHT_250

            (adHeight >= 90)  -> AdSize.HEIGHT_90

            (adHeight >= 50)  -> AdSize.HEIGHT_50

            else -> AdSize.MATCH_VIEW
        }

    private val adUnitId = args["adUnitId"] as String

    private val autoRefreshTime = args["autoRefreshTime"] as? Int

    private val bannerAd: BannerAd

    private val channel = MethodChannel(messenger, "${CHANNEL_BANNER}_$viewId")


    init {
        bannerAd = BannerAd(context).also {
            it.adSize          = adSize
            it.adUnitId        = adUnitId
            it.listener        = this

            autoRefreshTime?.apply { it.autoRefreshTime = toLong() }

            it.loadAd()
        }
    }

    override fun dispose() {
        bannerAd.destroy()
    }

    override fun getView() = bannerAd


    override fun onBannerClicked(ad: BannerAd) {
        channel.invokeMethod("clicked", null)
    }

    override fun onBannerFailed(ad: BannerAd, error: AdError) {
        val values = mapOf("error" to error.name)

        channel.invokeMethod("failed", values)
    }

    override fun onBannerLoaded(ad: BannerAd) {
        val values = mapOf(
            "adHeight" to ad.adHeight,
            "adWidth"  to ad.adWidth
        )

        channel.invokeMethod("loaded", values)
    }
}