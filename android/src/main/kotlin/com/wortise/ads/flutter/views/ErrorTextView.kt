package com.wortise.ads.flutter.views

import android.content.Context
import android.graphics.Color
import android.widget.TextView
import io.flutter.plugin.platform.PlatformView

class ErrorTextView(context: Context, message: String) : PlatformView {

    private val textView by lazy {
        TextView(context).also {

            it.setBackgroundColor(Color.RED)
            it.setTextColor      (Color.YELLOW)

            it.text = message
        }
    }


    override fun dispose() {}

    override fun getView() = textView     
}