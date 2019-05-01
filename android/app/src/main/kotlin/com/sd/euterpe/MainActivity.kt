package com.sd.euterpe

import android.content.ComponentName
import android.content.ContentValues
import android.content.Intent
import android.content.ServiceConnection
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PersistableBundle
import android.provider.MediaStore
import android.view.ViewConfiguration
import android.view.WindowManager
import androidx.annotation.Keep
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

@Suppress("unused")
class MainActivity : FlutterActivity() {
    private var playerService: PlayerService? = null
    private val playerServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            playerService = (service as PlayerService.LocalBinder).service
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            playerService = null
        }
    }
    private var isPlayerServiceBound = false
    private var eventBus: EventBus? = null

    private lateinit var generalMethods: MethodChannel
    private lateinit var recorderMethods: MethodChannel
    private lateinit var playerMethods: MethodChannel

    private lateinit var generalMethodsResult: MethodChannel.Result
    private lateinit var recorderMethodsResult: MethodChannel.Result
    private lateinit var playerMethodsResult: MethodChannel.Result

    companion object {
        private const val GENERAL_METHODS = "com.sd.euterpe/general_methods"
        private const val RECORDER_METHODS = "com.sd.euterpe/recorder"
        private const val PLAYER_METHODS = "com.sd.euterpe/player"
        private const val RECORDER_WAVEFORM_STREAM = "com.sd.euterpe/recorder_waveform_stream"
        private const val RECORDER_ELAPSED_TIME_STREAM =
            "com.sd.euterpe/recorder_elapsed_time_stream"
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)

        // https://github.com/flutter/flutter/issues/64001
        val uiMode = context.resources
            ?.configuration
            ?.uiMode
            ?.and(Configuration.UI_MODE_NIGHT_MASK)
        window.statusBarColor = Color.TRANSPARENT
        WindowCompat.getInsetsController(window, window.decorView)?.let {
            it.isAppearanceLightStatusBars = uiMode != Configuration.UI_MODE_NIGHT_YES
        }
    }

    @Suppress("DEPRECATION")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        generalMethods = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            GENERAL_METHODS,
        ).also {
            it.setMethodCallHandler { call, result ->
                generalMethodsResult = result
                when (call.method) {
                    "getSaveLocation" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val contentValues = ContentValues().apply {
                                put(
                                    MediaStore.Audio.Media.RELATIVE_PATH,
                                    Util.saveLocationRelativePath,
                                )
                            }
                            contentResolver.insert(
                                MediaStore.Audio.Media.getContentUri(
                                    MediaStore.VOLUME_EXTERNAL_PRIMARY
                                ),
                                contentValues,
                            )
                        }
                        generalMethodsResult.success(Util.saveLocationCanonicalFile.path)
                    }
                    "getLongPressDuration" -> {
                        generalMethodsResult.success(ViewConfiguration.getLongPressTimeout())
                    }
                    "setKeepScreenOn" -> setKeepScreenOn(call.argument("shouldKeepScreenOn"))
                    else -> result.notImplemented()
                }
            }
        }
        recorderMethods = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RECORDER_METHODS,
        ).also {
            it.setMethodCallHandler { call, result ->
                recorderMethodsResult = result
                when (call.method) {
                    "start" -> {
                        startRecorder(
                            call.argument("format"),
                            call.argument("quality"),
                            call.argument("channels"),
                            call.argument("echoCancellation"),
                            call.argument("noiseSuppression"),
                            call.argument("notificationTitle"),
                        )
                        recorderMethodsResult.success(null)
                    }
                    "pause" -> {
                        pauseRecorder(call.argument("notificationTitle"))
                        recorderMethodsResult.success(null)
                    }
                    "resume" -> {
                        resumeRecorder(call.argument("notificationTitle"))
                        recorderMethodsResult.success(null)
                    }
                    "stop", "cancel" -> {
                        stopRecorder(call.argument("title"))
                        recorderMethodsResult.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        playerMethods = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PLAYER_METHODS,
        ).also {
            it.setMethodCallHandler { call, result ->
                playerMethodsResult = result
                when (call.method) {
                    "start" -> {
                        startPlayer(
                            call.argument("title"),
                            call.argument("path"),
                            call.argument("notificationTitle"),
                        )
                        playerMethodsResult.success(null)
                    }
                    "pause" -> {
                        pausePlayer(call.argument("notificationTitle"))
                        playerMethodsResult.success(null)
                    }
                    "resume" -> {
                        resumePlayer(call.argument("notificationTitle"))
                        playerMethodsResult.success(null)
                    }
                    "stop" -> {
                        stopPlayer()
                        playerMethodsResult.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RECORDER_WAVEFORM_STREAM,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            private var sink: EventChannel.EventSink? = null
            private var eventBus: EventBus? = null

            override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                sink = events
                eventBus = EventBus.getDefault().also {
                    if (!it.isRegistered(this)) {
                        it.register(this)
                    }
                }
            }

            override fun onCancel(args: Any?) {
                sink = null
                eventBus?.unregister(this)
            }

            @Keep
            @Subscribe(threadMode = ThreadMode.MAIN)
            fun onWaveformEvent(event: Events.WaveformEvent) = sink?.success(event.amplitudes)
        })
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RECORDER_ELAPSED_TIME_STREAM,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            private var sink: EventChannel.EventSink? = null
            private var eventBus: EventBus? = null

            override fun onListen(args: Any?, events: EventChannel.EventSink?) {
                sink = events
                eventBus = EventBus.getDefault().also {
                    if (!it.isRegistered(this)) {
                        it.register(this)
                    }
                }
            }

            override fun onCancel(args: Any?) {
                sink = null
                eventBus?.unregister(this)
            }

            @Keep
            @Subscribe(threadMode = ThreadMode.MAIN)
            fun onElapsedTimeEvent(event: Events.ElapsedTimeEvent) =
                sink?.success(event.elapsedTime)
        })
    }

    override fun onStart() {
        super.onStart()

        eventBus = EventBus.getDefault().also {
            if (!it.isRegistered(this)) {
                it.register(this)
            }
        }
    }

    override fun onStop() {
        eventBus?.unregister(this)

        super.onStop()
    }

    override fun onDestroy() {
        if (isPlayerServiceBound) {
            unbindService(playerServiceConnection)
            isPlayerServiceBound = false
        }

        super.onDestroy()
    }

    @Keep
    @Subscribe(sticky = true, threadMode = ThreadMode.MAIN)
    fun onPlayerEvent(event: Events.PlayerEvent) {
        if (event.status == Status.STOPPED) {
            playerMethods.invokeMethod("completed", null)
        }
    }

    private fun startRecorder(
        format: String?,
        quality: String?,
        channels: String?,
        echoCancellation: Boolean?,
        noiseSuppression: Boolean?,
        notificationTitle: String?,
    ) {
        Intent(this, RecorderService::class.java).apply {
            action = Status.STARTED.value
            putExtra("format", format)
            putExtra("quality", quality)
            putExtra("channels", channels)
            putExtra("echoCancellation", echoCancellation)
            putExtra("noiseSuppression", noiseSuppression)
            putExtra("notificationTitle", notificationTitle)
        }.also { startService(it) }
    }

    private fun pauseRecorder(notificationTitle: String?) {
        Intent(this, RecorderService::class.java).apply {
            action = Status.PAUSED.value
            putExtra("notificationTitle", notificationTitle)
        }.also { startService(it) }
    }

    private fun resumeRecorder(notificationTitle: String?) {
        Intent(this, RecorderService::class.java).apply {
            action = Status.RESUMED.value
            putExtra("notificationTitle", notificationTitle)
        }.also { startService(it) }
    }

    private fun stopRecorder(title: String?) {
        Intent(this, RecorderService::class.java).apply {
            action = Status.STOPPED.value
            putExtra("title", title)
        }.also { startService(it) }
    }

    private fun startPlayer(
        title: String?,
        path: String?,
        notificationTitle: String?,
    ) {
        Intent(this, PlayerService::class.java).apply {
            action = Status.STARTED.value
            putExtra("title", title)
            putExtra("path", path)
            putExtra("notificationTitle", notificationTitle)
        }.also {
            startService(it)
            isPlayerServiceBound = bindService(it, playerServiceConnection, 0)
        }
    }

    private fun pausePlayer(notificationTitle: String?) {
        Intent(this, PlayerService::class.java).apply {
            action = Status.PAUSED.value
            putExtra("notificationTitle", notificationTitle)
        }.also { startService(it) }
    }

    private fun resumePlayer(notificationTitle: String?) {
        Intent(this, PlayerService::class.java).apply {
            action = Status.RESUMED.value
            putExtra("notificationTitle", notificationTitle)
        }.also { startService(it) }
    }

    private fun stopPlayer() {
        Intent(this, PlayerService::class.java).apply {
            action = Status.STOPPED.value
        }.also {
            startService(it)
            if (isPlayerServiceBound) {
                unbindService(playerServiceConnection)
                isPlayerServiceBound = false
            }
        }
    }

    private fun setKeepScreenOn(shouldKeepScreenOn: Boolean?) {
        if (shouldKeepScreenOn == true) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }
}
