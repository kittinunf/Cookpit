package com.github.kittinunf.cookpit.util

import rx.Observable

fun <T> Observable<T?>.filterNotNull(): Observable<T> = filter { it != null }.map { it!! }

fun Observable<Boolean>.not(): Observable<Boolean> = map { !it }
 
