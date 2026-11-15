import 'package:flutter/material.dart';
import '../services/api_config.dart';
import '../services/mock_data.dart';
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
        SplitRow(
          main: SectionCard(
            title: 'Preferências',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: _periodoPadrao,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Período padrão',
                      border: OutlineInputBorder(),
                      isDense: true),
                  items: [
                    for (final m in MockData.meses)
                      DropdownMenuItem(value: m, child: Text(m)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _periodoPadrao = v);
                  },
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
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Notificar alertas críticos'),
                  subtitle: const Text('Avisar quando surgir uma ocorrência crítica'),
                  value: _notificarCriticos,
                  onChanged: (v) => setState(() => _notificarCriticos = v),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Resumo semanal por e-mail'),
                  subtitle: const Text('Receber o consolidado da semana'),
                  value: _resumoSemanal,
                  onChanged: (v) => setState(() => _resumoSemanal = v),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _salvar, child: const Text('Salvar preferências')),
            ]),
          ),
          side: SectionCard(
            title: 'Sobre o sistema',
            child: Column(children: [
              _info('Sistema', 'SEMOB-SCS'),
              _info('Versão', '0.1.0 (protótipo)'),
              _info('Dados', 'Julho a Setembro/2026'),
              _info('Fonte', 'Relatórios de utilização do transporte municipal'),
              _info('Modo', ApiConfig.sourceLabel),
              _info('API', ApiConfig.baseUrl),
            ]),
          ),
        ),
      ],
    );
  }
}
