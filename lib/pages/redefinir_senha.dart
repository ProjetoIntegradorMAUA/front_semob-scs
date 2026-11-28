import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navbar/widgets/campos_login.dart';

class RedefinirSenhaPage extends StatefulWidget {
  final String email;

  const RedefinirSenhaPage({super.key, required this.email});

  @override
  State<RedefinirSenhaPage> createState() => _RedefinirSenhaPageState();
}

class _RedefinirSenhaPageState extends State<RedefinirSenhaPage> {
  final codigoController = TextEditingController();
  final novaSenhaController = TextEditingController();
  final confirmarController = TextEditingController();

  @override
  void dispose() {
    codigoController.dispose();
    novaSenhaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  void mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  void voltarParaLogin() {
    Navigator.popUntil(context, (rota) => rota.isFirst);
  }

  void salvar() {
    if (codigoController.text.length != 6) {
      mostrarAviso('O código deve ter 6 dígitos');
      return;
    }
    if (novaSenhaController.text.isEmpty) {
      mostrarAviso('Informe a nova senha');
      return;
    }
    if (novaSenhaController.text != confirmarController.text) {
      mostrarAviso('As senhas não são iguais');
      return;
    }

    // Aqui depois entra a chamada ao backend para trocar a senha
    mostrarAviso('Senha alterada com sucesso');
    voltarParaLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardFormulario(
        titulo: 'Redefinir senha',
        subtitulo: 'Digite o código de 6 dígitos enviado para ${widget.email}',
        filhos: [
          CampoTexto(
            rotulo: 'Código',
            dica: '000000',
            controller: codigoController,
            teclado: TextInputType.number,
            limite: 6,
            formatadores: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),
          CampoTexto(
            rotulo: 'Nova senha',
            dica: 'Digite a nova senha',
            controller: novaSenhaController,
            senha: true,
          ),
          const SizedBox(height: 20),
          CampoTexto(
            rotulo: 'Confirmar nova senha',
            dica: 'Repita a nova senha',
            controller: confirmarController,
            senha: true,
            aoEnviar: salvar,
          ),
          const SizedBox(height: 24),
          BotaoPrincipal(texto: 'Salvar nova senha', aoClicar: salvar),
          const SizedBox(height: 16),
          LinkTexto(texto: 'Voltar para o login', aoClicar: voltarParaLogin),
        ],
      ),
    );
  }
}