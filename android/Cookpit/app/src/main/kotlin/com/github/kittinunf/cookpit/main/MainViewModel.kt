package com.github.kittinunf.cookpit.main

import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.explore.ExploreFragment
import com.github.kittinunf.cookpit.search.SearchFragment

class MainViewModel {

    val tabData = listOf(
            Triple(R.string.tab_explore, R.mipmap.ic_landscape_black_36dp, ::ExploreFragment),
            Triple(R.string.tab_search, R.mipmap.ic_search_black_36dp, ::SearchFragment)
    )

}