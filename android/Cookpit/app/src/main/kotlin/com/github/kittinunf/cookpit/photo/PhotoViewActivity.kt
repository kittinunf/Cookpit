package com.github.kittinunf.cookpit.photo

import android.content.Intent
import android.support.v4.app.ActivityCompat
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.text.Html
import android.view.LayoutInflater
import android.view.View
import com.github.kittinunf.cookpit.BaseActivity
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.util.addSpaceItemDecoration
import com.github.kittinunf.cookpit.util.setAvatarImage
import com.github.kittinunf.cookpit.util.setImage
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.scheduler.AndroidThreadScheduler
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_itemsWith
import com.github.kittinunf.reactiveandroid.widget.rx_text
import kotlinx.android.synthetic.main.activity_photo_view.*
import kotlinx.android.synthetic.main.recycler_item_comment.view.*

class PhotoViewActivity : BaseActivity() {

    companion object {
        val PHOTO_ID_EXTRA = "photo_id_extra"
        val PHOTO_TITLE_EXTRA = "photo_title_extra"
    }

    override val resourceId: Int = R.layout.activity_photo_view

    lateinit var photoId: String
    lateinit var photoTitle: String
    lateinit var viewModel: PhotoViewModel

    override fun handleIntent(intent: Intent) {
        photoId = intent.getStringExtra(PHOTO_ID_EXTRA)
        photoTitle = intent.getStringExtra(PHOTO_TITLE_EXTRA)
    }

    override fun setUp() {
        ActivityCompat.postponeEnterTransition(this)

        viewModel = PhotoViewModel(photoId)

        photoCommentRecyclerView.layoutManager = LinearLayoutManager(this)
        photoCommentRecyclerView.addSpaceItemDecoration(resources.getDimensionPixelSize(R.dimen.explore_item_offset))
        photoCommentRecyclerView.rx_itemsWith(viewModel.comments, { viewGroup, Index ->
            val view = LayoutInflater.from(PhotoViewActivity@this).inflate(R.layout.recycler_item_comment, viewGroup, false)
            CommentViewHolder(view)
        }, { viewHolder, index, item ->
            viewHolder.avatarImageView.setAvatarImage(item.ownerAvatarUrl)
            viewHolder.nameTextView.text = item.ownerName
            viewHolder.contentTextView.text = Html.fromHtml(item.text)
        }).addTo(subscriptions)

        photoTitleTextView.text = photoTitle
        viewModel.imageUrls.observeOn(AndroidThreadScheduler.main).subscribe {
            photoImageView.setImage(it, onReady = {
                ActivityCompat.startPostponedEnterTransition(this@PhotoViewActivity)
                false
            })
        }.addTo(subscriptions)

        viewModel.ownerAvatarUrls.observeOn(AndroidThreadScheduler.main).subscribe {
            ownerAvatarImageView.setAvatarImage(it)
        }.addTo(subscriptions)

        viewModel.ownerNames.bindTo(ownerNameTextView.rx_text).addTo(subscriptions)

        viewModel.viewCounts.bindTo(viewCountTextView.rx_text).addTo(subscriptions)
        viewModel.commentCounts.bindTo(commentCountTextView.rx_text).addTo(subscriptions)
    }

    override fun onDestroy() {
        super.onDestroy()
        viewModel.unsubscribe()
    }

    class CommentViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val avatarImageView by lazy { view.photoCommentAvatarImageView }
        val nameTextView by lazy { view.photoCommentNameTextView }
        val contentTextView by lazy { view.photoCommentTextView }
    }

}
