import 'package:flutter/material.dart';
import '../services/perfil_service.dart';
import '../services/tema_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _perfil = PerfilService.instance;
  final _tema = TemaService.instance;

  late final TextEditingController _nome = TextEditingController(text: _perfil.nome);
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _confirmacao = TextEditingController();

  bool _ocultar = true;
  String? _erroNome;
  String? _erroSenha;

  @override
  void dispose() {
    _nome.dispose();
    _atual.dispose();
    _nova.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  void _aviso(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  void _salvarNome() {
    final erro = _perfil.alterarNome(_nome.text);
    setState(() => _erroNome = erro);
    if (erro == null) _aviso('Nome atualizado.');
  }

  void _salvarSenha() {
    final erro = _perfil.alterarSenha(
      atual: _atual.text,
      nova: _nova.text,
      confirmacao: _confirmacao.text,
    );
    setState(() => _erroSenha = erro);
    if (erro == null) {
      _atual.clear();
      _nova.clear();
      _confirmacao.clear();
      _aviso('Senha alterada.');
    }
  }

  Widget _limitado(Widget filho) => Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: filho,
        ),
      );

  Widget _campoSenha(String rotulo, TextEditingController controller, Key chave) {
    return TextField(
      key: chave,
      controller: controller,
      obscureText: _ocultar,
      decoration: InputDecoration(
        labelText: rotulo,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: IconButton(
          tooltip: _ocultar ? 'Mostrar senhas' : 'Ocultar senhas',
          icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _ocultar = !_ocultar),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Configurações',
      subtitle: 'Tema do sistema e dados do seu perfil',
      children: [
        // ---------- Aparência ----------
        _limitado(SectionCard(
          title: 'Aparência',
          child: ListenableBuilder(
            listenable: _tema,
            builder: (context, _) => SwitchListTile(
              key: const Key('switch-tema'),
              contentPadding: EdgeInsets.zero,
              secondary: Icon(_tema.escuro ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
              title: const Text('Tema escuro'),
              subtitle: Text(_tema.escuro ? 'Tema escuro ativado' : 'Tema claro ativado'),
              value: _tema.escuro,
              onChanged: _tema.definirEscuro,
            ),
          ),
        )),

        // ---------- Nome ----------
        _limitado(SectionCard(
          title: 'Perfil',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ListenableBuilder(
              listenable: _perfil,
              builder: (context, _) => Row(children: [
                CircleAvatar(
                  child: Text(_perfil.nome.isEmpty ? '?' : _perfil.nome[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_perfil.nome,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.cores.text)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('campo-nome'),
              controller: _nome,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _salvarNome(),
              decoration: InputDecoration(
                labelText: 'Nome',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _erroNome,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('botao-salvar-nome'),
              onPressed: _salvarNome,
              child: const Text('Salvar nome'),
            ),
          ]),
        )),

        // ---------- Senha ----------
        _limitado(SectionCard(
          title: 'Alterar senha',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _campoSenha('Senha atual', _atual, const Key('campo-senha-atual')),
            const SizedBox(height: 12),
            _campoSenha('Nova senha', _nova, const Key('campo-senha-nova')),
            const SizedBox(height: 12),
            _campoSenha('Confirmar nova senha', _confirmacao, const Key('campo-senha-confirmacao')),
            if (_erroSenha != null) ...[
              const SizedBox(height: 12),
              Text(_erroSenha!, style: const TextStyle(color: AppColors.red)),
            ],
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('botao-alterar-senha'),
              onPressed: _salvarSenha,
              child: const Text('Alterar senha'),
            ),
            const SizedBox(height: 12),
            // Dica do protótipo — apague quando houver login real.
            Text('Protótipo: a senha inicial é ${PerfilService.senhaInicial}.',
                style: TextStyle(fontSize: 12, color: context.cores.muted)),
          ]),
        )),
      ],
    );
  }
}
