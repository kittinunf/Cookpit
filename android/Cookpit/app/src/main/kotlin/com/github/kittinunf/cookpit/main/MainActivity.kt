package com.github.kittinunf.cookpit.main

import android.graphics.PorterDuff
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentPagerAdapter
import android.support.v4.content.ContextCompat
import com.github.kittinunf.cookpit.BaseActivity
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.widget.rx_tabSelected
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : BaseActivity() {

    override val resourceId: Int = R.layout.activity_main

    val defaultTabIndex = 0

    private val viewModel = MainViewModel()

    override fun setUp() {
        mainViewPager.apply {
            adapter = MainPagerAdapter(viewModel, supportFragmentManager)
            offscreenPageLimit = 2
        }
        mainTab.setupWithViewPager(mainViewPager)

        viewModel.tabIndices.forEach { index ->
            mainTab.getTabAt(index)?.let {
                it.setIcon(viewModel.iconForIndex(index))
                it.icon?.setColorFilter(ContextCompat.getColor(this@MainActivity, if (it.position == defaultTabIndex) R.color.teal400 else android.R.color.white), PorterDuff.Mode.SRC_IN)
            }
        }

        mainTab.rx_tabSelected().map { it.position }.subscribe { selectedIndex ->
            //manually set
            mainViewPager.currentItem = selectedIndex
            mainTab.getTabAt(selectedIndex)?.icon?.setColorFilter(ContextCompat.getColor(this@MainActivity, R.color.teal400), PorterDuff.Mode.SRC_IN)
            viewModel.tabIndices.forEach {
                if (it != selectedIndex) {
                    mainTab.getTabAt(it)?.icon?.setColorFilter(ContextCompat.getColor(this@MainActivity, android.R.color.white), PorterDuff.Mode.SRC_IN)
                }
            }
        }.addTo(subscriptions)
    }

    class MainPagerAdapter(val viewModel: MainViewModel, fm: FragmentManager) : FragmentPagerAdapter(fm) {

        override fun getItem(position: Int): Fragment {
            return viewModel.fragmentForIndex(position)
        }

        override fun getCount(): Int {
            return viewModel.itemCount()
        }

        override fun getPageTitle(position: Int): CharSequence? = null

    }

}
