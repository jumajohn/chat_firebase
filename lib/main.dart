import 'package:flutter/material.dart';
import 'pages/LoginPage.dart';
import 'pages/HomePage.dart';
import 'pages/AccountSettingsPage.dart';
import 'pages/ChatPage.dart';
import 'package:firebase_core/firebase_core.dart';
import './pages/ImageView.dart';
import './pages/UsersPage.dart';

import 'package:provider/provider.dart';
import './provider/DataProvider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => DataProvider())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: 'home',
        routes: {
          'home': (context) => const LoginPage(),
          HomePage.routeName: (context) => const HomePage(),
          AccountSettingsPage.routeName: (context) =>
              const AccountSettingsPage(),
          ChatPage.routeName: (context) => const ChatPage(),
          ImageView.routeName: (context) => ImageView(),
          UsersPage.routeName: (context) => UsersPage(),
        },
      ),
    );
  }
}
