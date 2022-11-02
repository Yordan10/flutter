package com.example.flutter_app

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import com.polidea.rxandroidble2.exceptions.BleException;
import io.reactivex.exceptions.UndeliverableException;
import io.reactivex.plugins.RxJavaPlugins;

class MainActivity: FlutterActivity() {
    fun configureRxJavaErrorHandler(){
        RxJavaPlugins.setErrorHandler { Throwable ->
            if (Throwable is UndeliverableException && Throwable.cause is BleException) {
              return@setErrorHandler // ignore BleExceptions since we do not have subscriber
            }
            else {
              throw Throwable
            }
          }
    }
   
}
