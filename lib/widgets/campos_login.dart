import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

/// Rótulo + campo de texto
class CampoTexto extends StatelessWidget {
  final String rotulo;
  final String dica;
  final TextEditingController controller;
  final bool senha;
  final TextInputType? teclado;
  final int? limite;
  final List<TextInputFormatter>? formatadores;
  final VoidCallback? aoEnviar;

  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.dica,
    required this.controller,
    this.senha = false,
    this.teclado,
    this.limite,
    this.formatadores,
    this.aoEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: TextStyle(color: context.cores.muted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: senha,
          keyboardType: teclado,
          maxLength: limite,
          inputFormatters: formatadores,
          onSubmitted: aoEnviar == null ? null : (_) => aoEnviar!(),
          decoration: InputDecoration(
            hintText: dica,
            counterText: '',
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// Botão azul de largura total
class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback aoClicar;

  const BotaoPrincipal({super.key, required this.texto, required this.aoClicar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: aoClicar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: Text(texto),
      ),
    );
  }
}

/// Texto azul clicável
class LinkTexto extends StatelessWidget {
  final String texto;
  final VoidCallback aoClicar;

  const LinkTexto({super.key, required this.texto, required this.aoClicar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoClicar,
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    );
  }
}

/// Card branco centralizado com título e subtítulo
class CardFormulario extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Widget> filhos;

  const CardFormulario({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.filhos,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    return Center(
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
                titulo,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cores.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitulo,
                style: TextStyle(fontSize: 12, color: cores.muted),
              ),
              const SizedBox(height: 32),
              ...filhos,
            ],
          ),
        ),
      ),
    );
  }
}