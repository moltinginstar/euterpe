package com.sd.euterpe

class Events {
    data class WaveformEvent(val amplitudes: List<Double>)

    data class ElapsedTimeEvent(val elapsedTime: Long)

//    data class PercentEvent(val percent: Double)

    data class PlayerEvent(val status: Status)
}
