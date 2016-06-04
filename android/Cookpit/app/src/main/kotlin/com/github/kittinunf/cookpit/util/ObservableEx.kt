package com.github.kittinunf.cookpit.util

import rx.Observable

fun Observable<Boolean>.not(): Observable<Boolean> = map { !it }
 
