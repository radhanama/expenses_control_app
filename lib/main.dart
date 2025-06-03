import 'dart:io';

import 'package:expenses_control/data/usuario_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'databases/database.dart';
import 'services/authentication_service.dart';
import 'view/usuario_view.dart';
import 'view_model/usuario_view_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit(); // loads native sqlite3
    databaseFactory = databaseFactoryFfi;
  }
  

  // 1) open (or create) the SQLite file
  final db = await openAppDatabase();

  // 2) build the dependency graph
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => UsuarioRepository(db)),
        Provider(
          create: (ctx) => AuthenticationService(
            ctx.read<UsuarioRepository>(),
            secureStorage: const FlutterSecureStorage(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => UsuarioViewModel(
            repo: ctx.read<UsuarioRepository>(),
            auth: ctx.read<AuthenticationService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UsuarioView(),
    );
  }
}
