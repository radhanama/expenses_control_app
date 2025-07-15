import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../view_model/gasto_view_model.dart';
import 'gasto_view.dart';

class NfceWebView extends StatefulWidget {
  final String url;
  const NfceWebView({super.key, required this.url});

  @override
  State<NfceWebView> createState() => _NfceWebViewState();
}

class _NfceWebViewState extends State<NfceWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (url) {
          setState(() {
            _loading = false;
          });
        }),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _importar() async {
    final encodedHtml = await _controller.runJavaScriptReturningResult(
        "JSON.stringify(document.documentElement.outerHTML)");
    final html = jsonDecode(encodedHtml as String) as String;
    final vm = context.read<GastoViewModel>();
    final ok = await vm.processarHtml(html);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GastoView(dadosIniciais: vm.scrapedData)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Erro ao processar nota')),
      );
    }
  }

  Future<void> _abrirNoNavegador() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o navegador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota Fiscal'),
        actions: [
          IconButton(onPressed: _abrirNoNavegador, icon: const Icon(Icons.open_in_browser)),
          IconButton(onPressed: _importar, icon: const Icon(Icons.check)),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
