import 'package:expenses_control_app/view/gasto_view.dart';
import 'package:expenses_control_app/view/gemini_text_view.dart';
import 'package:expenses_control_app/view/simple_text_view.dart';
import 'package:expenses_control_app/view/nfce_webview.dart';
import 'package:expenses_control_app/view_model/gasto_view_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../view_model/usuario_view_model.dart';
import 'package:expenses_control/models/usuario.dart';
import 'extrato_import_view.dart';

class AdicionarGastoView extends StatefulWidget {
  @override
  State<AdicionarGastoView> createState() => _AdicionarGastoViewState();
}

class _AdicionarGastoViewState extends State<AdicionarGastoView> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  // Variáveis para controlar o estado da UI localmente
  TorchState _torchState = TorchState.off;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    // Pega o primeiro código de barras detectado
    final String? code = capture.barcodes.first.rawValue;

    if (code != null && !_isProcessing && mounted) {
      setState(() {
        _isProcessing = true;
      });
      // A câmera para automaticamente ao detectar, não precisa pausar manualmente

      final viewModel = context.read<GastoViewModel>();
      final success = await viewModel.processarQRCode(code);

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GastoView(dadosIniciais: viewModel.scrapedData),
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      } else if (mounted && code.startsWith('https://')) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NfceWebView(url: code)),
        );
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Ocorreu um erro desconhecido.')),
        );
        await Future.delayed(const Duration(seconds: 3));
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera);
    if (foto == null) return;
    final vm = context.read<GastoViewModel>();
    final sucesso = await vm.processarImagem(foto.path);
    if (!mounted) return;
    if (sucesso) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GastoView(dadosIniciais: vm.scrapedData)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Erro desconhecido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GastoViewModel>(
      builder: (context, viewModel, child) {
        final plano =
            context.watch<UsuarioViewModel>().usuarioLogado?.plano ??
                PlanoUsuario.gratuito;
        final isGold = plano == PlanoUsuario.ouro;
        final isFree = plano == PlanoUsuario.gratuito;
        return Scaffold(
          appBar: AppBar(
            title: Text('Adicionar Despesa'),
            centerTitle: true,
            actions: [ // Controles da câmera
              IconButton(
                icon: Icon(
                  _torchState == TorchState.off
                      ? Icons.flash_off
                      : Icons.flash_on,
                  color: _torchState == TorchState.off ? Colors.grey : Colors.yellow,
                ),
                iconSize: 32.0,
                onPressed: () async {
                  await cameraController.toggleTorch();
                  // Atualiza o estado local para redesenhar o ícone
                  setState(() {
                      _torchState = _torchState == TorchState.off ? TorchState.on : TorchState.off;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                    _cameraFacing == CameraFacing.back
                        ? Icons.camera_rear
                        : Icons.camera_front),
                iconSize: 32.0,
                onPressed: () async {
                  await cameraController.switchCamera();
                  // Atualiza o estado local para redesenhar o ícone
                  setState(() {
                      _cameraFacing = _cameraFacing == CameraFacing.back ? CameraFacing.front : CameraFacing.back;
                  });
                },
              ),
            ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isFree) ...[
                    Text('Aponte a câmera para o QR Code',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: cameraController,
                          onDetect: _handleBarcode,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.text_fields),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => isFree
                                ? const SimpleTextView()
                                : const GeminiTextView()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 1.5),
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text('Inserir por Texto',
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExtratoImportView(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blueGrey, width: 1.5),
                      foregroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: const Text('Importar Extrato',
                        style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  if (isGold) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      onPressed: _tirarFoto,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange, width: 1.5),
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: const Text('Inserir por Foto',
                          style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GastoView()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue, width: 1.5),
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: const Text('Inserir Manualmente',
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              // Indicador de Carregamento
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Processando nota...", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}