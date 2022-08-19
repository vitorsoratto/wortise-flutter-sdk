package com.wortise.ads.flutter.views

import android.view.View
import io.flutter.plugin.platform.PlatformView

class FlutterPlatformView(private var view: View?) : PlatformView {

    override fun dispose() {
        view = null
    }

    override fun getView() = view
}