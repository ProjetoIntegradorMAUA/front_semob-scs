import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/common.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  String _periodoPadrao = 'Agosto/2026';
  bool _notificarCriticos = true;
  bool _resumoSemanal = false;

  // SIMULAÇÃO: as preferências ainda não são gravadas em lugar nenhum.
  void _salvar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferências salvas (simulação: ainda não persistem).')),
    );
  }

  Widget _info(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 90,
            child: Text(rotulo,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 13))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Configurações',
      subtitle: 'Preferências do painel e informações do sistema',
      children: [
        SplitRow(
          main: SectionCard(
            title: 'Preferências',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue: _periodoPadrao,
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
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notificar alertas críticos'),
                subtitle: const Text('Avisar quando surgir uma ocorrência crítica'),
                value: _notificarCriticos,
                onChanged: (v) => setState(() => _notificarCriticos = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Resumo semanal por e-mail'),
                subtitle: const Text('Receber o consolidado da semana'),
                value: _resumoSemanal,
                onChanged: (v) => setState(() => _resumoSemanal = v),
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
            ]),
          ),
        ),
      ],
    );
  }
}
