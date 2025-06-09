import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Imports do projeto que não dependem do DB
import 'package:expenses_control_app/view/main_view.dart';
import 'package:expenses_control_app/services/web_scrapping_service.dart';
import 'package:expenses_control_app/view_model/gasto_view_model.dart';
import 'package:expenses_control_app/view_model/extrato_view_model.dart';
import 'package:expenses_control_app/view_model/dashboard_view_model.dart';
import 'package:expenses_control_app/services/statistica_service.dart';
import 'databases/database.dart';
import 'package:expenses_control/data/usuario_repository.dart';
import 'package:expenses_control/data/gasto_repository.dart';
import 'services/authentication_service.dart';
import 'view_model/usuario_view_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Imports relacionados ao banco de dados (comentados temporariamente)
// import 'package:expenses_control_framework/expenses_control_framework.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:expenses_control_app/services/authentication_service.dart';
// import 'package:expenses_control_app/view_model/usuario_view_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final db = await openAppDatabase();

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
        Provider(create: (_) => GastoRepository(db)),
        Provider(create: (_) => EstatisticaService()),
        Provider(create: (_) => WebScrapingService()),
        ChangeNotifierProvider(
          create: (ctx) => GastoViewModel(
            webScrapingService: ctx.read<WebScrapingService>(),
            repo: ctx.read<GastoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ExtratoViewModel(ctx.read<GastoRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DashboardViewModel(
            ctx.read<GastoRepository>(),
            ctx.read<EstatisticaService>(),
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
      home: MainView(),
    );
  }
}
