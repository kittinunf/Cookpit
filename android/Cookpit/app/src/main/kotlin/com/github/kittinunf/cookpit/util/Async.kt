package com.github.kittinunf.cookpit.util

import android.os.Handler
import android.os.Looper
import java.lang.ref.WeakReference
import java.util.concurrent.Executor
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future

internal class FuseAsync<T>(val weakRef: WeakReference<T>)

internal fun <T, X> FuseAsync<T>.thread(executor: Executor, f: (T) -> X) {
    val r = weakRef.get() ?: return
    executor.execute { f(r) }
}

internal fun <T, X> FuseAsync<T>.mainThread(f: (T) -> X) {
    val mainLooperHandler = Handler(Looper.getMainLooper())
    val mainThreadExecutor = Executor {
        mainLooperHandler.post(it)
    }
    thread(mainThreadExecutor, f)
}

internal fun <T> T.dispatchAsync(executorService: ExecutorService = executor, block: FuseAsync<T>.() -> Unit): Future<Unit> {
    val a = FuseAsync(WeakReference(this))
    return executorService.submit<Unit> { a.block() }
}

private val executor: ExecutorService = Executors.newScheduledThreadPool(2 * Runtime.getRuntime().availableProcessors())
 
