package com.github.kittinunf.cookpit.util

import android.content.Context
import android.graphics.*
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation

fun ImageView.setImage(url: String) {
    Glide.with(context).load(url).fitCenter().crossFade().into(this)
}

fun ImageView.setImage(url: String, width: Int, height: Int) {
    Glide.with(context).load(url).override(width, height).fitCenter().crossFade().into(this)
}

fun ImageView.setAvatarImage(url: String) {
    Glide.with(context)
            .load(url)
            .fitCenter()
            .crossFade()
            .transform(CropCircleTransformation(context))
            .into(this)
}

private class CropCircleTransformation(context: Context) : BitmapTransformation(context) {

    override fun transform(pool: BitmapPool, source: Bitmap?, outWidth: Int, outHeight: Int): Bitmap? {
        if (source == null) return null

        val sourceSize = Math.min(source.width, source.height)
        val x = (source.width - sourceSize) / 2
        val y = (source.height - sourceSize) / 2

        val squared = Bitmap.createBitmap(source, x, y, sourceSize, sourceSize)
        var result = pool.get(sourceSize, sourceSize, Bitmap.Config.ARGB_8888)
        if (result == null) {
            result = Bitmap.createBitmap(sourceSize, sourceSize, Bitmap.Config.ARGB_8888)
        }

        val canvas = Canvas(result)
        val paint = Paint()
        paint.shader = BitmapShader(squared, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        paint.isAntiAlias = true
        val r = sourceSize / 2f
        canvas.drawCircle(r, r, r, paint)
        return Bitmap.createScaledBitmap(result, outWidth, outHeight, true)
    }

    override fun getId(): String? {
        return javaClass.simpleName
    }

}
