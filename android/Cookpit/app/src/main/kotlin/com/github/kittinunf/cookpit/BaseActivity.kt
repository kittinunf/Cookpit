package com.github.kittinunf.cookpit

import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import rx.subscriptions.CompositeSubscription

abstract class BaseActivity : AppCompatActivity() {

    lateinit var subscriptions: CompositeSubscription

    abstract val resourceId: Int

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(resourceId)

        subscriptions = CompositeSubscription()

        savedInstanceState?.let {
            handleSavedInstanceState(it)
        }

        intent?.let {
            handleIntent(it)
        }

        setUp()
    }

    open fun handleSavedInstanceState(savedInstanceState: Bundle) {
    }

    open fun handleIntent(intent: Intent) {
    }

    open fun setUp() {
    }

    override fun onDestroy() {
        subscriptions.unsubscribe()
        super.onDestroy()
    }

}