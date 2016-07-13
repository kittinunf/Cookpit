package com.github.kittinunf.cookpit.search

import android.content.Intent
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.support.v7.widget.SearchView
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.github.kittinunf.cookpit.BaseFragment
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.SearchDetailViewData
import com.github.kittinunf.cookpit.photo.PhotoViewActivity
import com.github.kittinunf.cookpit.util.not
import com.github.kittinunf.cookpit.util.setImage
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindNext
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_itemsWith
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_queryTextChange
import com.github.kittinunf.reactiveandroid.view.rx_click
import com.github.kittinunf.reactiveandroid.view.rx_visibility
import kotlinx.android.synthetic.main.fragment_search.*
import kotlinx.android.synthetic.main.recycler_item_search.view.*
import rx.Observable
import rx.schedulers.Schedulers
import java.util.concurrent.TimeUnit

class SearchFragment : BaseFragment() {

    override val resourceId: Int = R.layout.fragment_search

    private val controller = SearchDataController()

    override fun setUp(view: View) {
        searchView.setIconifiedByDefault(false)

        val searchTexts = searchView.rx_queryTextChange(true).share()

        searchTexts.filter { it.isEmpty() }.subscribe { controller.fetchRecents() }.addTo(subscriptions)

        searchTexts.map { it.isEmpty() }.map { if (it) View.VISIBLE else View.GONE }.bindTo(recentSearchRecyclerView.rx_visibility).addTo(subscriptions)
        searchTexts.map { it.isEmpty() }.not().map { if (it) View.VISIBLE else View.GONE }.bindTo(searchResultRecyclerView.rx_visibility).addTo(subscriptions)
        searchTexts.filter { !it.isEmpty() }
                .debounce(600, TimeUnit.MILLISECONDS)
                .distinctUntilChanged()
                .observeOn(Schedulers.computation())
                .bindNext(controller, SearchDataController::searchWith)
                .addTo(subscriptions)

        val loadSearchResultsCommand = controller.viewData.map { SearchViewModelCommand.SetSearchItems(it.results) }
        val loadRecentItemsCommand = controller.recentItems.map { SearchViewModelCommand.SetRecentItems(it) }
        val resetSearchItemsCommand = searchTexts.filter { it.isNotEmpty() }.map { SearchViewModelCommand.SetSearchItems(emptyList()) }

        val viewModels = Observable.merge(loadSearchResultsCommand, loadRecentItemsCommand, resetSearchItemsCommand)
                                    .scan(SearchViewModel()) { viewModel, command -> viewModel.executeCommand(command) }
                                    .replay(1)
                                    .refCount()

        recentSearchRecyclerView.apply {
            layoutManager = LinearLayoutManager(activity)
            rx_itemsWith(viewModels.map { it.recentItems }, { viewGroup, index ->
                val itemView = LayoutInflater.from(viewGroup?.context).inflate(android.R.layout.simple_list_item_1, viewGroup, false)
                val viewHolder = RecentSearchViewHolder(itemView)
                viewHolder.itemView.rx_click()
                                .map { viewHolder.layoutPosition }
                                .withLatestFrom(viewModels) { index, viewModel -> viewModel.recentItems[index] to true }
                                .bindNext(searchView, SearchView::setQuery)
                viewHolder
            }, { viewHolder, index, item ->
                viewHolder.titleTextView.text = item
            }).addTo(subscriptions)
        }

        searchResultRecyclerView.apply {
            layoutManager = LinearLayoutManager(activity)
            rx_itemsWith(viewModels.map { it.searchResults }, { viewGroup, index ->
                val itemView = LayoutInflater.from(viewGroup?.context).inflate(R.layout.recycler_item_search, viewGroup, false)
                val viewHolder = SearchResultViewHolder(itemView)
                viewHolder.itemView.rx_click()
                        .map { viewHolder.layoutPosition }
                        .withLatestFrom(viewModels) { index, viewModel -> viewModel.searchResults[index] }
                                .bindNext(this@SearchFragment, SearchFragment::navigateToPhotoViewActivity)
                                .addTo(subscriptions)
                viewHolder
            }, { viewHolder, index, item ->
                viewHolder.itemView.searchBackgroundImageView.setImage(item.imageUrl)
            }).addTo(subscriptions)
        }

    }

    fun navigateToPhotoViewActivity(viewData: SearchDetailViewData) {
        val intent = Intent(activity, PhotoViewActivity::class.java).apply {
            putExtra(PhotoViewActivity.PHOTO_ID_EXTRA, viewData.id)
            putExtra(PhotoViewActivity.PHOTO_TITLE_EXTRA, viewData.title)
        }

        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        controller.unsubscribe()
    }

    class RecentSearchViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val titleTextView by lazy { view.findViewById(android.R.id.text1) as TextView }

        var onClick: ((Int) -> Unit)? = null

        init {
           view.setOnClickListener { onClick?.invoke(layoutPosition) }
        }
    }

    class SearchResultViewHolder(view: View) : RecyclerView.ViewHolder(view)

}