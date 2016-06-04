package com.github.kittinunf.cookpit.main

import android.support.v4.app.Fragment
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.explore.ExploreFragment
import com.github.kittinunf.cookpit.search.SearchFragment

class MainViewModel {

    private val values = listOf(
            Triple(R.string.tab_explore, R.mipmap.ic_landscape_black_36dp, ::ExploreFragment),
            Triple(R.string.tab_search, R.mipmap.ic_search_black_36dp, ::SearchFragment)
    )

    val tabIndices = 0..(values.size - 1)

    fun titleForIndex(index: Int): Int {
        return values[index].first
    }

    fun iconForIndex(index: Int): Int {
        return values[index].second
    }

    fun fragmentForIndex(index: Int): Fragment {
        return values[index].third()
    }

    fun itemCount(): Int {
        return values.size
    }

}