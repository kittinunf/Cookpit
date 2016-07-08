package com.github.kittinunf.cookpit.explore

import android.content.Context
import android.graphics.Point
import android.support.v7.widget.RecyclerView
import android.support.v7.widget.StaggeredGridLayoutManager
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import com.github.kittinunf.cookpit.BaseFragment
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.util.addSpaceItemDecoration
import com.github.kittinunf.cookpit.util.not
import com.github.kittinunf.cookpit.util.rx_staggeredLoadMore
import com.github.kittinunf.cookpit.util.setImage
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindNext
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.support.v4.widget.rx_refresh
import com.github.kittinunf.reactiveandroid.support.v4.widget.rx_refreshing
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_itemsWith
import com.github.kittinunf.reactiveandroid.view.rx_enabled
import com.github.kittinunf.reactiveandroid.view.rx_visibility
import kotlinx.android.synthetic.main.fragment_explore.*
import kotlinx.android.synthetic.main.recycler_item_explore.view.*
import rx.Observable
import android.support.v4.util.Pair as AndroidPair

class ExploreFragment : BaseFragment() {

    override val resourceId: Int = R.layout.fragment_explore

    private val screenSize: Point by lazy {
        val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = wm.defaultDisplay
        val size = Point()
        display.getSize(size)
        size
    }

    private val controller = ExploreDataController()

    override fun setUp(view: View) {
        val loadCommands = controller.viewData.map { ExploreViewModelCommand.SetItems(it.explores) }

        val viewModels = loadCommands.scan(ExploreViewModel(listOf())) { viewModel, command ->
            viewModel.executeCommand(command)
        }.share()

        controller.request(1)

        exploreRecyclerView.apply {
            layoutManager = StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL)
            addSpaceItemDecoration(resources.getDimensionPixelOffset(R.dimen.explore_item_offset))
            rx_itemsWith(viewModels.map { it.items },
                    { parent, index ->
                        val itemView = LayoutInflater.from(parent?.context).inflate(R.layout.recycler_item_explore, parent, false)
                        val viewHolder = ExploreViewHolder(itemView)
//                    viewHolder.onClick = { viewHolder, selectedIndex ->
//                        viewModel[selectedIndex]?.let {
//                            val intent = Intent(activity, PhotoViewActivity::class.java)
//                            intent.putExtra(PhotoViewActivity.PHOTO_ID_EXTRA, it.id)
//                            intent.putExtra(PhotoViewActivity.PHOTO_TITLE_EXTRA, it.title)
//                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//                                val image = AndroidPair(viewHolder.backgroundImageView as View, viewHolder.backgroundImageView.transitionName)
//                                val title = AndroidPair(viewHolder.titleTextView as View, viewHolder.titleTextView.transitionName)
//                                val options = ActivityOptionsCompat.makeSceneTransitionAnimation(activity, image, title)
//                                this@ExploreFragment.startActivity(intent, options.toBundle())
//                            } else {
//                                this@ExploreFragment.startActivity(intent)
//                            }
//                        }
//                    }
                        viewHolder
                    },
                    { viewHolder, index, item  ->
                        viewHolder.itemView.exploreCardView.preventCornerOverlap = false
                        viewHolder.itemView.exploreBackgroundImageView.setImage(item.imageUrl, screenSize.x / 2, 600)
                        viewHolder.itemView.exploreTitleTextView.text = item.title
                    })
        }

        exploreSwipeRefreshLayout.rx_refresh().subscribe {
            controller.reset()
            controller.request(1)
        }.addTo(subscriptions)

        exploreRecyclerView.rx_staggeredLoadMore()
                .withLatestFrom(Observable.merge(controller.loadings, controller.loadingMores)) { loadMore, loading -> loading }
                .filter { !it }
                .bindNext(controller, ExploreDataController::requestNextPage)
                .addTo(subscriptions)

        controller.loadings.bindTo(exploreSwipeRefreshLayout.rx_refreshing).addTo(subscriptions)
        controller.loadingMores.not().bindTo(exploreSwipeRefreshLayout.rx_enabled).addTo(subscriptions)
        controller.loadingMores.map { if (it) View.VISIBLE else View.GONE }.bindTo(exploreProgressLoadMore.rx_visibility).addTo(subscriptions)
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    class ExploreViewHolder(view: View) : RecyclerView.ViewHolder(view) {

        var onClick: ((ExploreViewHolder, Int) -> Unit)? = null

        init {
            view.setOnClickListener { onClick?.invoke(this, layoutPosition) }
        }

    }

}
