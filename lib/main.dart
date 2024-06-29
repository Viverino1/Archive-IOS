// ignore_for_file: prefer_const_constructors

import 'package:app_links/app_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/data/providors.dart';
import 'package:fbla_nlc_2024/pages/academics_page.dart';
import 'package:fbla_nlc_2024/pages/auth_page.dart';
import 'package:fbla_nlc_2024/pages/hero_page.dart';
import 'package:fbla_nlc_2024/pages/home_page.dart';
import 'package:fbla_nlc_2024/pages/network_page.dart';
import 'package:fbla_nlc_2024/pages/profile_page.dart';
import 'package:fbla_nlc_2024/pages/register_page.dart';
import 'package:fbla_nlc_2024/pages/settings_page.dart';
import 'package:fbla_nlc_2024/pages/support_page.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:fbla_nlc_2024/services/gemini/gemini.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme.dart';

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvidor()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeApp().then((e) => FlutterNativeSplash.remove());

    _appLinks.uriLinkStream.listen((uri) async {
      print(uri.path);
      if(uri.path.contains("support")){
        _navigatorKey.currentState?.popUntil(ModalRoute.withName('/'));
        _navigatorKey.currentState?.push(CupertinoPageRoute(
            builder: (ctx) => SupportPage()));
      }else{
        UserData? linkUser =
        await Firestore.getUser(uri.path.replaceAll("/", ""));
        if (linkUser != null && context.read<UserProvidor>().isAuthenticated && linkUser.uid != context.read<UserProvidor>().currentUser.uid) {
          Navigator.of(context).popUntil(ModalRoute.withName('/'));
          _navigatorKey.currentState?.push(CupertinoPageRoute(
              builder: (ctx) => ProfilePage(user: linkUser, isMine: false,)));
        }
      }
    });
  }

  Future<void> initializeApp() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    Gemini.init();

    final fbu = FirebaseAuth.instance.currentUser;

    if(fbu != null){
      final UserData? user = await context.read<UserProvidor>().getUser(fbu.uid);
      if(user != null){
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        OneSignal.initialize("27c7ab08-f87c-4a08-81d8-fcca68c227b9");
        String? id = await OneSignal.User.getOnesignalId();
        if(id != null){
          Firestore.setOnesignalId(id, user);
        }
        OneSignal.Notifications.requestPermission(true);

        context.read<UserProvidor>().setCurrentUser(user);
        context.read<UserProvidor>().setIsAuthenticated(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: cupertinoDark,
      home: context.watch<UserProvidor>().isAuthenticated? HomePage() : HeroPage(),
      routes: {
        '/auth': (context) => AuthPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}