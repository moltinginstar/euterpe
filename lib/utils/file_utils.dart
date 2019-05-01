import "dart:io";
import "dart:math";

import "package:easy_localization/easy_localization.dart";
import "package:euterpe/models/models.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/services/store.dart";
import "package:path/path.dart" as p;

const _units = [
  ResStrings.unitB,
  ResStrings.unitKB,
  ResStrings.unitMB,
  ResStrings.unitGB,
  ResStrings.unitTB,
  ResStrings.unitPB,
  ResStrings.unitEB,
  ResStrings.unitZB,
  ResStrings.unitYB,
];

String getFormattedFileSize(String path) {
  final file = File(path);
  final fileLength = file.lengthSync();

  if (fileLength <= 0) {
    return "0 ${ResStrings.unitEB.tr()}";
  }

  final i = (log(fileLength) / log(1024)).floor();

  return "${(fileLength / pow(1024, i)).toStringAsFixed(0)} ${_units[i].tr()}";
}

bool isRecording({required File file}) => Store.supportedFormats
    .contains(p.extension(file.path).toLowerCase().substring(1));

Recording getRecording({required File file}) => Recording(
      title: p.basenameWithoutExtension(file.path),
      date: file.lastModifiedSync().toUtc(),
      path: file.path,
    );

Future<String?> getRecordingNewPath({
  required String newTitle,
  required String path,
}) async {
  var index = 1;
  var recordingNewTitle = newTitle;
  var recordingNewPath = p.join(
    p.dirname(path),
    "$recordingNewTitle${p.extension(path)}",
  );
  var file = File(recordingNewPath);
  while (await file.exists()) {
    recordingNewTitle = "$recordingNewTitle (${index++})";
    var recordingNewPath = p.join(
      p.dirname(path),
      "$recordingNewTitle${p.extension(path)}",
    );
    file = File(recordingNewPath);
  }

  return recordingNewPath;
}
