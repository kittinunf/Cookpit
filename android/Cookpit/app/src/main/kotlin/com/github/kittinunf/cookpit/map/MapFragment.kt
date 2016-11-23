package com.github.kittinunf.cookpit.map

import android.content.Intent
import android.os.Bundle
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import com.github.kittinunf.cookpit.BaseFragment
import com.github.kittinunf.cookpit.MapDetailViewData
import com.github.kittinunf.cookpit.R
import com.github.kittinunf.cookpit.photo.PhotoViewActivity
import com.github.kittinunf.cookpit.util.rx_infoWindowClick
import com.github.kittinunf.cookpit.util.rx_mapReady
import com.github.kittinunf.cookpit.util.rx_markerClick
import com.github.kittinunf.cookpit.util.setImage
import com.github.kittinunf.reactiveandroid.MutableProperty
import com.github.kittinunf.reactiveandroid.rx.addTo
import com.github.kittinunf.reactiveandroid.rx.bindNext
import com.github.kittinunf.reactiveandroid.rx.bindTo
import com.github.kittinunf.reactiveandroid.scheduler.AndroidThreadScheduler
import com.github.kittinunf.reactiveandroid.support.v7.widget.rx_itemsWith
import com.github.kittinunf.reactiveandroid.view.rx_click
import com.mapbox.mapboxsdk.MapboxAccountManager
import com.mapbox.mapboxsdk.camera.CameraPosition
import com.mapbox.mapboxsdk.maps.MapboxMap
import kotlinx.android.synthetic.main.fragment_map.*
import kotlinx.android.synthetic.main.recycler_item_map.view.*
import rx.schedulers.Schedulers

class MapFragment : BaseFragment() {

    override val resourceId: Int = R.layout.fragment_map

    lateinit var controller: MapDataController

    lateinit var layout: LinearLayoutManager

    private val selectedViewData = MutableProperty<MapDetailViewData>()
    private val mapboxMap = MutableProperty<MapboxMap>()

    override fun setUp() {
        controller = MapDataController()
        MapboxAccountManager.start(activity, MapDataController.mapToken())
    }

    override fun onViewCreated(view: View?, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        mapView.onCreate(savedInstanceState)
        mapView.rx_mapReady().bindTo(mapboxMap).addTo(subscriptions)
    }

    override fun setUp(view: View) {
        val loadCommands = controller.viewData.map { MapViewModelCommand.SetItems(it.items) }

        val viewModels = loadCommands.scan(MapViewModel(), MapViewModel::executeCommand)
                .doOnSubscribe {
                    controller.request()
                }
                .subscribeOn(Schedulers.computation())
                .replay(1)
                .autoConnect()

        viewModels.map { it.items.map { it.createMarkerOptions() } }
                .subscribe {
                    mapboxMap.value?.addMarkers(it)
                }.addTo(subscriptions)

        mapRecyclerView.apply {
            layout = LinearLayoutManager(activity, LinearLayoutManager.HORIZONTAL, false)
            layoutManager = layout
            rx_itemsWith(viewModels.map { it.items },
                    { parent, index ->
                        val itemView = LayoutInflater.from(parent?.context).inflate(R.layout.recycler_item_map, parent, false)
                        val viewHolder = MapViewHolder(itemView)
                        viewHolder.itemView.rx_click()
                                .map { viewHolder.layoutPosition }
                                .withLatestFrom(viewModels) { index, viewModel ->
                                    viewModel.items[index]
                                }.bindTo(selectedViewData)
                        viewHolder
                    },
                    { viewHolder, index, item ->
                        val size = resources.getDimensionPixelOffset(R.dimen.map_item_size)
                        viewHolder.itemView.mapPhotoImageView.setImage(item.imageUrl, size, size)
                    }).addTo(subscriptions)
        }

        mapboxMap.observable.subscribe { map ->
            map.rx_markerClick(false)
                    .withLatestFrom(viewModels) { marker, viewModel ->
                        val items = viewModel.items
                        items.indexOfFirst { it.location == marker.position } to marker.position
                    }
                    .observeOn(AndroidThreadScheduler.main)
                    .subscribe {
                        val (index, position) = it
                        layout.scrollToPositionWithOffset(index, 20)
                        map.animateCamera { CameraPosition.Builder().zoom(12.0).target(position).build() }
                    }.addTo(subscriptions)

            map.rx_infoWindowClick(false)
                    .withLatestFrom(viewModels) { marker, viewModel ->
                        viewModel.items.find { it.location == marker.position }
                    }
                    .observeOn(AndroidThreadScheduler.main)
                    .bindNext(this@MapFragment, MapFragment::navigateToPhotoViewActivity)
                    .addTo(subscriptions)
        }.addTo(subscriptions)

        selectedViewData.observable
                .subscribe { data ->
                    val map = mapboxMap.value ?: return@subscribe
                    map.animateCamera({ CameraPosition.Builder().zoom(12.0).target(data.location).build() },
                            object : MapboxMap.CancelableCallback {
                                override fun onCancel() {
                                }

                                override fun onFinish() {
                                    map.selectMarker(map.markers.filter { it.position == data.location }.first())
                                }
                            })
                }.addTo(subscriptions)
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
        controller.unsubscribe()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mapView.onSaveInstanceState(outState)
    }

    fun navigateToPhotoViewActivity(viewData: MapDetailViewData?) {
        val data = viewData ?: return
        val intent = Intent(activity, PhotoViewActivity::class.java).apply {
            putExtra(PhotoViewActivity.PHOTO_ID_EXTRA, data.id)
            putExtra(PhotoViewActivity.PHOTO_TITLE_EXTRA, data.text)
        }

        startActivity(intent)
    }

    class MapViewHolder(view: View) : RecyclerView.ViewHolder(view)

}