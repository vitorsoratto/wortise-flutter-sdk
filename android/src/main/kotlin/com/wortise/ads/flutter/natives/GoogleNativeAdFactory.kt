package com.wortise.ads.flutter.natives

import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

interface GoogleNativeAdFactory {
    fun createNativeAd(nativeAd: NativeAd): NativeAdView
}