package com.github.kittinunf.cookpit.util

import android.support.v7.widget.RecyclerView
import android.support.v7.widget.StaggeredGridLayoutManager
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_scrolled
import rx.Observable

fun RecyclerView.rx_staggeredLoadMore(): Observable<Boolean> {
    return rx_scrolled().map {
        val itemCount = childCount
        val totalItemCount = layoutManager.itemCount
        val firstVisibleItem = (layoutManager as StaggeredGridLayoutManager).findFirstVisibleItemPositions(null).first()

        if (totalItemCount - itemCount < firstVisibleItem) true else false
    }
}
 
