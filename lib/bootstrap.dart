import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:starship_shooter/gen/assets.gen.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log(
      'onEvent(${bloc.runtimeType} $event)',
      name: 'Global Bloc Observer',
    );
  }

  // @override
  // void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
  //   super.onChange(bloc, change);
  //   log(
  //     'onChange(${bloc.runtimeType}, $change)',
  //     name: 'Global Bloc Observer',
  //   );
  // }

  // @override
  // void onTransition(
  //   Bloc<dynamic, dynamic> bloc,
  //   Transition<dynamic, dynamic> transition,
  // ) {
  //   super.onTransition(bloc, transition);
  //   log(
  //     'onTransition(${bloc.runtimeType} $transition)',
  //     name: 'Global Bloc Observer',
  //   );
  // }

  // @override
  // void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
  //   super.onError(bloc, error, stackTrace);
  //   log(
  //     'onError(${bloc.runtimeType}, $error, $stackTrace)',
  //     name: 'Global Bloc Observer',
  //   );
  // }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = AppBlocObserver();

  LicenseRegistry.addLicense(() async* {
    final poppins = await rootBundle.loadString(Assets.licenses.poppins.ofl);
    yield LicenseEntryWithLineBreaks(['poppins'], poppins);
  });

  // Add cross-flavor configuration here
  WidgetsFlutterBinding.ensureInitialized();
  // await Flame.device.fullScreen();
  // await Flame.device.setLandscape();
  await FullScreenWindow.setFullScreen(true);

  runApp(await builder());
}
