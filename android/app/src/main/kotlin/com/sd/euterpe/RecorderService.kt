package com.sd.euterpe

import android.app.*
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.media.*
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
import android.os.*
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import com.arthenica.ffmpegkit.FFmpegKit
import org.greenrobot.eventbus.EventBus
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.*
import kotlin.math.abs

class RecorderService : Service() {
    private var startId: Int? = null
    private var notificationManager: NotificationManager? = null
    private var builder: Notification.Builder? = null

    private var recorder: AudioRecord? = null
    private var minBufferSize = 1

    private var format = ""
    private var quality = ""
    private var channels = ""
    private var echoCancellation = false
    private var noiseSuppression = false

    private var acousticEchoCanceler: AcousticEchoCanceler? = null
    private var noiseSuppressor: NoiseSuppressor? = null

    private var isRecording = false
    private var recordingThread: Thread? = null
    private var recordingTempFile: File? = null
    private var recordingFinalFile: File? = null

    private val maxWaveformLength: Int
        get() {
            val widthDip = resources.displayMetrics.widthPixels / resources.displayMetrics.density

            return (widthDip / (2.0 * 2)).toInt()
        }
    private val waveform = mutableListOf<Double>()

    private var elapsedTimeHandler: Handler? = null
    private var elapsedTimeRunnable: Runnable? = null
    private var elapsedTime = 0L
    private var startTime = 0L

    companion object {
        private const val CHANNEL_ID = "RECORDER_SERVICE"
        private const val NOTIFICATION_ID = 1
    }

    override fun onCreate() {
        super.onCreate()

        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onBind(intent: Intent?): IBinder? = null

    @Suppress("DEPRECATION")
    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)

