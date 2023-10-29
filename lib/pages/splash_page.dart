import 'package:firebase_core/firebase_core.dart';
import '../services/cloud_storage_service.dart';
import '../services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/database_service.dart';
import '../services/navigation_services.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashPage({Key? key, required this.onComplete}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    _setup().then(
          (_) => widget.onComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flash Chat",
debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xff4D81F7),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white,)
        ),
      ),
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    _registerServices();
  }

  void _registerServices() {
    GetIt.instance.registerSingleton<NavigationService>(NavigationService());
    GetIt.instance.registerSingleton<MediaService>(MediaService());
    GetIt.instance
        .registerSingleton<CloudStorageService>(CloudStorageService());
    GetIt.instance.registerSingleton<DatabaseService>(DatabaseService());
  }
}
