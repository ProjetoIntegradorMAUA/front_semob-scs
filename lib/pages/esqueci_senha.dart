import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage({super.key});

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void enviar() {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o seu e-mail')),
      );
      return;
    }

    // Aqui depois entra a chamada ao backend para enviar o e-mail
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviamos as instruções para o seu e-mail')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 456,
            padding: const EdgeInsets.all(48),
            decoration: cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cores.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Informe o seu e-mail e enviaremos as instruções para criar uma nova senha',
                  style: TextStyle(fontSize: 12, color: cores.muted),
                ),
                const SizedBox(height: 32),
                Text('E-mail', style: TextStyle(color: cores.muted)),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  onSubmitted: (_) => enviar(),
                  decoration: const InputDecoration(
                    hintText: 'seu@email.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: enviar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Enviar instruções'),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Voltar para o login',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}