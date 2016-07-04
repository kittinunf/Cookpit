package com.github.kittinunf.cookpit

import android.util.Log

class Application : android.app.Application() {

    init {
        System.loadLibrary("cookpit_android")
        Log.i(javaClass.simpleName, System.getProperty("os.arch"))
    }

    override fun onCreate() {
        super.onCreate()

        val db = getDatabasePath("CookpitDB")
        db.mkdirs()
        Api.setPath(db.absolutePath)

        val token = "pk.eyJ1Ijoia2l0dGludW5mIiwiYSI6ImNpcTZyY2MwODAwaDBmcW02N3JweTk3M2wifQ.zM0-aialUeNtcCslIVG1ow"
        MapboxAccountManager.start(this, token)
    }

}
