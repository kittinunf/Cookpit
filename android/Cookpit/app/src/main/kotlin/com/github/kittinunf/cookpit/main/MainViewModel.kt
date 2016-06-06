package com.github.kittinunf.cookpit.main

import android.support.v4.app.Fragment
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.explore.ExploreFragment
import com.github.kittinunf.cookpit.search.SearchFragment

class MainViewModel {

    private val tabData = listOf(
            Triple(R.string.tab_explore, R.mipmap.ic_landscape_black_36dp, ::ExploreFragment),
            Triple(R.string.tab_search, R.mipmap.ic_search_black_36dp, ::SearchFragment)
    )

    val tabIndices = 0..(tabData.size - 1)

    fun fragmentForIndex(index: Int): Fragment {
        return tabData[index].third()
    }

    fun iconForIndex(index: Int): Int {
        return tabData[index].second
    }

    fun itemCount(): Int {
        return tabData.size
    }

}