import "package:equatable/equatable.dart";
import "package:flutter/material.dart";

class Recording extends Equatable {
  final String title;
  final DateTime date;
  final String path;

  late final colors;

  Recording({
    required this.title,
    required this.date,
    required this.path,
  }) {
    final color1 = Color(
        int.parse((title.hashCode & 0x00FFFFFF).toRadixString(16), radix: 16) +
            0xFF000000);
    final color2 = color1
        .withRed(color1.red * 4 ~/ 7)
        .withGreen(color1.green * 4 ~/ 7)
        .withBlue(color1.blue * 4 ~/ 7);
    colors = [color1, color2];
  }

  @override
  List<Object?> get props => [title, date, path];
}
