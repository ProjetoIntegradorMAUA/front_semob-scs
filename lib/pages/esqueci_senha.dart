import 'package:flutter/material.dart';
import 'package:navbar/widgets/campos_login.dart';
import 'redefinir_senha.dart';

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

    // Aqui depois entra a chamada ao backend para enviar o código por e-mail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RedefinirSenhaPage(email: emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardFormulario(
        titulo: 'Esqueceu a senha?',
        subtitulo:
            'Informe o seu e-mail e enviaremos um código de 6 dígitos para criar uma nova senha',
        filhos: [
          CampoTexto(
            rotulo: 'E-mail',
            dica: 'seu@email.com',
            controller: emailController,
            aoEnviar: enviar,
          ),
          const SizedBox(height: 24),
          BotaoPrincipal(texto: 'Enviar código', aoClicar: enviar),
          const SizedBox(height: 16),
          LinkTexto(
            texto: 'Voltar para o login',
            aoClicar: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}