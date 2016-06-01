package com.github.kittinunf.cookpit.main

import android.graphics.PorterDuff
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentPagerAdapter
import android.support.v4.content.ContextCompat
import com.github.kittinunf.cookpit.BaseActivity
import com.github.kittinunf.cookpit.R
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : BaseActivity() {

    override val resourceId: Int = R.layout.activity_main

    lateinit var mainPagerAdapter: MainPagerAdapter

    private val viewModel = MainViewModel()

    override fun setUp() {
        configureViews()
    }

    private fun configureViews() {
        mainPagerAdapter = MainPagerAdapter(supportFragmentManager)
        mainViewPager.apply {
            adapter = mainPagerAdapter
            offscreenPageLimit = 2
        }

        mainTab.setupWithViewPager(mainViewPager)
        (0..(viewModel.itemCount() - 1)).forEach { index ->
            mainTab.getTabAt(index)?.let {
                it.setIcon(viewModel.iconForIndex(index))
                it.icon?.setColorFilter(ContextCompat.getColor(this@MainActivity, android.R.color.white), PorterDuff.Mode.SRC_IN)
            }
        }
    }

    inner class MainPagerAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm) {

        override fun getItem(position: Int): Fragment {
            return viewModel.fragmentForIndex(position)()
        }

        override fun getCount(): Int {
            return viewModel.itemCount()
        }

        override fun getPageTitle(position: Int): CharSequence? {
            return ""
        }

    }
}
