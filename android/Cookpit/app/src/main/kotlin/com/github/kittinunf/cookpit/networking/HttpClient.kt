package com.github.kittinunf.cookpit.networking

import com.github.kittinunf.cookpit.Http
import com.github.kittinunf.cookpit.HttpObserver
import com.github.kittinunf.fuel.Fuel
import com.github.kittinunf.result.Result

class HttpClient : Http() {

    override fun get(url: String, observer: HttpObserver?) {
        Fuel.get(url).responseString{ request, response, result ->
            when (result) {
                is Result.Success -> observer?.onSuccess(result.value)
                is Result.Failure -> observer?.onFailure()
            }
        }
    }

}