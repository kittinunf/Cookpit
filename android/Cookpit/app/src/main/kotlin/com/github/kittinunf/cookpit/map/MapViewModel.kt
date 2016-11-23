package com.github.kittinunf.cookpit.map

import com.github.kittinunf.cookpit.MapDetailViewData
import com.mapbox.mapboxsdk.annotations.MarkerOptions

sealed class MapViewModelCommand {

    class SetItems(val items: List<MapDetailViewData>) : MapViewModelCommand()

}

class MapViewModel(val items: List<MapDetailViewData> = listOf()) {

    fun executeCommand(command: MapViewModelCommand): MapViewModel {
        when (command) {
            is MapViewModelCommand.SetItems -> {
                return MapViewModel(command.items)
            }
        }
    }

}

fun MapDetailViewData.createMarkerOptions(): MarkerOptions {
    return MarkerOptions().title(text).position(location)
}

 
