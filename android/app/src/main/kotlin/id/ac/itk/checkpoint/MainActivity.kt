package id.ac.itk.checkpoint

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel
    private var pendingStart: Pair<Intent, MethodChannel.Result>? = null
    private val changes = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) { channel.invokeMethod("sessionChanged", null) }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "checkpoint/session_timer")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val id = call.argument<String>("id")
                    val name = call.argument<String>("name")
                    val startedAt = call.argument<Number>("startedAt")?.toLong()
                    if (id == null || name == null || startedAt == null) { result.error("INVALID", "Data sesi tidak lengkap", null); return@setMethodCallHandler }
                    val intent = Intent(this, SessionTimerService::class.java).putExtra("id", id).putExtra("name", name).putExtra("startedAt", startedAt)
                    if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                        if (pendingStart != null) { result.error("BUSY", "Permintaan izin sedang diproses", null); return@setMethodCallHandler }
                        pendingStart = Pair(intent, result)
                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 6201)
                    } else startTimer(intent, result, true)
                }
                "stop" -> { stopService(Intent(this, SessionTimerService::class.java)); result.success(null) }
                else -> result.notImplemented()
            }
        }
        val filter = IntentFilter(SessionTimerService.ACTION_CHANGED)
        if (Build.VERSION.SDK_INT >= 33) registerReceiver(changes, filter, Context.RECEIVER_NOT_EXPORTED) else registerReceiver(changes, filter)
    }

    private fun startTimer(intent: Intent, result: MethodChannel.Result, allowed: Boolean) {
        try {
            if (Build.VERSION.SDK_INT >= 26) startForegroundService(intent) else startService(intent)
            result.success(allowed)
        } catch (error: Exception) { result.error("START_FAILED", error.message, null) }
    }

    @Deprecated("Deprecated in Android")
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 6201) {
            val pending = pendingStart ?: return
            pendingStart = null
            startTimer(pending.first, pending.second, grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
        }
    }

    override fun onDestroy() { unregisterReceiver(changes); super.onDestroy() }
}
