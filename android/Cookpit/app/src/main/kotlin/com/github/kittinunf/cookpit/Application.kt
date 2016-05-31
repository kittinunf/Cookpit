package com.github.kittinunf.cookpit

import android.util.Log
import com.github.kittinunf.fuel.Fuel

class Application : android.app.Application() {

    init {
        System.loadLibrary("cookpit_android")
        Log.i(javaClass.simpleName, System.getProperty("os.arch"))
    }

    override fun onCreate() {
        super.onCreate()

        Api.setPath(filesDir.absolutePath)

        Api.setHttp(object : Http() {
            override fun get(url: String, observer: HttpObserver?) {
                Fuel.get(url).responseString { request, response, result ->
                    result.fold({ observer?.onSuccess(it) }, { observer?.onFailure() })
                }
            }
        })
    }

}