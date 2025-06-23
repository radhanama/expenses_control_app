import 'dart:io';

import 'package:expenses_control/models/data/gasto_repository.dart';
import 'package:expenses_control/models/data/usuario_repository.dart';
import 'package:expenses_control_app/view_model/smart_analysis_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:expenses_control_app/view/main_view.dart';
import 'package:expenses_control_app/models/services/web_scrapping_service.dart';
import 'package:expenses_control_app/models/services/smart_analysis_service.dart';
import 'package:expenses_control_app/view_model/gasto_view_model.dart';
import 'package:expenses_control_app/view_model/extrato_view_model.dart';
import 'package:expenses_control_app/view_model/dashboard_view_model.dart';
import 'package:expenses_control_app/models/services/statistica_service.dart';
import 'models/databases/database.dart';
import 'models/data/categoria_repository.dart';
import 'models/services/authentication_service.dart';
import 'view_model/usuario_view_model.dart';
import 'view_model/categoria_view_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        Provider(create: (_) => CategoriaRepository(db)),
        ChangeNotifierProvider(
          create: (ctx) => CategoriaViewModel(ctx.read<CategoriaRepository>())
            ..carregarCategorias(),
        ),
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
        Provider(create: (_) => SmartAnalysisService()),
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
        ChangeNotifierProvider(
          create: (ctx) => SmartAnalysisViewModel(
            ctx.read<GastoRepository>(),
            ctx.read<CategoriaRepository>(),
            ctx.read<SmartAnalysisService>(),
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
