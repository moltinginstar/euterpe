import "package:flutter/material.dart";

enum BottomSheetStatus {
  completed,
  postexpanded, // Same as completed, technically
  postexpanding,
  expanded,
  expanding,
  preexpanded,
  preexpanding,
  appeared,
  appearing, // Same as forward, technically
  forward,
  reverse,
  precollapsing,
  precollapsed,
  collapsing,
  collapsed,
  postcollapsing,
  postcollapsed,
  disappearing,
  disappeared, // Same as dismissed, technically
  dismissed,
}

Future dismissBottomSheet(PopupRoute? bottomSheet) async {
  if (bottomSheet == null) {
    return null;
  }

  if (bottomSheet.isCurrent) {
    bottomSheet.navigator!.pop();

    return await bottomSheet.completed;
  } else if (bottomSheet.isActive) {
    bottomSheet.navigator!.removeRoute(bottomSheet);
  }

  return null;
}
