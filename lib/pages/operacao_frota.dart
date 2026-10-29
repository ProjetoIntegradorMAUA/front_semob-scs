import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../services/mock_data.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class OperacaoFrotaPage extends StatefulWidget {
  const OperacaoFrotaPage({super.key});

  @override
  State<OperacaoFrotaPage> createState() => _OperacaoFrotaPageState();
}

class _OperacaoFrotaPageState extends State<OperacaoFrotaPage> {
  String _mes = 'Agosto/2026';

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Operação da Frota',
      subtitle: 'Viagens, quilometragem e cumprimento por linha',
      children: [
        _Filtros(
          mes: _mes,
          onChanged: (v) => setState(() => _mes = v),
          // TODO: recarregar os dados do mês selecionado (API / CSV).
          onFiltrar: () {},
        ),
        KpiGrid(children: [
          KpiCard(
              icon: Icons.event_note_outlined,
              color: AppColors.teal,
              value: fmtInt(MockData.viagensProgramadas),
              label: 'Viagens programadas'),
          KpiCard(
              icon: Icons.directions_bus_outlined,
              color: AppColors.blue,
              value: fmtInt(MockData.viagensRealizadas),
              label: 'Viagens realizadas'),
          KpiCard(
              icon: Icons.cancel_outlined,
              color: AppColors.red,
              value: fmtInt(MockData.viagensNaoRealizadas),
              label: 'Não realizadas'),
          KpiCard(
              icon: Icons.speed,
              color: AppColors.green,
              value: fmtPct(MockData.fcv),
              label: 'Cumprimento (FCV)'),
        ]),
        SplitRow(
          main: BarChartCard(
            title: 'Viagens por linha',
            labels: [for (final l in MockData.topLinhas) l.linha],
            values: [for (final l in MockData.topLinhas) l.viagens.toDouble()],
          ),
          side: const LineChartCard(
            title: 'Programadas x realizadas (dias 01–07)',
            labels: MockData.diasLabels,
            series: [
              LineSeries(MockData.viagensProgPorDia, AppColors.orange, 'Programadas'),
              LineSeries(MockData.viagensRealPorDia, AppColors.blue, 'Realizadas'),
            ],
          ),
        ),
        const _FaixasTable(),
      ],
    );
  }
}

class _Filtros extends StatelessWidget {
  final String mes;
  final ValueChanged<String> onChanged;
  final VoidCallback onFiltrar;
  const _Filtros({required this.mes, required this.onChanged, required this.onFiltrar});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Filtros',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: mes,
              decoration: const InputDecoration(
                  labelText: 'Período', border: OutlineInputBorder(), isDense: true),
              items: [
                for (final m in MockData.meses)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
          FilledButton(onPressed: onFiltrar, child: const Text('Filtrar')),
        ],
      ),
    );
  }
}

class _FaixasTable extends StatelessWidget {
  const _FaixasTable();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Cumprimento por faixa horária',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          columns: const [
            DataColumn(label: Text('Faixa')),
            DataColumn(label: Text('Programadas'), numeric: true),
            DataColumn(label: Text('Realizadas'), numeric: true),
            DataColumn(label: Text('FCV'), numeric: true),
          ],
          rows: [
            for (final f in MockData.faixas)
              DataRow(cells: [
                DataCell(Text(f.nome)),
                DataCell(Text(fmtInt(f.programadas))),
                DataCell(Text(fmtInt(f.realizadas))),
                DataCell(Text(fmtPct(f.fcv))),
              ]),
          ],
        ),
      ),
    );
  }
}
