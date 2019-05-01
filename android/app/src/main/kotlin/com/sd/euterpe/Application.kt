package com.sd.euterpe

import android.app.Application
import org.greenrobot.eventbus.EventBus

@Suppress("unused")
class Application : Application() {
    override fun onCreate() {
        super.onCreate()

        EventBus.builder().addIndex(EventBusIndex()).installDefaultEventBus()
    }
}
