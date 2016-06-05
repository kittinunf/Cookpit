package com.github.kittinunf.cookpit.photo

import android.content.Intent
import com.github.kittinunf.cookpit.BaseActivity
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.util.setAvatarImage
import com.github.kittinunf.cookpit.util.setImage
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.scheduler.AndroidThreadScheduler
import com.github.kittinunf.reactiveandroid.widget.rx_text
import kotlinx.android.synthetic.main.activity_photo_view.*

class PhotoViewActivity : BaseActivity() {

    companion object {
        val PHOTO_ID_EXTRA = "photo_id_extra"
    }

    override val resourceId: Int = R.layout.activity_photo_view

    lateinit var photoId: String
    lateinit var viewModel: PhotoViewModel

    override fun handleIntent(intent: Intent) {
        photoId = intent.getStringExtra(PHOTO_ID_EXTRA)
    }

    override fun setUp() {
        viewModel = PhotoViewModel(photoId)

        viewModel.imageUrls.observeOn(AndroidThreadScheduler.mainThreadScheduler).subscribe {
            photoImageView.setImage(it)
        }.addTo(subscriptions)

        viewModel.ownerAvatarUrls.observeOn(AndroidThreadScheduler.mainThreadScheduler).subscribe {
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

}