        when (intent.action) {
            Status.STARTED.value -> {
                this.startId = startId

                format = intent.getStringExtra("format")!!
                quality = intent.getStringExtra("quality")!!
                channels = intent.getStringExtra("channels")!!
                echoCancellation = intent.getBooleanExtra("echoCancellation", false)
                noiseSuppression = intent.getBooleanExtra("noiseSuppression", false)
                val notificationTitle = intent.getStringExtra("notificationTitle")!!

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    notificationManager!!.createNotificationChannel(
                        NotificationChannel(
                            CHANNEL_ID,
                            "${Util.APP_NAME} ${resources.getString(R.string.recorder)}",
                            NotificationManager.IMPORTANCE_DEFAULT
                        ).apply {
                            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                            setSound(null, null)
                        })

                    builder = Notification.Builder(this, CHANNEL_ID).apply {
                        setWhen(System.currentTimeMillis())
                        setSmallIcon(R.drawable.ic_recording)
                        setOngoing(true)
                        setOnlyAlertOnce(true)
                        setContentTitle(notificationTitle)
                        setContentText(Util.formatTime(0))
                        setContentIntent(
                            PendingIntent.getActivity(
                                this@RecorderService,
                                NOTIFICATION_ID,
                                packageManager.getLaunchIntentForPackage(packageName)
                                    ?: Intent(this@RecorderService, MainActivity::class.java),
                                0,
                            )
                        )
                    }
                } else {
                    builder = Notification.Builder(this).apply {
                        setWhen(System.currentTimeMillis())
                        setSmallIcon(R.drawable.ic_recording)
                        setOngoing(true)
                        setOnlyAlertOnce(true)
                        setPriority(Notification.PRIORITY_DEFAULT)
                        setVisibility(Notification.VISIBILITY_PUBLIC)
                        setSound(null, null)
                        setContentTitle(notificationTitle)
                        setContentText(Util.formatTime(0))
                        setContentIntent(
                            PendingIntent.getActivity(
                                this@RecorderService,
                                NOTIFICATION_ID,
                                packageManager.getLaunchIntentForPackage(packageName)
                                    ?: Intent(this@RecorderService, MainActivity::class.java),
                                0,
                            )
                        )
                    }
                }
                create(builder!!.build())

                startRecorder()
            }
            Status.PAUSED.value -> {
                val notificationTitle = intent.getStringExtra("notificationTitle")!!
                builder?.let {
                    it.setContentTitle(notificationTitle)
                    notificationManager?.notify(NOTIFICATION_ID, it.build())
                }

                pauseRecorder()
            }
            Status.RESUMED.value -> {
                val notificationTitle = intent.getStringExtra("notificationTitle")!!
                builder?.let {
                    it.setContentTitle(notificationTitle)
                    notificationManager?.notify(NOTIFICATION_ID, it.build())
                }

                resumeRecorder()
            }
            Status.STOPPED.value -> stopRecorder(intent.getStringExtra("title"))
        }

        return START_NOT_STICKY
    }

    private fun create(notification: Notification) {
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun destroy() {
        elapsedTimeRunnable?.let { elapsedTimeHandler?.removeCallbacks(it) }

        isRecording = false
        recorder?.let {
            it.stop()
            it.release()
        }
        recorder = null
        recordingThread = null
        minBufferSize = 1

        waveform.clear()

        acousticEchoCanceler?.enabled = false
        acousticEchoCanceler?.release()
        acousticEchoCanceler = null
        noiseSuppressor?.enabled = false
        noiseSuppressor?.release()
        noiseSuppressor = null

        recordingTempFile?.delete()
        recordingFinalFile?.delete()

        stopForeground(true)
        startId?.let { stopSelf(it) } ?: stopSelf()
    }

    private fun startRecorder() {
        try {
            val audioQuality = Util.getSampleRate(quality)
            val audioChannels = if (channels == "stereo") {
                AudioFormat.CHANNEL_IN_STEREO
            } else {
                AudioFormat.CHANNEL_IN_MONO
            }
            minBufferSize = AudioRecord.getMinBufferSize(
                audioQuality,
                audioChannels,
                AudioFormat.ENCODING_PCM_16BIT,
            )
            recorder = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                audioQuality,
                audioChannels,
                AudioFormat.ENCODING_PCM_16BIT,
                minBufferSize,
            ).also {
                if (AcousticEchoCanceler.isAvailable() && echoCancellation) {
                    acousticEchoCanceler = AcousticEchoCanceler.create(it.audioSessionId)
                        .also { acousticEchoCanceler -> acousticEchoCanceler.enabled = true }
                }
                if (NoiseSuppressor.isAvailable() && noiseSuppression) {
                    noiseSuppressor = NoiseSuppressor.create(it.audioSessionId)
                        .also { noiseSuppressor -> noiseSuppressor.enabled = true }
                }
                it.startRecording()
            }

            isRecording = true
            val recordingTempFileName = "${Util.getRecordingTitle("", format)}.pcm"
            recordingTempFile = filesDir.resolve(recordingTempFileName).also { it.createNewFile() }
            recordingThread = Thread {
                try {
                    FileOutputStream(recordingTempFile).use { outputStream ->
                        val bufferSize = minBufferSize * 2  // Arbitrary factor
                        val data = ShortArray(bufferSize)
                        while (isRecording) {
                            recorder!!.read(data, 0, bufferSize / 2)

                            waveform.add(data.maxByOrNull { abs(it.toDouble()) }?.toDouble() ?: 0.0)
                            if (waveform.size == maxWaveformLength + 1) {
                                waveform.removeAt(0)
                            }
                            EventBus.getDefault().post(Events.WaveformEvent(waveform))

                            outputStream.write(data.toByteArray(), 0, bufferSize)
                        }

                        return@Thread
                    }
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }.also { it.start() }

            startTime = SystemClock.elapsedRealtime()
            elapsedTime = 0L
            elapsedTimeHandler = Looper.getMainLooper()?.let { Handler(it) }
            elapsedTimeRunnable = object : Runnable {
                override fun run() {
                    val newStartTime = SystemClock.elapsedRealtime()
                    if (recorder?.recordingState == AudioRecord.RECORDSTATE_RECORDING) {
                        elapsedTime += newStartTime - startTime
                        builder?.let {
                            it.setContentText(Util.formatTime(elapsedTime))
                            notificationManager?.notify(NOTIFICATION_ID, it.build())
                        }
                        EventBus.getDefault().post(Events.ElapsedTimeEvent(elapsedTime))
                    }
                    startTime = newStartTime

                    elapsedTimeHandler?.postDelayed(this, 10L)
                }
            }.also { elapsedTimeHandler?.post(it) }
        } catch (e: Exception) {
            e.printStackTrace()
            destroy()
        }
    }

    private fun pauseRecorder() {
        isRecording = false
        recorder?.stop()
        recordingThread = null
    }

    private fun resumeRecorder() {
        recorder?.startRecording()

        isRecording = true
        recordingThread = Thread {
            try {
                FileOutputStream(recordingTempFile, true).use { outputStream ->
                    val bufferSize = minBufferSize * 2  // Arbitrary factor
                    val data = ShortArray(bufferSize)
                    while (isRecording) {
                        recorder!!.read(data, 0, bufferSize / 2)
                        waveform.add(data.maxByOrNull { abs(it.toDouble()) }?.toDouble() ?: 0.0)
                        if (waveform.size == maxWaveformLength + 1) {
                            waveform.removeAt(0)
                        }
                        EventBus.getDefault().post(Events.WaveformEvent(waveform))

                        outputStream.write(data.toByteArray(), 0, bufferSize)
                    }

                    return@Thread
                }
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }.also { it.start() }
    }

    private fun stopRecorder(title: String?) {
        try {
            if (title != null) {
                val recordingTitle = Util.getRecordingTitle(title, format)
                recordingFinalFile = filesDir.resolve("$recordingTitle.$format").also {
                    it.createNewFile()
                }

                processRecording()
                saveRecording()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        destroy()
    }

    private fun processRecording() {
        val recordingTempFilePath = recordingTempFile?.path
        val recordingFinalFilePath = recordingFinalFile?.path
        FFmpegKit.execute("-y -f s16le -i '$recordingTempFilePath' '$recordingFinalFilePath'")
    }

    private fun saveRecording() {
        val mimeType = MimeTypeMap
            .getSingleton()
            .getMimeTypeFromExtension(recordingFinalFile?.extension)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val contentValues = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, recordingFinalFile?.name)
                put(MediaStore.Audio.Media.TITLE, recordingFinalFile?.name)
                put(MediaStore.Audio.Media.MIME_TYPE, mimeType)
                put(
                    MediaStore.Audio.Media.RELATIVE_PATH,
                    Util.saveLocationRelativePath,
                )
            }
            val uri = contentResolver.insert(
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
                contentValues,
            )
            try {
                FileInputStream(recordingFinalFile).use { inputStream ->
                    contentResolver.openOutputStream(uri!!).use { outputStream ->
                        inputStream.copyTo(outputStream!!, DEFAULT_BUFFER_SIZE)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } else {
            val recordingFinalFilePath = recordingFinalFile?.name?.let { recordingFinalFilename ->
                Util.saveLocationCanonicalFile
                    .resolve(recordingFinalFilename)
                    .also {
                        try {
                            FileInputStream(recordingFinalFile).use { inputStream ->
                                FileOutputStream(it).use { outputStream ->
                                    inputStream.copyTo(outputStream, DEFAULT_BUFFER_SIZE)
                                }
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
            }
            MediaScannerConnection.scanFile(
                this,
                arrayOf(recordingFinalFilePath?.path),
                arrayOf(mimeType),
            ) { _, _ -> }
        }
    }

    private fun ShortArray.toByteArray(): ByteArray {
        val bytes = ByteArray(size * 2)
        for (i in indices) {
            bytes[i * 2] = (this[i].toInt() and 0x00FF).toByte()
            bytes[i * 2 + 1] = (this[i].toInt() shr 8).toByte()
            this[i] = 0
        }

        return bytes
    }
}
