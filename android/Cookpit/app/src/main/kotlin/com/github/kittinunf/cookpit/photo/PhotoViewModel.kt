package com.github.kittinunf.cookpit.photo

import com.github.kittinunf.cookpit.PhotoDetailController
import com.github.kittinunf.cookpit.PhotoDetailControllerObserver
import com.github.kittinunf.cookpit.PhotoDetailViewData
import com.github.kittinunf.cookpit.util.filterNotNull
import com.github.kittinunf.reactiveandroid.MutableProperty


class PhotoViewModel(val id: String) : PhotoDetailControllerObserver() {

    private val controller: PhotoDetailController

    private val viewData = MutableProperty<PhotoDetailViewData?>(null)

    val imageUrls by lazy {
        viewData.observable.filterNotNull().map { it.imageUrl }
    }

    val ownerNames by lazy {
        viewData.observable.filterNotNull().map { it.ownerName }
    }

    val ownerAvatarUrls by lazy {
        viewData.observable.filterNotNull().map { it.ownerAvatarUrl }
    }

    val viewCounts by lazy {
        viewData.observable.filterNotNull().map { it.numberOfView }
    }

    val commentCounts by lazy {
        viewData.observable.filterNotNull().map { it.numberOfComment }
    }

    init {
        controller = PhotoDetailController.create(id)

        controller.subscribe(this)
        controller.requestDetail()
    }

    fun requestDetail() {
        controller.requestDetail()
    }

    override fun onBeginUpdate() {
    }

    override fun onUpdate(data: PhotoDetailViewData?) {
        viewData.value = data
    }

    override fun onEndUpdate() {
    }

}