import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/usuario_view_model.dart';

/// Tela de autenticação (login & registro rápido)
/// -----------------------------------------------------------------------------
/// - ViewModel: [UsuarioViewModel] (via Provider)
/// - Mostra dois `TextFormField` (e-mail, senha) e botões de *Login* e *Registrar*
/// - Exibe estado de carregamento e mensagens de erro vindas do ViewModel
class UsuarioView extends StatefulWidget {
  const UsuarioView({Key? key}) : super(key: key);

  @override
  State<UsuarioView> createState() => _UsuarioViewState();
}

class _UsuarioViewState extends State<UsuarioView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Consumer<UsuarioViewModel>(
      builder: (context, vm, _) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bem-vindo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'E-mail inválido',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaCtrl,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 32),
              if (vm.errorMessage != null) ...[
                Text(vm.errorMessage!,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          vm.loading ? null : () => _onLoginPressed(context),
                      child: vm.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed:
                    vm.loading ? null : () => _onRegisterPressed(context),
                child: const Text('Registrar-se'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onLoginPressed(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<UsuarioViewModel>();
    await vm.login(_emailCtrl.text.trim(), _senhaCtrl.text);
  }

  void _onRegisterPressed(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<UsuarioViewModel>();
    await vm.registrar(_emailCtrl.text.trim(), _senhaCtrl.text, nome: '');
  }
}
