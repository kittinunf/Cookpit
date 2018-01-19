package com.github.kittinunf.cookpit.util

import android.graphics.Rect
import android.support.v7.widget.RecyclerView
import android.support.v7.widget.StaggeredGridLayoutManager
import android.view.View
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_scrolled
import rx.Observable

fun RecyclerView.rx_staggeredLoadMore(): Observable<Boolean> {
    return rx_scrolled().map {
        if (it.dy > 0) {
            val itemCount = childCount
            val totalItemCount = layoutManager.itemCount
            val firstVisibleItem = (layoutManager as StaggeredGridLayoutManager).findFirstVisibleItemPositions(null).first()

            (totalItemCount - itemCount) <= firstVisibleItem
        } else {
            false
        }
    }
}

fun RecyclerView.addSpaceItemDecoration(space: Int) {
    addItemDecoration(SpaceItemDecoration(space))
}

private class SpaceItemDecoration(val space: Int) : RecyclerView.ItemDecoration() {
    override fun getItemOffsets(outRect: Rect?, view: View?, parent: RecyclerView?, state: RecyclerView.State?) {
        outRect?.let {
            it.left = space
            it.right = space
            it.bottom = space
            it.top = space
        }
    }
}

