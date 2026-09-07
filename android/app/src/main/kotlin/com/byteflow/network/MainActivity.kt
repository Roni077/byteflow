package com.byteflow.network

import com.byteflow.network.plugins.AppUsagePlugin
import com.byteflow.network.plugins.NetworkStatsPlugin
import com.byteflow.network.plugins.ShizukuPlugin
import com.byteflow.network.plugins.SimManagerPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(NetworkStatsPlugin())
        flutterEngine.plugins.add(AppUsagePlugin())
        flutterEngine.plugins.add(SimManagerPlugin())
        flutterEngine.plugins.add(ShizukuPlugin())
    }
}

