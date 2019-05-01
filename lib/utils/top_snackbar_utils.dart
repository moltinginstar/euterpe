enum TopSnackbarStatus {
  completed,
  forward,
  reverse,
  dismissed,
}

typedef void TopSnackbarStatusCallback(TopSnackbarStatus status);
