package com.github.kittinunf.cookpit.util

import com.github.kittinunf.reactiveandroid.subscription.AndroidMainThreadSubscription
import com.mapbox.mapboxsdk.annotations.Marker
import com.mapbox.mapboxsdk.maps.MapView
import com.mapbox.mapboxsdk.maps.MapboxMap
import rx.Observable

fun MapView.rx_mapReady(): Observable<MapboxMap> {
    return Observable.create { subscriber ->
        getMapAsync {
            subscriber.onNext(it)
        }
    }
}

fun MapboxMap.rx_markerClick(consumed: Boolean): Observable<Marker> {
    return Observable.create { subscriber ->
        setOnMarkerClickListener {
            subscriber.onNext(it)
            consumed
        }

        subscriber.add(AndroidMainThreadSubscription {
            setOnMarkerClickListener(null)
        })
    }
}

fun MapboxMap.rx_infoWindowClick(consumed: Boolean): Observable<Marker> {
    return Observable.create { subscriber ->
        setOnInfoWindowClickListener {
            subscriber.onNext(it)
            consumed
        }

        subscriber.add(AndroidMainThreadSubscription {
            onInfoWindowClickListener = null
        })
    }
}

 
