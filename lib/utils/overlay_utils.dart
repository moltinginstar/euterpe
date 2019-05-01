import "package:flutter/material.dart";

class BottomNavigationBarVisibilityNotification extends Notification {
  bool isVisible;

  BottomNavigationBarVisibilityNotification({required this.isVisible});
}

class TopSnackbarVisibilityNotification extends Notification {
  bool isVisible;

  TopSnackbarVisibilityNotification({required this.isVisible});
}
