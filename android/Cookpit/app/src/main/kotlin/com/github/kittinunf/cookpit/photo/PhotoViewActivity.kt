package com.github.kittinunf.cookpit.photo

import android.content.Intent
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.text.Html
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import com.github.kittinunf.cookpit.BaseActivity
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.util.addSpaceItemDecoration
import com.github.kittinunf.cookpit.util.setAvatarImage
import com.github.kittinunf.cookpit.util.setImageUrl
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindNext
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.scheduler.AndroidThreadScheduler
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_itemsWith
import com.github.kittinunf.reactiveandroid.widget.rx_text
import kotlinx.android.synthetic.main.activity_photo_view.*
import kotlinx.android.synthetic.main.recycler_item_comment.view.*
import rx.Observable
import rx.schedulers.Schedulers

class PhotoViewActivity : BaseActivity() {

    companion object {
        val PHOTO_ID_EXTRA = "photo_id_extra"
        val PHOTO_TITLE_EXTRA = "photo_title_extra"
    }

    override val resourceId: Int = R.layout.activity_photo_view

    lateinit var photoTitle: String

    private lateinit var detailController: PhotoDetailDataController
    private lateinit var commentController: PhotoCommentDataController

    override fun handleIntent(intent: Intent) {
        val photoId = intent.getStringExtra(PHOTO_ID_EXTRA)
        photoTitle = intent.getStringExtra(PHOTO_TITLE_EXTRA)

        detailController = PhotoDetailDataController(photoId)
        commentController = PhotoCommentDataController(photoId)
    }

    override fun setUp() {
        val loadDetailCommands = detailController.viewData.map { PhotoViewModelCommand.SetPhoto(it) }
        val loadCommentCommands = commentController.viewData.map { PhotoViewModelCommand.SetComments(it.comments) }

        val viewModels = Observable.merge(loadDetailCommands, loadCommentCommands)
                .scan(PhotoViewModel()) { viewModel, command -> viewModel.executeCommand(command) }
                .doOnSubscribe {
                    detailController.request()
                    commentController.request()
                }
                .subscribeOn(Schedulers.computation())
                .replay(1)
                .refCount()

        photoCommentRecyclerView.apply {
            layoutManager = LinearLayoutManager(this@PhotoViewActivity)
            addSpaceItemDecoration(resources.getDimensionPixelSize(R.dimen.explore_item_offset))
            rx_itemsWith(viewModels.map { it.comments }, { parent, Index ->
                val view = LayoutInflater.from(parent?.context).inflate(R.layout.recycler_item_comment, parent, false)
                CommentViewHolder(view)
            }, { viewHolder, index, item ->
                viewHolder.itemView.photoCommentAvatarImageView.setAvatarImage(item.ownerAvatarUrl)
                viewHolder.itemView.photoCommentNameTextView.text = item.ownerName
                viewHolder.itemView.photoCommentTextView.text = Html.fromHtml(item.text)
            }).addTo(subscriptions)
        }

        photoTitleTextView.text = photoTitle

        viewModels.filter { it.photo != null }
                .map { it.photo!!.imageUrl }
                .observeOn(AndroidThreadScheduler.main)
                .bindNext(photoImageView, ImageView::setImageUrl)
                .addTo(subscriptions)

        viewModels.filter { it.photo != null }
                .map { it.photo!!.ownerAvatarUrl }
                .observeOn(AndroidThreadScheduler.main)
                .bindNext(ownerAvatarImageView, ImageView::setAvatarImage)
                .addTo(subscriptions)

        viewModels.filter { it.photo != null }
                .map { it.photo!!.ownerName }
                .bindTo(ownerNameTextView.rx_text)
                .addTo(subscriptions)

        viewModels.filter { it.photo != null }
                .map { it.photo!!.numberOfView }
                .bindTo(viewCountTextView.rx_text)
                .addTo(subscriptions)

        viewModels.filter { it.photo != null }
                .map { it.photo!!.numberOfComment }
                .bindTo(commentCountTextView.rx_text)
                .addTo(subscriptions)
    }

    override fun onDestroy() {
        super.onDestroy()
        detailController.unsubscribe()
        commentController.unsubscribe()
    }

    class CommentViewHolder(view: View) : RecyclerView.ViewHolder(view)

}
