package com.github.kittinunf.cookpit.explore

import com.github.kittinunf.cookpit.ExploreController
import com.github.kittinunf.cookpit.ExploreControllerObserver
import com.github.kittinunf.cookpit.ExploreDetailViewData
import com.github.kittinunf.cookpit.ExploreViewData
import com.github.kittinunf.reactiveandroid.MutableProperty

class ExploreViewModel : ExploreControllerObserver() {

    private val controller = ExploreController.create()

    private val viewData = MutableProperty<ExploreViewData>()

    private val loading = MutableProperty(false)
    private val loadingMore = MutableProperty(false)

    var pageNumber = 0

    val items by lazy {
        viewData.observable.map { it.explores.toList() }
    }

    val loadings by lazy {
        loading.observable
    }

    val loadingMores by lazy {
        loadingMore.observable
    }

    init {
        controller.subscribe(this)
        requestForPage(1)
    }

    fun reset() {
        controller.reset()
    }

    fun requestForPage(page: Int) {
        pageNumber = page
        controller.request(page.toByte())
    }

    fun requestForNextPage() {
        requestForPage(pageNumber + 1)
    }

    operator fun get(index: Int): ExploreDetailViewData? {
        return viewData.value!!.explores[index]
    }

    fun unsubscribe() {
        controller.unsubscribe()
    }

    //region ExploreControllerObserver
    override fun onBeginUpdate() {
        if (pageNumber != 1) {
            loadingMore.value = true
        } else {
            loading.value = true
        }
    }

    override fun onUpdate(data: ExploreViewData?) {
        viewData.value = data
    }

    override fun onEndUpdate() {
        loading.value = false
        loadingMore.value = false
    }
    //endregion

}