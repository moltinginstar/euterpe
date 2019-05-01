package com.sd.euterpe

import android.os.Environment
import java.io.File
import java.time.Instant

object Util {
    const val APP_NAME = "Lyre"

    @Suppress("DEPRECATION")
    val saveLocationCanonicalFile: File
        get() = Environment
            .getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
            .resolve("$APP_NAME Recordings")
            .also { it.mkdirs() }
            .canonicalFile

    val saveLocationRelativePath: String
        get() = File(Environment.DIRECTORY_MUSIC).resolve("$APP_NAME Recordings").path

    fun formatTime(timeInMillis: Long): String {
        val timeInSeconds = timeInMillis / 1000
        val seconds = timeInSeconds % 60
        val minutes = (timeInSeconds - seconds) / 60

        val mm = minutes.toString().padStart(2, '0')
        val ss = seconds.toString().padStart(2, '0')

        return "$mm:$ss"
    }

    fun getRecordingTitle(title: String, format: String): String {
        val recordingTitle = if (title.isNotEmpty()) title else Instant.now()
            .toString()
            .replace(":", "")
            .replace("-", "")
            .replace(".", "")

        var index = 1
        var newTitle = recordingTitle
        var recordingPath = saveLocationCanonicalFile.resolve("$newTitle.$format")
        while (recordingPath.exists()) {
            newTitle = "$recordingTitle (${index++})"
            recordingPath = saveLocationCanonicalFile.resolve("$newTitle.$format")
        }

        return recordingTitle
    }

    fun getSampleRate(quality: String?) = when (quality) {
        "low" -> 11025
        "medium" -> 22050
        "best" -> 96000
        else -> 44100  // Guaranteed to work on all devices
    }
}
