package com.github.kittinunf.cookpit.view

import android.content.Context
import android.support.v4.view.ViewPager
import android.util.AttributeSet
import android.view.View
import com.mapbox.mapboxsdk.maps.MapView

class MapViewSupportViewPager @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : ViewPager(context, attrs) {

    override fun canScroll(v: View?, checkV: Boolean, dx: Int, x: Int, y: Int): Boolean {
        if (v is MapView) {
            return true
        }
        return super.canScroll(v, checkV, dx, x, y)
    }

}