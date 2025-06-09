import 'package:expenses_control_app/view/gasto_view.dart';
import 'package:expenses_control_app/view_model/gasto_view_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Importe o novo pacote
import 'package:provider/provider.dart';

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
        // Navega para a tela de gasto com os dados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GastoView(dadosIniciais: viewModel.scrapedData),
          ),
        ).then((_) {
          // Quando voltar da tela de cadastro, reinicia o processamento
          if(mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      } else {
        // Se falhar, exibe o erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.errorMessage ?? 'Ocorreu um erro desconhecido.')),
          );
          await Future.delayed(const Duration(seconds: 3)); // Delay para o usuário ler o erro
          setState(() {
            _isProcessing = false; // Permite nova tentativa
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GastoViewModel>(
      builder: (context, viewModel, child) {
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
                  Text("Aponte a câmera para o QR Code", style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 20),
                  // Área do Scanner
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
                  SizedBox(height: 30),
                  // Botão de Inserção Manual
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GastoView()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 1.5),
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text('Inserir Manualmente', style: TextStyle(fontSize: 18)),
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