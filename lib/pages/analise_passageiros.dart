import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../services/mock_dados_mes.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class AnalisePassageirosPage extends StatelessWidget {
  const AnalisePassageirosPage({super.key});

  @override
  Widget build(BuildContext context) {
    int soma(List<int> l) => l.fold<int>(0, (a, b) => a + b);

    final totais = MockPassageiros.total;
    final total = soma(totais);
    final pagantes = soma(MockPassageiros.catraca) + soma(MockPassageiros.antecipados);
    final naoPagantes = soma(MockPassageiros.naoPagantes);
    final media = total / totais.length;

    final semanas = porSemana(totais);
    final dias = diasPorSemana(totais.length);
    final medias = [for (var i = 0; i < semanas.length; i++) semanas[i] / dias[i]];

    return PageScaffold(
      title: 'Análise de Passageiros',
      subtitle: 'Agosto de 2026 · Perfil de uso do sistema',
      children: [
        KpiGrid(children: [
          KpiCard(
              icon: Icons.groups_outlined,
              color: AppColors.blue,
              value: fmtInt(total),
              label: 'Total de passageiros'),
          KpiCard(
              icon: Icons.payments_outlined,
              color: AppColors.teal,
              value: fmtInt(pagantes),
              label: 'Pagantes (catraca + antecipados)'),
          KpiCard(
              icon: Icons.card_giftcard_outlined,
              color: AppColors.orange,
              value: fmtInt(naoPagantes),
              label: 'Não pagantes'),
          KpiCard(
              icon: Icons.insights_outlined,
              color: AppColors.blue,
              value: fmtInt(media),
              label: 'Média diária'),
        ]),
        SplitRow(
          sideFirst: true,
          side: DonutChartCard(
            title: 'Composição dos passageiros',
            centerValue: '${(pagantes / total * 100).round()}%',
            centerLabel: 'pagantes',
            slices: [
              DonutSlice('Pagantes', pagantes.toDouble(), AppColors.blue),
              DonutSlice('Não pagantes', naoPagantes.toDouble(), AppColors.orange),
            ],
          ),
          main: BarChartCard(
            title: 'Evolução semanal',
            labels: [for (var i = 0; i < semanas.length; i++) 'Sem ${i + 1}'],
            values: semanas,
          ),
        ),
        SplitRow(
          main: LineChartCard(
            title: 'Passageiros por dia',
            labels: MockPassageiros.dias,
            series: [LineSeries(
                [for (final t in totais) t.toDouble()], AppColors.blue)],
          ),
          side: SectionCard(
            title: 'Resumo por semana',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 36,
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('Semana')),
                    DataColumn(label: Text('Total'), numeric: true),
                    DataColumn(label: Text('Média/dia'), numeric: true),
                    DataColumn(label: Text('Var.'), numeric: true),
                  ],
                  rows: [
                    for (var i = 0; i < semanas.length; i++)
                      DataRow(cells: [
                        DataCell(Text('Sem ${i + 1}${dias[i] < 7 ? '*' : ''}')),
                        DataCell(Text(fmtInt(semanas[i]))),
                        DataCell(Text(fmtInt(medias[i]))),
                        DataCell(i == 0
                            ? const Text('—')
                            : _variacao(medias[i] / medias[i - 1] * 100 - 100)),
                      ]),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('* semana incompleta (3 dias). Var. = média/dia x semana anterior.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          ),
        ),
        LineChartCard(
          title: 'Viagens realizadas por faixa de horário (oferta)',
          labels: MockPassageiros.horasLabels,
          series: [LineSeries(MockPassageiros.viagensPorHora, AppColors.teal)],
        ),
      ],
    );
  }

  static Widget _variacao(double p) => Text(
        fmtVar(p),
        style: TextStyle(
            color: p >= 0 ? AppColors.green : AppColors.red,
            fontWeight: FontWeight.w600),
      );
}
