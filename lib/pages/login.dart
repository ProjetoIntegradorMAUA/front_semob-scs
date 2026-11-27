import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void entrar() {
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o e-mail e a senha')),
      );
      return;
    }
    widget.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: Row(
        children: [
          // Lado esquerdo (só aparece em tela grande)
          if (desktop)
            Expanded(
              flex: 45,
              child: Container(
                padding: const EdgeInsets.all(54),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.sidebarBottom, AppColors.sidebarTop],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SEMOB-SCS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Dashboard de Operação de Transporte',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset('assets/images/bus.png'),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestão inteligente da mobilidade urbana',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'São Caetano do Sul • Secretaria de Mobilidade Urbana',
                          style: TextStyle(fontSize: 11, color: Colors.white60),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Lado direito (formulário)
          Expanded(
            flex: 55,
            child: Center(
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
                        'Bem-vindo',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: cores.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Acesse o painel de operação de transporte',
                        style: TextStyle(fontSize: 12, color: cores.muted),
                      ),
                      const SizedBox(height: 32),
                      Text('E-mail', style: TextStyle(color: cores.muted)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'seu@email.com',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Senha', style: TextStyle(color: cores.muted)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: senhaController,
                        obscureText: true,
                        onSubmitted: (_) => entrar(),
                        decoration: const InputDecoration(
                          hintText: 'Digite sua senha',
                          border: OutlineInputBorder(),
                        ),
                      ),      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: entrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}