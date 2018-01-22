package com.github.kittinunf.cookpit

import android.util.Log

class Application : android.app.Application() {

    init {
        Log.i(javaClass.simpleName, System.getProperty("os.arch"))
        System.loadLibrary("cookpit_android")
    }

    override fun onCreate() {
        super.onCreate()

        val db = getDatabasePath("CookpitDB")
        db.mkdirs()
        Api.setPath(db.absolutePath)

        //set proxy if needed
//        Api.setProxy("192.168.11.7:8080")
    }

}

