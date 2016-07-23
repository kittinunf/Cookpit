package com.github.kittinunf.cookpit.map

import com.github.kittinunf.cookpit.MapController
import com.github.kittinunf.cookpit.MapControllerObserver
import com.github.kittinunf.cookpit.MapViewData
import com.github.kittinunf.reactiveandroid.MutableProperty

class MapDataController : MapControllerObserver() {

    private val controller = MapController.create()

    private val _viewData = MutableProperty<MapViewData>()

    val viewData by lazy { _viewData.observable }

    companion object {
        fun mapToken() = MapController.mapToken()
    }

    init {
        controller.subscribe(this)
    }

    fun request() {
        controller.request()
    }

    fun unsubscribe() {
        controller.unsubscribe()
    }

    //region MapControllerObserver
    override fun onBeginUpdate() {
    }

    override fun onUpdate(viewData: MapViewData?) {
        _viewData.value = viewData
    }

    override fun onEndUpdate() {
    }
    //endregion
}