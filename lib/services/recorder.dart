import "package:flutter/services.dart";

class Recorder {
  static final recorderClient = MethodChannel("com.sd.euterpe/recorder");
  static final recorderWaveformStream =
      EventChannel("com.sd.euterpe/recorder_waveform_stream");
  static final recorderElapsedTimeStream =
      EventChannel("com.sd.euterpe/recorder_elapsed_time_stream");

  Future<void> start({
    required String format,
    required String quality,
    required String channels,
    required bool echoCancellation,
    required bool noiseSuppression,
    required String notificationTitle,
  }) async =>
      await recorderClient.invokeMethod("start", {
        "format": format,
        "quality": quality,
        "channels": channels,
        "echoCancellation": echoCancellation,
        "noiseSuppression": noiseSuppression,
        "notificationTitle": notificationTitle,
      });

  Future<void> pause({required String notificationTitle}) async =>
      await recorderClient.invokeMethod("pause", {
        "notificationTitle": notificationTitle,
      });

  Future<void> resume({required String notificationTitle}) async =>
      await recorderClient.invokeMethod("resume", {
        "notificationTitle": notificationTitle,
      });

  Future<void> stop({required String title}) async =>
      await recorderClient.invokeMethod("stop", {"title": title});

  Future<void> cancel() async => await recorderClient.invokeMethod("cancel");
}
