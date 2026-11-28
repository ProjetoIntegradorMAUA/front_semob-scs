import 'package:flutter/material.dart';
import 'package:navbar/widgets/campos_login.dart';
import '../widgets/app_theme.dart';
import 'esqueci_senha.dart';

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
            child: CardFormulario(
              titulo: 'Bem-vindo',
              subtitulo: 'Acesse o painel de operação de transporte',
              filhos: [
                CampoTexto(
                  rotulo: 'E-mail',
                  dica: 'seu@email.com',
                  controller: emailController,
                ),
                const SizedBox(height: 20),
                CampoTexto(
                  rotulo: 'Senha',
                  dica: 'Digite sua senha',
                  controller: senhaController,
                  senha: true,
                  aoEnviar: entrar,
                ),
                const SizedBox(height: 24),
                BotaoPrincipal(texto: 'Entrar', aoClicar: entrar),
                const SizedBox(height: 16),
                LinkTexto(
                  texto: 'Esqueci minha senha',
                  aoClicar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EsqueciSenhaPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}