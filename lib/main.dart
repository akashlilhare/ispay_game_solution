import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/splash_page.dart';
import '../provider/authentication_provider.dart';
import '../provider/chats_page_provider.dart';
import '../provider/user_page_provider.dart';
import '../services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SplashPage(onComplete: () {
        runApp(MainApp());
      }),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
            create: (BuildContext context) {
          return AuthenticationProvider();
        })
      ],
      child: Consumer<AuthenticationProvider>(builder: (context, _auth, _) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<UserPageProvider>(
              create: (_) => UserPageProvider(_auth),
            ),
            ChangeNotifierProvider(create: (_) => ChatsPageProvider(_auth)),
          ],
          child: MaterialApp(
            title: "Flash Chat",
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primaryColor: Color(0xff4D81F7),
                secondaryHeaderColor: Color(0xff6E99FA),
                backgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
                scaffoldBackgroundColor: Color(0xffFDFDFD),
                inputDecorationTheme: InputDecorationTheme(fillColor:Color(0xffEEF2FE) ),
                appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xffFDFDFD),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    elevation: 0, backgroundColor: Color(0xffFDFDFD))),
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: "/login",
            routes: {
              "/login": (BuildContext context) => LoginPage(),
              "/home": (BuildContext context) => HomePage(),
              "/register": (BuildContext context) => RegisterPage(),
            },
          ),
        );
      }),
    );
  }
}
