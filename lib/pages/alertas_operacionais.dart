import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../services/alertas_service.dart';
import '../services/dados_service.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/tabela.dart';

Color corGravidade(Gravidade g) => switch (g) {
      Gravidade.critico => AppColors.red,
      Gravidade.atencao => AppColors.orange,
      Gravidade.baixo => AppColors.teal,
    };

Color corStatus(StatusAlerta s) => switch (s) {
      StatusAlerta.aberto => AppColors.red,
      StatusAlerta.emAnalise => AppColors.orange,
      StatusAlerta.resolvido => AppColors.green,
    };

class AlertasOperacionaisPage extends StatefulWidget {
  const AlertasOperacionaisPage({super.key});

  @override
  State<AlertasOperacionaisPage> createState() => _AlertasOperacionaisPageState();
}

class _AlertasOperacionaisPageState extends State<AlertasOperacionaisPage> {
  static const _todosPeriodos = 'Todos os períodos';

  final List<Alerta> _todos = AlertasService.listar();
  String _periodo = _todosPeriodos;
  Gravidade? _filtro; // null = todas as gravidades
  int _visiveis = 10;

  List<Alerta> get _doPeriodo {
    if (_periodo == _todosPeriodos) return _todos;
    final mes = DadosService.porRotulo(_periodo).mes;
    return _todos.where((a) => a.data.month == mes).toList();
  }

  int _conta(List<Alerta> lista, Gravidade g) =>
      lista.where((a) => a.gravidade == g).length;

  void _mudarFiltro({String? periodo, Gravidade? gravidade, bool limparGravidade = false}) {
    setState(() {
      if (periodo != null) _periodo = periodo;
      if (gravidade != null || limparGravidade) _filtro = gravidade;
      _visiveis = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final periodo = _doPeriodo;
    final filtrados =
        _filtro == null ? periodo : periodo.where((a) => a.gravidade == _filtro).toList();
    final mostrados = filtrados.take(_visiveis).toList();

    return PageScaffold(
      title: 'Alertas Operacionais',
      subtitle: 'Monitoramento de falhas e ocorrências da operação · Jul a Set/2026',
      children: [
        KpiGrid(children: [
          KpiCard(
              icon: Icons.error_outline,
              color: AppColors.red,
              value: '${_conta(periodo, Gravidade.critico)}',
              label: 'Críticos',
              hint: 'Requer atenção',
              hintColor: AppColors.red),
          KpiCard(
              icon: Icons.warning_amber_rounded,
              color: AppColors.orange,
              value: '${_conta(periodo, Gravidade.atencao)}',
              label: 'Atenção',
              hint: 'Em análise',
              hintColor: AppColors.orange),
          KpiCard(
              icon: Icons.check_circle_outline,
              color: AppColors.teal,
              value: '${_conta(periodo, Gravidade.baixo)}',
              label: 'Baixa gravidade',
              hint: 'Resolvidos',
              hintColor: AppColors.teal),
          KpiCard(
              icon: Icons.notifications_none,
              color: AppColors.blue,
              value: '${periodo.length}',
              label: 'Total de ocorrências',
              hint: _periodo == _todosPeriodos ? 'Julho a setembro' : _periodo),
        ]),
        SplitRow(
          main: SectionCard(
            title: 'Lista de ocorrências',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      initialValue: _periodo,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: 'Período',
                          border: OutlineInputBorder(),
                          isDense: true),
                      items: [
                        for (final o in [_todosPeriodos, ...DadosService.rotulos])
                          DropdownMenuItem(value: o, child: Text(o)),
                      ],
                      onChanged: (v) {
                        if (v != null) _mudarFiltro(periodo: v);
                      },
                    ),
                  ),
                  ChoiceChip(
                      label: const Text('Todas'),
                      selected: _filtro == null,
                      onSelected: (_) => _mudarFiltro(limparGravidade: true)),
                  for (final g in Gravidade.values)
                    ChoiceChip(
                        label: Text('${g.rotulo} (${_conta(periodo, g)})'),
                        selected: _filtro == g,
                        onSelected: (_) => _mudarFiltro(gravidade: g)),
                ],
              ),
              const SizedBox(height: 16),
              TabelaCheia(
                vazio: 'Nenhuma ocorrência para este filtro.',
                colunas: const [
                  TabCol('Data', flex: 1, largMin: 60),
                  TabCol('Linha', flex: 3, largMin: 130),
                  TabCol('Ocorrência', flex: 5, largMin: 220),
                  TabCol('Gravidade', flex: 2, largMin: 90),
                  TabCol('Status', flex: 2, largMin: 100),
                ],
                linhas: [
                  for (final a in mostrados)
                    [
                      Text(fmtDiaMes(a.data)),
                      celulaLinha(context, a.linha),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.tipo, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(a.descricao,
                              style: TextStyle(fontSize: 11, color: context.cores.muted)),
                        ],
                      ),
                      Pilula(a.gravidade.rotulo, corGravidade(a.gravidade)),
                      Pilula(a.status.rotulo, corStatus(a.status)),
                    ],
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Text('Mostrando ${mostrados.length} de ${filtrados.length}',
                    style: TextStyle(fontSize: 12, color: context.cores.muted)),
                const Spacer(),
                if (mostrados.length < filtrados.length)
                  TextButton(
                      onPressed: () => setState(() => _visiveis += 10),
                      child: const Text('Ver mais')),
              ]),
            ]),
          ),
          side: SectionCard(
            title: 'Histórico de alertas',
            child: Column(children: [
              if (periodo.isEmpty)
                Text('Sem alertas no período.', style: TextStyle(color: context.cores.muted)),
              for (final a in periodo.take(8))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: corGravidade(a.gravidade).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.cores.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${a.id} · ${a.tipo}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                        '${fmtDiaMes(a.data)} · ${a.linha == AlertasService.todas ? 'Todas as linhas' : 'Linha ${a.linha}'}',
                        style: TextStyle(fontSize: 11, color: context.cores.muted)),
                    const SizedBox(height: 6),
                    Pilula(a.gravidade.rotulo, corGravidade(a.gravidade)),
                  ]),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}
