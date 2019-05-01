package com.sd.euterpe

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.*
import android.os.*
import org.greenrobot.eventbus.EventBus
import java.util.*

class PlayerService : Service() {
    private val binder = LocalBinder()

    private var startId: Int? = null
    private var notificationManager: NotificationManager? = null
    private var builder: Notification.Builder? = null

    var player: MediaPlayer? = null

    private var elapsedTimeHandler: Handler? = null
    private var elapsedTimeRunnable: Runnable? = null
    private var elapsedTime = 0L
    private var startTime = 0L

    companion object {
        private const val CHANNEL_ID = "PLAYER_SERVICE"
        private const val NOTIFICATION_ID = 2
    }

    override fun onCreate() {
        super.onCreate()

        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onBind(intent: Intent?) = binder

    @Suppress("DEPRECATION")
    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)

        when (intent.action) {
            Status.STARTED.value -> {
                this.startId = startId

                val title = intent.getStringExtra("title")!!
                val path = intent.getStringExtra("path")!!
                val notificationTitle = intent.getStringExtra("notificationTitle")!!

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    notificationManager!!.createNotificationChannel(
                        NotificationChannel(
                            CHANNEL_ID,
                            "${Util.APP_NAME} ${resources.getString(R.string.player)}",
                            NotificationManager.IMPORTANCE_DEFAULT
                        ).apply {
                            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                            setSound(null, null)
                        })

                    builder = Notification.Builder(this, CHANNEL_ID).apply {
                        setWhen(System.currentTimeMillis())
                        setSmallIcon(R.drawable.ic_playing)
                        setOngoing(true)
                        setOnlyAlertOnce(true)
                        setContentTitle(notificationTitle.format(title))
                        setContentText(Util.formatTime(0))
                        setContentIntent(
                            PendingIntent.getActivity(
                                this@PlayerService,
                                NOTIFICATION_ID,
                                packageManager.getLaunchIntentForPackage(packageName)
                                    ?: Intent(this@PlayerService, MainActivity::class.java),
                                0,
                            )
                        )
                    }
                } else {
                    builder = Notification.Builder(this).apply {
                        setWhen(System.currentTimeMillis())
                        setSmallIcon(R.drawable.ic_playing)
                        setOngoing(true)
                        setOnlyAlertOnce(true)
                        setPriority(Notification.PRIORITY_DEFAULT)
                        setVisibility(Notification.VISIBILITY_PUBLIC)
                        setSound(null, null)
                        setContentTitle(notificationTitle.format(title))
                        setContentText(Util.formatTime(0))
                        setContentIntent(
                            PendingIntent.getActivity(
                                this@PlayerService,
                                NOTIFICATION_ID,
                                packageManager.getLaunchIntentForPackage(packageName)
                                    ?: Intent(this@PlayerService, MainActivity::class.java),
                                0,
                            )
                        )
                    }
                }
                create(builder!!.build())

                startPlayer(path)
            }
            Status.PAUSED.value -> {
                val title = intent.getStringExtra("title")!!
                val notificationTitle = intent.getStringExtra("notificationTitle")!!
                builder?.let {
                    it.setContentTitle(notificationTitle.format(title))
                    notificationManager?.notify(NOTIFICATION_ID, it.build())
                }

                pausePlayer()
            }
            Status.RESUMED.value -> {
                val title = intent.getStringExtra("title")!!
                val notificationTitle = intent.getStringExtra("notificationTitle")!!
                builder?.let {
                    it.setContentTitle(notificationTitle.format(title))
                    notificationManager?.notify(NOTIFICATION_ID, it.build())
                }

                resumePlayer()
            }
            Status.STOPPED.value -> stopPlayer()
        }

        return START_NOT_STICKY
    }

    private fun create(notification: Notification) {
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun destroy() {
        elapsedTimeRunnable?.let { elapsedTimeHandler?.removeCallbacks(it) }
//        percentRunnable?.let { percentHandler?.removeCallbacks(it) }

        player?.let {
            it.stop()
            it.reset()
            it.release()
        }
        player = null

        stopForeground(true)
        startId?.let { stopSelf(it) } ?: stopSelf()
    }

    private fun startPlayer(path: String) {
        EventBus.getDefault().removeStickyEvent(Events.PlayerEvent(Status.STOPPED))

        try {
            player = MediaPlayer().also {
                it.setDataSource(path)
                it.setOnCompletionListener {
                    stopPlayer()
                    EventBus.getDefault().postSticky(Events.PlayerEvent(Status.STOPPED))
                }
                it.setOnErrorListener { _, _, _ ->
                    stopPlayer()
                    EventBus.getDefault().postSticky(Events.PlayerEvent(Status.STOPPED))

                    true
                }
            }
            player?.setOnPreparedListener { mp ->
                mp.start()

                startTime = SystemClock.elapsedRealtime()
                elapsedTime = 0L
                elapsedTimeHandler = Looper.getMainLooper()?.let { Handler(it) }
                elapsedTimeRunnable = object : Runnable {
                    override fun run() {
                        val newStartTime = SystemClock.elapsedRealtime()
                        if (player?.isPlaying == true) {
                            elapsedTime += newStartTime - startTime
                            builder?.let {
                                it.setContentText(Util.formatTime(elapsedTime))
                                notificationManager?.notify(NOTIFICATION_ID, it.build())
                            }
                        }
                        startTime = newStartTime

                        elapsedTimeHandler?.postDelayed(this, 10L)
                    }
                }.also { elapsedTimeHandler?.post(it) }
            }
            player?.prepareAsync()
        } catch (e: Exception) {
            e.printStackTrace()
            destroy()
        }
    }

    private fun pausePlayer() = player?.pause()

    private fun resumePlayer() = player?.start()

    private fun stopPlayer() = destroy()

    inner class LocalBinder : Binder() {
        val service get() = this@PlayerService
    }
}
