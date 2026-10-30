import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../services/alertas_service.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../widgets/common.dart';

Color _corGravidade(Gravidade g) => switch (g) {
      Gravidade.critico => AppColors.red,
      Gravidade.atencao => AppColors.orange,
      Gravidade.baixo => AppColors.teal,
    };

Color _corStatus(StatusAlerta s) => switch (s) {
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
  final List<Alerta> _todos = AlertasService.listar();
  Gravidade? _filtro; // null = todos
  int _visiveis = 10;

  int _conta(Gravidade g) => _todos.where((a) => a.gravidade == g).length;

  void _filtrar(Gravidade? g) => setState(() {
        _filtro = g;
        _visiveis = 10;
      });

  @override
  Widget build(BuildContext context) {
    final filtrados =
        _filtro == null ? _todos : _todos.where((a) => a.gravidade == _filtro).toList();
    final mostrados = filtrados.take(_visiveis).toList();

    return PageScaffold(
      title: 'Alertas Operacionais',
      subtitle: 'Monitoramento de falhas e ocorrências da operação · Ago–Set/2026',
      children: [
        KpiGrid(children: [
          KpiCard(
              icon: Icons.error_outline,
              color: AppColors.red,
              value: '${_conta(Gravidade.critico)}',
              label: 'Críticos',
              hint: 'Requer atenção',
              hintColor: AppColors.red),
          KpiCard(
              icon: Icons.warning_amber_rounded,
              color: AppColors.orange,
              value: '${_conta(Gravidade.atencao)}',
              label: 'Atenção',
              hint: 'Em análise',
              hintColor: AppColors.orange),
          KpiCard(
              icon: Icons.check_circle_outline,
              color: AppColors.teal,
              value: '${_conta(Gravidade.baixo)}',
              label: 'Baixa gravidade',
              hint: 'Resolvidos',
              hintColor: AppColors.teal),
          KpiCard(
              icon: Icons.notifications_none,
              color: AppColors.blue,
              value: '${_todos.length}',
              label: 'Total de ocorrências',
              hint: 'Agosto e 1ª quinzena de setembro'),
        ]),
        SplitRow(
          main: SectionCard(
            title: 'Lista de ocorrências',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                ChoiceChip(
                    label: const Text('Todos'),
                    selected: _filtro == null,
                    onSelected: (_) => _filtrar(null)),
                for (final g in Gravidade.values)
                  ChoiceChip(
                      label: Text('${g.rotulo} (${_conta(g)})'),
                      selected: _filtro == g,
                      onSelected: (_) => _filtrar(g)),
              ]),
              const SizedBox(height: 16),
              const Text('Ocorrências recentes',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 36,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 64,
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Data')),
                    DataColumn(label: Text('Linha')),
                    DataColumn(label: Text('Ocorrência')),
                    DataColumn(label: Text('Gravidade')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: [
                    for (final a in mostrados)
                      DataRow(cells: [
                        DataCell(Text(fmtDiaMes(a.data))),
                        DataCell(Text(a.linha)),
                        DataCell(SizedBox(
                          width: 280,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.tipo,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(a.descricao,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.muted)),
                            ],
                          ),
                        )),
                        DataCell(Text(a.gravidade.rotulo,
                            style: TextStyle(
                                color: _corGravidade(a.gravidade),
                                fontWeight: FontWeight.w600))),
                        DataCell(Text(a.status.rotulo,
                            style: TextStyle(
                                color: _corStatus(a.status),
                                fontWeight: FontWeight.w600))),
                      ]),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text('Mostrando ${mostrados.length} de ${filtrados.length}',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
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
              for (final a in _todos.take(6))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _corGravidade(a.gravidade).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${a.id} · ${a.tipo}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${fmtDiaMes(a.data)} · ${a.gravidade.rotulo}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _corGravidade(a.gravidade))),
                  ]),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}
