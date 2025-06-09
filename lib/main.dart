import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Imports do projeto que não dependem do DB
import 'package:expenses_control_app/view/main_view.dart';
import 'package:expenses_control_app/services/web_scrapping_service.dart';
import 'package:expenses_control_app/view_model/gasto_view_model.dart';

// Imports relacionados ao banco de dados (comentados temporariamente)
// import 'package:expenses_control_framework/expenses_control_framework.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:expenses_control_app/services/authentication_service.dart';
// import 'package:expenses_control_app/view_model/usuario_view_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // A inicialização do FFI para desktop e do banco de dados foi desativada temporariamente.
  // if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
  //   sqfliteFfiInit();
  //   databaseFactory = databaseFactoryFfi;
  // }
  // final db = await openAppDatabase();

  runApp(
    MultiProvider(
      providers: [
        // =====================================================================
        // Providers que dependem do banco de dados (desativados temporariamente)
        // Para reativar, descomente estas linhas, os imports acima e a
        // inicialização do 'db'.
        // =====================================================================
        // Provider(create: (_) => UsuarioRepository(db)),
        // Provider(
        //   create: (ctx) => AuthenticationService(
        //     ctx.read<UsuarioRepository>(),
        //     secureStorage: const FlutterSecureStorage(),
        //   ),
        // ),
        // ChangeNotifierProvider(
        //   create: (ctx) => UsuarioViewModel(
        //     repo: ctx.read<UsuarioRepository>(),
        //     auth: ctx.read<AuthenticationService>(),
        //   ),
        // ),

        // =====================================================================
        // Providers independentes que podem ser testados sem o banco de dados
        // =====================================================================
        Provider(create: (_) => WebScrapingService()),
        ChangeNotifierProvider(
          create: (ctx) => GastoViewModel(
            webScrapingService: ctx.read<WebScrapingService>(),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // A tela inicial continua a mesma, mas funcionalidades que dependem
      // dos providers de usuário/autenticação (como login) não irão funcionar.
      home: MainView(),
    );
  }
}
