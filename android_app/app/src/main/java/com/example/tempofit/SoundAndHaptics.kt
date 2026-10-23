package com.example.tempofit

import android.content.Context
import android.media.ToneGenerator
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

class SoundAndHaptics(private val context: Context) {

    private val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
        vibratorManager?.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }

    private var toneGen: ToneGenerator? = null

    init {
        try {
            toneGen = ToneGenerator(AudioManager.STREAM_MUSIC, 85)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun playRepBeep() {
        toneGen?.startTone(ToneGenerator.TONE_PROP_BEEP, 80)
        vibrate(60)
    }

    fun playSetComplete() {
        toneGen?.startTone(ToneGenerator.TONE_CDMA_CONFIRM, 250)
        vibratePattern(longArrayOf(0, 100, 80, 200))
    }

    fun playRestCountdownTick() {
        toneGen?.startTone(ToneGenerator.TONE_PROP_PROMPT, 50)
        vibrate(30)
    }

    private fun vibrate(durationMs: Long) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(durationMs)
        }
    }

    private fun vibratePattern(pattern: LongArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, -1)
        }
    }

    fun release() {
        toneGen?.release()
        toneGen = null
    }
}

