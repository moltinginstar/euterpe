import "package:flutter/services.dart";

class Player {
  static final playerClient = MethodChannel("com.sd.euterpe/player");

  Future<void> start({
    required String title,
    required String path,
    required String notificationTitle,
  }) async =>
      await playerClient.invokeMethod("start", {
        "title": title,
        "path": path,
        "notificationTitle": notificationTitle,
      });

  Future<void> pause({required String notificationTitle}) async =>
      await playerClient.invokeMethod("pause", {
        "notificationTitle": notificationTitle,
      });

  Future<void> resume({required String notificationTitle}) async =>
      await playerClient.invokeMethod("resume", {
        "notificationTitle": notificationTitle,
      });

  Future<void> stop() async => await playerClient.invokeMethod("stop");
}
