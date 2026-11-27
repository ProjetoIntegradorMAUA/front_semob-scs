import 'package:flutter/material.dart';
import '../models/dados_mes.dart';
import '../services/dados_service.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/tabela.dart';

class AnalisePassageirosPage extends StatelessWidget {
  const AnalisePassageirosPage({super.key});

  static Widget _variacao(double p) => Text(
        fmtVar(p),
        style: TextStyle(
            color: p >= 0 ? AppColors.green : AppColors.red, fontWeight: FontWeight.w600),
      );

  @override
  Widget build(BuildContext context) {
    final d = DadosService.agosto;
    final total = d.passageirosTotal;

    final semanas = semanasDoMes(d.diasPass);
    final totais = somaPorSemana(d.diasPass, d.passageirosPorDia, semanas);
    final dias = diasComDadosPorSemana(d.diasPass, semanas);
    final medias = [
      for (var i = 0; i < semanas; i++) dias[i] == 0 ? 0.0 : totais[i] / dias[i]
    ];
    final rotulosSemana = [for (var i = 0; i < semanas; i++) 'Sem ${i + 1}'];

    return PageScaffold(
      title: 'Análise de Passageiros',
      subtitle: '${d.rotulo} · Perfil de uso do sistema',
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
              value: fmtInt(d.passageirosPagantes),
              label: 'Pagantes (catraca + antecipados)'),
          KpiCard(
              icon: Icons.card_giftcard_outlined,
              color: AppColors.orange,
              value: fmtInt(d.passageirosNaoPagantes),
              label: 'Não pagantes'),
          KpiCard(
              icon: Icons.insights_outlined,
              color: AppColors.blue,
              value: fmtInt(d.mediaDiariaPassageiros),
              label: 'Média diária'),
        ]),
        SplitRow(
          sideFirst: true,
          side: DonutChartCard(
            title: 'Composição dos passageiros',
            centerValue: '${(d.passageirosPagantes / total * 100).round()}%',
            centerLabel: 'pagantes',
            slices: [
              DonutSlice('Pagantes', d.passageirosPagantes.toDouble(), AppColors.blue),
              DonutSlice('Não pagantes', d.passageirosNaoPagantes.toDouble(), AppColors.orange),
            ],
          ),
          main: BarChartCard(
            title: 'Evolução semanal',
            labels: rotulosSemana,
            values: totais,
          ),
        ),
        SplitRow(
          main: LineChartCard(
            title: 'Passageiros por dia',
            labels: [for (final dia in d.diasPass) doisDigitos(dia)],
            series: [
              LineSeries([for (final p in d.passageirosPorDia) p.toDouble()], AppColors.blue),
            ],
          ),
          side: _ResumoSemanal(
              semanas: semanas, totais: totais, medias: medias, dias: dias, variacao: _variacao),
        ),
        LineChartCard(
          title: 'Viagens realizadas por faixa de horário (oferta)',
          labels: DadosMes.horasLabels,
          series: [
            LineSeries([for (final v in d.viagensPorHora) v.toDouble()], AppColors.teal),
          ],
        ),
      ],
    );
  }
}

class _ResumoSemanal extends StatelessWidget {
  final int semanas;
  final List<double> totais;
  final List<double> medias;
  final List<int> dias;
  final Widget Function(double) variacao;
  const _ResumoSemanal({
    required this.semanas,
    required this.totais,
    required this.medias,
    required this.dias,
    required this.variacao,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Resumo por semana',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TabelaCheia(
          colunas: const [
            TabCol('Semana', flex: 2, largMin: 70),
            TabCol('Total', flex: 3, direita: true, largMin: 80),
            TabCol('Média/dia', flex: 3, direita: true, largMin: 80),
            TabCol('Var.', flex: 3, direita: true, largMin: 70),
          ],
          linhas: [
            for (var i = 0; i < semanas; i++)
              [
                Text('Sem ${i + 1}${dias[i] < 7 ? '*' : ''}'),
                Text(fmtInt(totais[i])),
                Text(fmtInt(medias[i])),
                (i == 0 || medias[i - 1] == 0)
                    ? const Text('—')
                    : variacao(medias[i] / medias[i - 1] * 100 - 100),
              ],
          ],
        ),
        const SizedBox(height: 8),
        Text('* semana incompleta. Var. = média/dia x semana anterior.',
            style: TextStyle(fontSize: 11, color: context.cores.muted)),
      ]),
    );
  }
}
