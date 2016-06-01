package com.github.kittinunf.cookpit.util

import android.widget.ImageView
import com.bumptech.glide.Glide

fun ImageView.setImage(url: String, width: Int, height: Int) {
    Glide.with(context).load(url).override(width, height).fitCenter().crossFade().into(this)
}

 
