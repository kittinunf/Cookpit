package com.github.kittinunf.cookpit.main

import android.graphics.PorterDuff
import android.support.annotation.ColorRes
import android.support.v4.content.ContextCompat
import com.github.kittinunf.cookpit.BaseActivity
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.reactiveandroid.rx.bindNext
import com.github.kittinunf.reactiveandroid.support.design.widget.rx_tabSelected
import com.github.kittinunf.reactiveandroid.support.design.widget.rx_tabUnselected
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_fragmentsWith
import kotlinx.android.synthetic.main.activity_main.*
import rx.Observable

class MainActivity : BaseActivity() {

    override val resourceId: Int = R.layout.activity_main

    private val viewModel = MainViewModel()

    override fun setUp() {
        mainViewPager.apply {
            offscreenPageLimit = 3
            rx_fragmentsWith(Observable.just(viewModel.tabData), supportFragmentManager, { position, item ->
                item.third()
            }, { position, item ->
                ""
            })
        }

        mainTab.apply {
            setupWithViewPager(mainViewPager)
            rx_tabSelected().map { it.position to R.color.teal400 }.doOnNext { mainViewPager.currentItem = it.first }.bindNext(this@MainActivity, MainActivity::setTabAtIndexWithColor)
            rx_tabUnselected().map { it.position to android.R.color.white }.bindNext(this@MainActivity, MainActivity::setTabAtIndexWithColor)
        }
    }

    fun setTabAtIndexWithColor(index: Int, @ColorRes colorRes: Int) {
        viewModel.tabData.forEachIndexed { index, data ->
            mainTab.getTabAt(index)?.let {
                it.setIcon(data.second)
                it.icon?.setColorFilter(ContextCompat.getColor(this@MainActivity, android.R.color.white), PorterDuff.Mode.SRC_IN)
            }
        }

        mainTab.getTabAt(index)?.let {
            it.icon?.setColorFilter(ContextCompat.getColor(this@MainActivity, colorRes), PorterDuff.Mode.SRC_IN)
        }
    }

}
