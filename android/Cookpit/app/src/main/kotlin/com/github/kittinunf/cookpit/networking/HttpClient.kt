package com.github.kittinunf.cookpit.networking

import com.github.kittinunf.cookpit.Http
import com.github.kittinunf.cookpit.HttpObserver
import com.github.kittinunf.fuel.Fuel
import com.github.kittinunf.fuel.core.FuelManager
import com.github.kittinunf.result.Result
import java.util.*

class HttpClient : Http() {

    init {
        FuelManager.instance.baseParams = listOf("format" to "json", "nojsoncallback" to 1)
    }

    override fun get(url: String, params: HashMap<String, String>?, observer: HttpObserver?) {
        Fuel.get(url, params?.toList()).responseString { request, response, result ->
            when (result) {
                is Result.Success -> observer?.onSuccess(result.value)
                is Result.Failure -> observer?.onFailure()
            }
        }
    }
}