package com.github.kittinunf.cookpit.search

import com.github.kittinunf.cookpit.SearchController
import com.github.kittinunf.cookpit.SearchControllerObserver
import com.github.kittinunf.cookpit.SearchDetailViewData
import com.github.kittinunf.cookpit.SearchViewData
import com.github.kittinunf.cookpit.util.filterNotNull
import com.github.kittinunf.reactiveandroid.MutableProperty

class SearchViewModel : SearchControllerObserver() {

    private val controller = SearchController.create()

    private val recentSearch = MutableProperty(listOf<String>())
    private val viewData = MutableProperty<SearchViewData?>(null)

    private val loading = MutableProperty(false)

    val recents by lazy {
        recentSearch.observable
    }

    val results by lazy {
        viewData.observable.filterNotNull().map { it.results.toList() }
    }

    val loadings by lazy {
        loading.observable
    }

    init {
        controller.subscribe(this)
    }

    fun searchForKey(key: String) {
        controller.reset()
        searchForKey(key, 1)
    }

    fun fetchRecents() {
        recentSearch.value = controller.fetchRecents()
    }

    fun recentSearchFor(index: Int): String = controller.fetchRecents()[index]

    fun searchForKey(key: String, page: Int) {
        controller.search(key, page.toByte())
    }

    operator fun get(index: Int): SearchDetailViewData? {
        return viewData.value!!.results[index]
    }

    override fun onBeginUpdate() {
        loading.value = true
    }

    override fun onUpdate(data: SearchViewData?) {
        viewData.value = data
    }

    override fun onEndUpdate() {
        loading.value = false
    }

}