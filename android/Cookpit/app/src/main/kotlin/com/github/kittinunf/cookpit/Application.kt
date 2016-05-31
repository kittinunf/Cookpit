package com.github.kittinunf.cookpit

import android.util.Log
import com.github.kittinunf.cookpit.networking.HttpClient

class Application : android.app.Application() {

    init {
        System.loadLibrary("cookpit_android")
        Log.i(javaClass.simpleName, System.getProperty("os.arch"))
    }

    override fun onCreate() {
        super.onCreate()

        Api.setPath(filesDir.absolutePath)
        Api.setHttp(HttpClient())
    }

}