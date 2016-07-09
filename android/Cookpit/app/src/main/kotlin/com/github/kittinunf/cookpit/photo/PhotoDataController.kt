package com.github.kittinunf.cookpit.photo

import com.github.kittinunf.cookpit.*
import com.github.kittinunf.reactiveandroid.MutableProperty

class PhotoDetailDataController(id: String) : PhotoDetailControllerObserver() {

    private val controller: PhotoDetailController

    private val _viewData = MutableProperty<PhotoDetailViewData>()

    val viewData by lazy { _viewData.observable }

    private val _loadings = MutableProperty(false)

    val loadings by lazy { _loadings.observable }

    init {
        controller = PhotoDetailController.create(id)
        controller.subscribe(this)
    }

    fun unsubscribe() {
        controller.unsubscribe()
    }

    fun request() {
        controller.requestDetail()
    }

    //region PhotoDetailControllerObserver
    override fun onBeginUpdate() {
        _loadings.value = true
    }

    override fun onUpdate(viewData: PhotoDetailViewData?) {
        _viewData.value = viewData
    }

    override fun onEndUpdate() {
        _loadings.value = false
    }
    //endregion

}

class PhotoCommentDataController(id: String): PhotoCommentControllerObserver() {

    private val controller: PhotoCommentController

    private val _viewData = MutableProperty<PhotoCommentViewData>()

    val viewData by lazy { _viewData.observable }

    private val _loadings = MutableProperty(false)

    val loadings by lazy { _loadings.observable }

    init {
        controller = PhotoCommentController.create(id)
        controller.subscribe(this)
    }

    fun unsubscribe() {
        controller.unsubscribe()
    }

    fun request() {
        controller.requestComments()
    }

    //region PhotoCommentControllerObserver
    override fun onBeginUpdate() {
        _loadings.value = true
    }

    override fun onUpdate(viewData: PhotoCommentViewData?) {
        _viewData.value = viewData
    }

    override fun onEndUpdate() {
        _loadings.value = false
    }
    //endregion

}