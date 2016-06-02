package com.github.kittinunf.cookpit

import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import rx.subscriptions.CompositeSubscription

abstract class BaseFragment : Fragment() {

    lateinit var subscriptions: CompositeSubscription

    abstract val resourceId: Int

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        subscriptions = CompositeSubscription()

        savedInstanceState?.let {
            handleSavedInstanceState(it)
        }

        arguments?.let {
            handleArguments(it)
        }

        setUp()
    }

    override fun onCreateView(inflater: LayoutInflater?, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater?.inflate(resourceId, container, false)
    }

    override fun onViewCreated(view: View?, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setUp(view!!)
    }

    override fun onDestroy() {
        subscriptions.unsubscribe()
        super.onDestroy()
    }

    open fun handleSavedInstanceState(savedInstanceState: Bundle) {
    }

    open fun handleArguments(args: Bundle) {

    }

    open fun setUp() {
    }

    open fun setUp(view: View) {

    }

}