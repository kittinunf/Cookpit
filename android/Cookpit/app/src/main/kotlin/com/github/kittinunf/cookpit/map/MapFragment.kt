package com.github.kittinunf.cookpit.map

import android.os.Bundle
import android.view.View
import com.github.kittinunf.cookpit.BaseFragment
import com.github.kittinunf.cookpit.R
import com.mapbox.mapboxsdk.MapboxAccountManager
import com.mapbox.mapboxsdk.annotations.MarkerOptions
import com.mapbox.mapboxsdk.camera.CameraPosition
import com.mapbox.mapboxsdk.geometry.LatLng
import kotlinx.android.synthetic.main.fragment_map.*

class MapFragment : BaseFragment() {

    override val resourceId: Int = R.layout.fragment_map

    lateinit var controller: MapDataController

    override fun setUp() {
        controller = MapDataController()
        MapboxAccountManager.start(activity, MapDataController.mapToken())
    }

    override fun onViewCreated(view: View?, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        mapView.onCreate(savedInstanceState)
        val center = LatLng(40.7326808, -73.9843407)
        mapView.getMapAsync {
            it.cameraPosition = CameraPosition.Builder()
                    .target(center)
                    .zoom(10.0)
                    .build()
            it.addMarker(MarkerOptions().position(center).title("Hello"))
        }
    }

    override fun onResume() {
        super.onResume()
        mapView.onResume()
    }

    override fun onPause() {
        super.onPause()
        mapView.onPause()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        mapView.onLowMemory()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        mapView.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mapView.onSaveInstanceState(outState)
    }

}