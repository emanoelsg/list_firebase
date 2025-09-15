// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:list_firebase/app/core/bindings/initial_binding.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:list_firebase/firebase_options.dart';

// App imports

import 'package:list_firebase/app/features/auth/presentation/pages/splash/splash_page.dart'; // Splash Page refatorada
import 'package:list_firebase/app/core/utils/theme/theme.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 tz.initializeTimeZones();

 // Injeção de dependências global, uma única vez
 InitialBindings().dependencies();

runApp(const ListTarefa());
}

class ListTarefa extends StatelessWidget {
 const ListTarefa({super.key});

 @override
 Widget build(BuildContext context) {
 return GetMaterialApp(
 theme: TAppTheme.lightTheme,
 darkTheme: TAppTheme.darkTheme,
themeMode: ThemeMode.system,
 home: const SplashPage(), // Primeira tela
 debugShowCheckedModeBanner: false,
 );
 }
}