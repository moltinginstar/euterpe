import "package:device_info_plus/device_info_plus.dart";
import "package:easy_localization/easy_localization.dart";
import "package:euterpe/res/res.dart";
import "package:euterpe/views/overlays/permission_rationale_dialog.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";

Future<bool> checkPermissions() async =>
    await Permission.microphone.isGranted && await Permission.storage.isGranted;

Future<bool> getPermissions(BuildContext context) async {
  await _getPermission(context, Permission.microphone);
  await _getPermission(context, Permission.storage);

  return await checkPermissions();
}

Future<void> _getPermission(BuildContext context, Permission permission) async {
  await permission.request();
  // Currently there seems to be no way to check if the user actually clicked
  // Deny, thus permanently disabling the permission (on API >= 30), or simply
  // clicked outside the permission dialog, holding off on a definitive answer
  if ((await DeviceInfoPlugin().androidInfo).version.sdkInt! >= 30) {
    if (await permission.isDenied) {
      await showDialog(
        context: context,
        builder: (context) => PermissionRationaleDialog(
          permission: permission,
          confirmLabel: ResStrings.textOpenSettings.tr(),
          onConfirm: openAppSettings,
        ),
      );
    }
  } else {
    if (await permission.isPermanentlyDenied || await permission.isDenied) {
      await showDialog(
        context: context,
        builder: (context) => PermissionRationaleDialog(
          permission: permission,
          confirmLabel: ResStrings.textOpenSettings.tr(),
          onConfirm: openAppSettings,
        ),
      );
    }
    // else if (await permission.isDenied) {
    //   await showDialog(
    //     context: context,
    //     builder: (context) => PermissionRationaleDialog(
    //       permission: permission,
    //       confirmLabel: ResStrings.textOkay.tr(),
    //       onConfirm: () async => await _getPermission(context, permission), // Causes Unhandled Exception: Looking up a deactivated widget's ancestor is unsafe.
    //     ),
    //   );
    // }
  }
}
