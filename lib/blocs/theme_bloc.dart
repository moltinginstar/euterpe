import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/utils/utils.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required String savedTheme})
      : super(ThemeState(themeMode: getThemeModeFromThemeString(savedTheme)));

  @override
  Stream<ThemeState> mapEventToState(ThemeEvent event) async* {
    if (event is ThemeChanged) {
      final themeMode = getThemeModeFromThemeString(event.theme);

      yield ThemeState(themeMode: themeMode);
    }
  }
}
