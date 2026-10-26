package com.duniaanak.ceria.dunia_anak_ceria

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.duniaanak.ceria/kiosk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startKiosk" -> {
                    try {
                        startLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("KIOSK_ERROR", e.message, null)
                    }
                }
                "stopKiosk" -> {
                    try {
                        stopLockTask()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("KIOSK_ERROR", e.message, null)
                    }
                }
                "isKioskActive" -> {
                    val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val isInLockTaskMode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
                    } else {
                        activityManager.isInLockTaskMode
                    }
                    result.success(isInLockTaskMode)
                }
                "openHomeSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("SETTINGS_ERROR", e2.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
