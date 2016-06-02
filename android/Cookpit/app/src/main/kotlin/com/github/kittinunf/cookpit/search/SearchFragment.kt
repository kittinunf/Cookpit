package com.github.kittinunf.cookpit.search

import android.content.Intent
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import com.github.kittinunf.cookpit.BaseFragment
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.photo.PhotoViewActivity
import com.github.kittinunf.cookpit.util.not
import com.github.kittinunf.cookpit.util.setImage
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_itemsWith
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_queryTextChange
import com.github.kittinunf.reactiveandroid.view.rx_visibility
import kotlinx.android.synthetic.main.fragment_search.*
import kotlinx.android.synthetic.main.recycler_item_search.view.*
import java.util.concurrent.TimeUnit

class SearchFragment : BaseFragment() {

    override val resourceId: Int = R.layout.fragment_search

    private val viewModel = SearchViewModel()

    override fun setUp(view: View) {
        searchView.setIconifiedByDefault(false)

        searchResultRecyclerView.layoutManager = LinearLayoutManager(activity)
        recentSearchRecyclerView.layoutManager = LinearLayoutManager(activity)

        val searchTexts = searchView.rx_queryTextChange(true).share()

        searchTexts.filter { it.isEmpty() }.subscribe {
            viewModel.fetchRecents()
        }.addTo(subscriptions)

        searchTexts.map { it.isEmpty() }.map { if (it) View.VISIBLE else View.GONE }.bindTo(recentSearchRecyclerView.rx_visibility).addTo(subscriptions)
        searchTexts.map { it.isEmpty() }.not().map { if (it) View.VISIBLE else View.GONE }.bindTo(searchResultRecyclerView.rx_visibility).addTo(subscriptions)
        searchTexts.filter { !it.isEmpty() }
                .debounce(500, TimeUnit.MILLISECONDS)
                .distinctUntilChanged()
                .subscribe {
                    viewModel.searchForKey(it)
                }.addTo(subscriptions)

        recentSearchRecyclerView.rx_itemsWith(viewModel.recents, { viewGroup, index ->
            val itemView = LayoutInflater.from(viewGroup?.context).inflate(android.R.layout.simple_list_item_1, viewGroup, false)
            val viewHolder = RecentSearchViewHolder(itemView)
            viewHolder.onClick = {
                searchView.setQuery(viewModel.recentSearchFor(it), true)
            }
            viewHolder
        }, { viewHolder, index, item ->
            viewHolder.titleTextView.text = item
        })

        searchResultRecyclerView.rx_itemsWith(viewModel.results, { viewGroup, index ->
            val itemView = LayoutInflater.from(viewGroup?.context).inflate(R.layout.recycler_item_search, viewGroup, false)
            val viewHolder = SearchResultViewHolder(itemView)
            viewHolder.onClick = { selectedIndex ->
                viewModel[selectedIndex]?.let {
                    val intent = Intent(activity, PhotoViewActivity::class.java)
                    intent.putExtra(PhotoViewActivity.PHOTO_ID_EXTRA, it.id)
                    this@SearchFragment.startActivity(intent)
                }
            }
            viewHolder
        }, { viewHolder, index, item ->
            viewHolder.backgroundImageView.setImage(item.imageUrl)
        })
    }

    class RecentSearchViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val titleTextView by lazy { view.findViewById(android.R.id.text1) as TextView }

        var onClick: ((Int) -> Unit)? = null

        init {
           view.setOnClickListener { onClick?.invoke(layoutPosition) }
        }
    }

    class SearchResultViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val backgroundImageView by lazy { view.searchBackgroundImageView }

        var onClick: ((Int) -> Unit)? = null

        init {
           view.setOnClickListener { onClick?.invoke(layoutPosition) }
        }
    }
}