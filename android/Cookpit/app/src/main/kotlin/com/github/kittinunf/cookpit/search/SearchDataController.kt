package com.github.kittinunf.cookpit.search

import com.github.kittinunf.cookpit.SearchController
import com.github.kittinunf.cookpit.SearchControllerObserver
import com.github.kittinunf.cookpit.SearchViewData
import com.github.kittinunf.reactiveandroid.MutableProperty

class SearchDataController : SearchControllerObserver() {

    private val controller = SearchController.create()

    private val _viewData = MutableProperty<SearchViewData>()

    val viewData by lazy { _viewData.observable }

    private val _recentItems = MutableProperty<List<String>>()

    val recentItems by lazy { _recentItems.observable }

    private val _loadings = MutableProperty(false)

    val loadings by lazy { _loadings.observable }

    var currentPage = 1

    init {
        controller.subscribe(this)
    }

    fun searchWith(key: String) {
        controller.reset()
        searchWithKey(key, 1)
    }

    private fun searchWithKey(key: String, page: Int) {
        currentPage = page
        controller.search(key, page.toByte())
    }

    fun searchNextPage(key: String) {
        searchWithKey(key, currentPage + 1)
    }

    fun fetchRecents() {
        _recentItems.value = controller.fetchRecents()
    }

    fun unsubscribe() {
        controller.unsubscribe()
    }

    override fun onBeginUpdate() {
        _loadings.value = true
    }

    override fun onUpdate(viewData: SearchViewData?) {
        _viewData.value = viewData
    }

    override fun onEndUpdate() {
        _loadings.value = false
    }

}
