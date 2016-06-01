package com.github.kittinunf.cookpit.main

import android.support.v4.app.Fragment
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.explore.ExploreFragment

class MainViewModel {

    private val titleAndIcon = listOf(R.string.tab_explore to R.mipmap.ic_landscape_black_36dp, R.string.tab_explore to R.mipmap.ic_landscape_black_36dp)

    fun titleForIndex(index: Int): Int {
        return titleAndIcon[index].first
    }

    fun iconForIndex(index: Int): Int {
        return titleAndIcon[index].second
    }

    fun fragmentForIndex(index: Int): () -> Fragment {
        return {
            ExploreFragment()
        }
    }

    fun itemCount(): Int {
        return titleAndIcon.size
    }

}