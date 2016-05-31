package com.github.kittinunf.cookpit

import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_sample.*

class SampleActivity : AppCompatActivity() {

    val controller = SampleController.create()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_sample)

        controller.subscribe(object : SampleControllerObserver() {
            override fun onUpdate(viewData: SampleViewData?) {
                viewData?.let {
                    tvTitle.text = viewData.title
                }
            }
        })
    }
}