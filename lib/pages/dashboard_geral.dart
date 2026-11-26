import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../services/mock_data.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class DashboardGeralPage extends StatelessWidget {
  const DashboardGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Dashboard de Operação',
      subtitle: 'Agosto de 2026 · São Caetano do Sul',
      children: [
        KpiGrid(children: [
          KpiCard(
              icon: Icons.groups_outlined,
              color: AppColors.teal,
              value: fmtInt(MockData.passTotal),
              label: 'Passageiros no mês'),
          KpiCard(
              icon: Icons.alt_route,
              color: AppColors.blue,
              value: fmtInt(MockData.viagensRealizadas),
              label: 'Viagens realizadas'),
          KpiCard(
              icon: Icons.route_outlined,
              color: AppColors.orange,
              value: '${fmtInt(MockData.kmTotal)} km',
              label: 'Quilometragem total'),
          KpiCard(
              icon: Icons.check_circle_outline,
              color: AppColors.green,
              value: fmtPct(MockData.fcv),
              label: 'Cumprimento de viagens'),
        ]),
        SplitRow(
          main: const LineChartCard(
            title: 'Evolução de passageiros por dia',
            labels: MockData.diasLabels,
            series: [LineSeries(MockData.passPorDia, AppColors.blue)],
          ),
          side: const DonutChartCard(
            title: 'Distribuição de passageiros',
            centerValue: '1,05 mi',
            centerLabel: 'total',
            slices: [
              DonutSlice('Não pagantes', 761870, AppColors.blue),
              DonutSlice('Catraca', 228430, AppColors.teal),
              DonutSlice('Antecipados', 59948, AppColors.orange),
            ],
          ),
        ),
        const SplitRow(main: _TopLinhasTable(), side: _AlertasCard()),
      ],
    );
  }
}

class _TopLinhasTable extends StatelessWidget {
  const _TopLinhasTable();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Linhas com mais viagens',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          columns: const [
            DataColumn(label: Text('Linha')),
            DataColumn(label: Text('Viagens'), numeric: true),
            DataColumn(label: Text('Km'), numeric: true),
          ],
          rows: [
            for (final l in MockData.topLinhas)
              DataRow(cells: [
                DataCell(Text('Linha ${l.linha}')),
                DataCell(Text(fmtInt(l.viagens))),
                DataCell(Text(fmtInt(l.km))),
              ]),
          ],
        ),
      ),
    );
  }
}

class _AlertasCard extends StatelessWidget {
  const _AlertasCard();

  Widget _row(IconData i, Color c, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Alertas',
      child: Column(children: [
        _row(Icons.warning_amber_rounded, AppColors.orange,
            '${MockData.viagensNaoRealizadas} viagens não realizadas no mês'),
        _row(Icons.error_outline, AppColors.red,
            'Crédito circulante negativo em 01/08 e 02/08'),
        _row(Icons.check_circle_outline, AppColors.green,
            'Cumprimento de ${fmtPct(MockData.fcv)}'),
      ]),
    );
  }
}
