package com.github.kittinunf.cookpit.photo

import com.github.kittinunf.cookpit.*
import com.github.kittinunf.reactiveandroid.MutableProperty


class PhotoViewModel(val id: String) {

    private val detailController: PhotoDetailController
    private val commentController: PhotoCommentController

    private val detailViewData = MutableProperty<PhotoDetailViewData>()
    private val commentViewData = MutableProperty<PhotoCommentViewData>()

    val imageUrls by lazy {
        detailViewData.observable.map { it.imageUrl }
    }

    val ownerNames by lazy {
        detailViewData.observable.map { it.ownerName }
    }

    val ownerAvatarUrls by lazy {
        detailViewData.observable.map { it.ownerAvatarUrl }
    }

    val viewCounts by lazy {
        detailViewData.observable.map { it.numberOfView }
    }

    val commentCounts by lazy {
        detailViewData.observable.map { it.numberOfComment }
    }

    val comments by lazy {
        commentViewData.observable.map { it.comments }
    }

    init {
        detailController = PhotoDetailController.create(id).apply {
            subscribe(object : PhotoDetailControllerObserver() {
                override fun onBeginUpdate() {
                }

                override fun onUpdate(data: PhotoDetailViewData?) {
                    detailViewData.value = data
                }

                override fun onEndUpdate() {
                }
            })
            requestDetail()
        }

        commentController = PhotoCommentController.create(id).apply {
            subscribe(object : PhotoCommentControllerObserver() {
                override fun onBeginUpdate() {
                }

                override fun onUpdate(data: PhotoCommentViewData?) {
                    commentViewData.value = data
                }

                override fun onEndUpdate() {
                }

            })
            requestComments()
        }
    }

    fun unsubscribe() {
        detailController.unsubscribe()
        commentController.unsubscribe()
    }

}