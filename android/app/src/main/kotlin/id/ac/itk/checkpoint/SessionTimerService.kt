package id.ac.itk.checkpoint

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ContentValues
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.Executors

class SessionTimerService : Service() {
    private val worker = Executors.newSingleThreadExecutor()

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            val sessionId = intent.getStringExtra("id") ?: return START_NOT_STICKY
            val startedAt = intent.getLongExtra("startedAt", 0)
            worker.execute { finishSession(sessionId, startedAt, startId) }
            return START_NOT_STICKY
        }
        val sessionId = intent?.getStringExtra("id") ?: run { stopSelf(); return START_NOT_STICKY }
        val name = intent.getStringExtra("name") ?: "Game"
        val startedAt = intent.getLongExtra("startedAt", System.currentTimeMillis())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(CHANNEL, "Timer sesi game", NotificationManager.IMPORTANCE_LOW)
            )
        }
        val stopIntent = Intent(this, SessionTimerService::class.java).apply {
            action = ACTION_STOP
            putExtra("id", sessionId)
            putExtra("startedAt", startedAt)
        }
        val stop = PendingIntent.getService(this, 1, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val openIntent = packageManager.getLaunchIntentForPackage(packageName)
        val open = PendingIntent.getActivity(this, 0, openIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) Notification.Builder(this, CHANNEL) else Notification.Builder(this)
        val elapsed = (System.currentTimeMillis() - startedAt).coerceAtLeast(0)
        val notification = builder.setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle(name).setContentText("Sesi permainan berjalan")
            .setOngoing(true).setOnlyAlertOnce(true).setContentIntent(open)
            .setWhen(System.currentTimeMillis() - elapsed).setUsesChronometer(true)
            .addAction(android.R.drawable.ic_media_pause, "Stop", stop).build()
        startForeground(NOTIFICATION_ID, notification)
        return START_NOT_STICKY
    }

    private fun finishSession(id: String, startedAt: Long, startId: Int) {
        try {
            val now = System.currentTimeMillis()
            val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply { timeZone = TimeZone.getTimeZone("UTC") }
            SQLiteDatabase.openDatabase(getDatabasePath("checkpoint.db").path, null, SQLiteDatabase.OPEN_READWRITE).use { db ->
                val values = ContentValues().apply {
                    put("ended_at", format.format(Date(now)))
                    put("duration_sec", ((now - startedAt).coerceAtLeast(0) / 1000))
                    put("status", "completed")
                }
                db.update("play_sessions", values, "id = ? AND ended_at IS NULL", arrayOf(id))
            }
            sendBroadcast(Intent(ACTION_CHANGED).setPackage(packageName))
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelfResult(startId)
        } catch (error: Exception) {
            val manager = getSystemService(NotificationManager::class.java)
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) Notification.Builder(this, CHANNEL) else Notification.Builder(this)
            val retryIntent = Intent(this, SessionTimerService::class.java).apply { action = ACTION_STOP; putExtra("id", id); putExtra("startedAt", startedAt) }
            val retry = PendingIntent.getService(this, 1, retryIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            manager.notify(NOTIFICATION_ID, builder.setSmallIcon(android.R.drawable.ic_dialog_alert)
                .setContentTitle("Gagal menyimpan sesi").setContentText("Buka aplikasi atau coba lagi")
                .setOngoing(true).addAction(android.R.drawable.ic_media_pause, "Coba lagi", retry).build())
        }
    }

    override fun onDestroy() { worker.shutdown(); super.onDestroy() }
    companion object {
        const val ACTION_STOP = "id.ac.itk.checkpoint.STOP_SESSION"
        const val ACTION_CHANGED = "id.ac.itk.checkpoint.SESSION_CHANGED"
        private const val CHANNEL = "game_session_timer"
        private const val NOTIFICATION_ID = 101
    }
}
