import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projet_sncf/firebase_options.dart';
import 'package:projet_sncf/screens/liste_rapports_screen.dart';
import 'package:projet_sncf/utils/app_colors.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
late final FirebaseApp app;
late final PackageInfo packageInfo;
late final String appVersionOnFirebase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestPermissions();
  packageInfo = await PackageInfo.fromPlatform();
  appVersionOnFirebase = await getAppVersionFromFirebase();

  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

Future<String> getAppVersionFromFirebase() async {
  var db = FirebaseDatabase.instance;
  var ref = db.ref(kDebugMode ? "testVersion" : "appVersion");
  var dbEvent = await ref.once();
  return dbEvent.snapshot.value! as String;
}

Future<void> updateTestVersion() async {
  var db = FirebaseDatabase.instance;
  var ref = db.ref("testVersion");
  await ref.set(packageInfo.version);
}

Future<String> getApkDownloadUrl() async {
  Reference ref = FirebaseStorage.instance.ref('app-release.apk');
  String url = await ref.getDownloadURL();
  return url;
}

Future<File> downloadApk(String url, Function(double) onProgress) async {
  Dio dio = Dio();
  var dir = await getApplicationDocumentsDirectory();
  String savePath = '${dir.path}/app.apk';
  await dio.download(
    url,
    savePath,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        double progress = received / total;
        onProgress(progress); // Mise à jour de la progression
      }
    },
  );
  return File(savePath);
}

Future<void> installApkWithOpenFile(String apkPath) async {
  await OpenFile.open(apkPath);
}

Future<void> requestPermissions() async {
  await Permission.storage.request();
  await Permission.requestInstallPackages.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', 'FR'),
      ],
      locale: const Locale('fr', 'FR'),
      navigatorObservers: [routeObserver],
      title: 'Rapport Secteur Argenteuil',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
        ),
        cardTheme: CardTheme(
          color: AppColors.primary,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
        ),
        cardTheme: CardTheme(
          color: AppColors.cardColor,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.checkboxSelectedFillColor
                : null,
          ),
          checkColor: WidgetStateProperty.all(AppColors.checkboxCheckColor),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.radioSelectedFillColor
                : null,
          ),
        ),
        expansionTileTheme: ExpansionTileThemeData(
          iconColor: Colors.white,
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const ListeRapportsScreen(),
    );
  }
}
