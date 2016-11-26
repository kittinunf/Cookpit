package com.github.kittinunf.cookpit.explore

import com.github.kittinunf.cookpit.ExploreController
import com.github.kittinunf.cookpit.ExploreControllerObserver
import com.github.kittinunf.cookpit.ExploreDetailViewData
import com.github.kittinunf.cookpit.ExploreViewData
import com.github.kittinunf.reactiveandroid.MutableProperty

class ExploreDataController : ExploreControllerObserver() {

    private val controller = ExploreController.create()

    private val _viewData = MutableProperty<ExploreViewData>()

    val viewData by lazy { _viewData.observable }

    private val _loadings = MutableProperty(false)

    val loadings by lazy { _loadings.observable }

    private val _loadingMores = MutableProperty(false)

    val loadingMores by lazy { _loadingMores.observable }

    val errors by lazy {
        _viewData.observable.filter { it.error }
                .distinctUntilChanged()
                .map { it.message }
    }

    var currentPage = 1

    init {
        controller.subscribe(this)
    }

    fun reset() {
        currentPage = 1
        controller.reset()
    }

    fun request(page: Int) {
        currentPage = page
        controller.request(page.toByte())
    }

    fun requestDb(page: Int): List<ExploreDetailViewData> = controller.requestDb(page.toByte())

    fun requestNextPage() {
        request(currentPage + 1)
    }

    fun unsubscribe() {
        controller.unsubscribe()
    }

    //region ExploreControllerObserver
    override fun onBeginUpdate() {
        if (currentPage == 1) {
            _loadings.value = true
        } else {
            _loadingMores.value = true
        }
    }

    override fun onUpdate(viewData: ExploreViewData?) {
        _viewData.value = viewData
    }

    override fun onEndUpdate() {
        _loadings.value = false
        _loadingMores.value = false
    }
    //endregion

}