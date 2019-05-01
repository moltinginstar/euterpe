import "package:flutter/services.dart";

const generalMethods = MethodChannel("com.sd.euterpe/general_methods");

Future<String> getSaveLocation() async =>
    await generalMethods.invokeMethod("getSaveLocation");

Future<int> getLongPressDuration() async =>
    await generalMethods.invokeMethod("getLongPressDuration");

Future<void> setKeepScreenOn(bool shouldKeepScreenOn) async =>
    await generalMethods.invokeMethod("setKeepScreenOn", {
      "shouldKeepScreenOn": shouldKeepScreenOn,
    });
