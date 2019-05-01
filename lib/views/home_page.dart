import "package:euterpe/blocs/blocs.dart";
import "package:euterpe/services/player.dart";
import "package:euterpe/services/recorder.dart";
import "package:euterpe/utils/utils.dart";
import "package:euterpe/views/components/bottom_navigation_bar.dart";
import "package:euterpe/views/components/keep_alive_page.dart";
import "package:euterpe/views/tabs/record_tab.dart";
import "package:euterpe/views/tabs/recordings_tab.dart";
import "package:euterpe/views/tabs/settings_tab.dart";
import "package:flutter/material.dart" hide BottomNavigationBar;
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class EuterpeHomePage extends StatefulWidget {
  EuterpeHomePage({Key? key}) : super(key: key);

  @override
  _EuterpeHomePageState createState() => _EuterpeHomePageState();
}

class _EuterpeHomePageState extends State<EuterpeHomePage>
    with SingleTickerProviderStateMixin {
  final _tabController = PageController(keepPage: false);
  var _currentTab = 0;

  var _isBottomNavigationBarVisible = true;
  var _isTopSnackbarVisible = false;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<BottomNavigationBarVisibilityNotification>(
        onNotification: (notification) {
          setState(() {
            _isBottomNavigationBarVisible = notification.isVisible;
          });

          return true;
        },
        child: NotificationListener<TopSnackbarVisibilityNotification>(
          onNotification: (notification) {
            setState(() => _isTopSnackbarVisible = notification.isVisible);

            return true;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).primaryColor,
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: getSystemUiOverlayStyle(
                Theme.of(context).brightness,
                _isBottomNavigationBarVisible,
                _isTopSnackbarVisible,
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        BlocProvider(
                          create: (context) =>
                              RecorderBloc(recorder: Recorder()),
                          child: KeepAlivePage(child: RecordTab()),
                        ),
                        BlocProvider(
                          create: (context) => PlayerBloc(player: Player()),
                          child: KeepAlivePage(child: RecordingsTab()),
                        ),
                        KeepAlivePage(child: SettingsTab()),
                      ],
                      controller: _tabController,
                    ),
                    if (_isBottomNavigationBarVisible)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: BottomNavigationBar(
                          currentTab: _currentTab,
                          onPressed: (i) {
                            _tabController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.fastLinearToSlowEaseIn,
                            );
                            setState(() => _currentTab = i);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
