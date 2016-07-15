package com.github.kittinunf.cookpit.map

import com.github.kittinunf.cookpit.MapController
import com.github.kittinunf.cookpit.MapControllerObserver
import com.github.kittinunf.cookpit.MapViewData

class MapDataController : MapControllerObserver() {

    private val controller: MapController

    companion object {
        fun mapToken() = MapController.mapToken()
    }

    init {
        controller = MapController.create()
    }

    //region MapControllerObserver
    override fun onBeginUpdate() {
    }

    override fun onUpdate(viewDate: MapViewData?) {
    }

    override fun onEndUpdate() {
    }
    //endregion
}