import 'package:flutter/material.dart';
import '../services/dados_service.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class IndicadoresFinanceirosPage extends StatefulWidget {
  const IndicadoresFinanceirosPage({super.key});

  @override
  State<IndicadoresFinanceirosPage> createState() => _IndicadoresFinanceirosPageState();
}

class _IndicadoresFinanceirosPageState extends State<IndicadoresFinanceirosPage> {
  // Período aplicado (muda só quando o usuário clica em "Filtrar").
  String _aplicado = DadosService.agosto.rotulo;

  @override
  Widget build(BuildContext context) {
    final d = DadosService.porRotulo(_aplicado);
    final totalVendas = d.totalVendas;
    final totalUso = d.totalUtilizacao;
    final saldo = d.creditoCirculante;
    final pctUso = d.pctUtilizacao;
    final diasComVenda = d.diasFin.length;

    // Semanas do mês (blocos de 7 dias) para vendas e passageiros
    final semanas = semanasDoMes(d.diasFin);
    final semVendas = somaPorSemana(d.diasFin, d.vendas, semanas);
    final semPass = somaPorSemana(d.diasPass, d.passageirosPorDia, semanas);
    final diasPorSemana = diasComDadosPorSemana(d.diasFin, semanas);
    final rotulosSemana = [for (var i = 0; i < semanas; i++) 'Sem ${i + 1}'];

    // Variação: duas últimas semanas COMPLETAS (7 dias com dados)
    final completas = [
      for (var i = 0; i < semanas; i++)
        if (diasPorSemana[i] == 7) i
    ];
    double? variacao;
    String variacaoDica = 'Poucos dados no período';
    if (completas.length >= 2) {
      final atual = completas[completas.length - 1];
      final anterior = completas[completas.length - 2];
      if (semVendas[anterior] > 0) {
        variacao = semVendas[atual] / semVendas[anterior] * 100 - 100;
        variacaoDica = 'Sem ${atual + 1} x Sem ${anterior + 1}';
      }
    }

    // Comparativo mensal (todos os meses disponíveis)
    final meses = DadosService.meses;

    // Rosca: se a utilização passou das vendas, o "crédito em aberto" fica negativo
    final fatias = saldo >= 0
        ? [
            DonutSlice('Utilizado', totalUso, AppColors.blue),
            DonutSlice('Crédito em aberto', saldo, AppColors.orange),
          ]
        : [
            DonutSlice('Utilização coberta pelas vendas', totalVendas, AppColors.blue),
            DonutSlice('Utilização acima das vendas', -saldo, AppColors.red),
          ];

    return PageScaffold(
      title: 'Indicadores Financeiros',
      subtitle: 'Acompanhamento de vendas e utilização de créditos · ${d.rotulo}',
      children: [
        FiltroPeriodoCard(
          titulo: 'Filtro financeiro',
          opcoes: DadosService.rotulos,
          inicial: _aplicado,
          descricao: 'Período exibido: ${d.periodo}',
          aoFiltrar: (rotulo) => setState(() => _aplicado = rotulo),
        SectionCard(
          title: 'Filtro financeiro',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _mes,
                  decoration: const InputDecoration(
                      labelText: 'Período',
                      border: OutlineInputBorder(),
                      isDense: true),
                  items: [
                    for (final m in MockData.meses)
                      DropdownMenuItem(value: m, child: Text(m)),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _mes = v);
                  },
                ),
              ),
              // TODO: recarregar os dados do mês selecionado (API / CSV).
              FilledButton(onPressed: () {}, child: const Text('Filtrar')),
            ],
          ),
        ),
        KpiGrid(children: [
          KpiCard(
              icon: Icons.sell_outlined,
              color: AppColors.teal,
              value: fmtMoney(totalVendas),
              label: 'Receita total (vendas)',
              hint: diasComVenda == 0
                  ? null
                  : '${fmtMoney(totalVendas / diasComVenda)} por dia',
              hintColor: AppColors.teal),
          KpiCard(
              icon: Icons.credit_card_outlined,
              color: AppColors.blue,
              value: fmtMoney(totalUso),
              label: 'Créditos utilizados',
              hint: '${fmtPct(pctUso)} das vendas',
              hintColor: AppColors.blue),
          KpiCard(
              icon: Icons.account_balance_wallet_outlined,
              color: saldo >= 0 ? AppColors.orange : AppColors.red,
              value: fmtMoney(saldo),
              label: 'Crédito circulante',
              hint: saldo >= 0 ? 'Vendas - utilização' : 'Utilização acima das vendas',
              hintColor: saldo >= 0 ? AppColors.orange : AppColors.red),
          KpiCard(
              icon: Icons.trending_up,
              color: AppColors.green,
              value: variacao == null ? '—' : fmtVar(variacao),
              label: 'Variação semanal das vendas',
              hint: variacaoDica,
              hintColor: (variacao ?? 0) >= 0 ? AppColors.green : AppColors.red),
        ]),
        SplitRow(
          main: LineChartCard(
            title: 'Evolução da receita: vendas x utilização por dia (R\$)',
            labels: [for (final dia in d.diasFin) doisDigitos(dia)],
            formatoTooltip: fmtMoney,
            series: [
              LineSeries(d.vendas, AppColors.teal, 'Vendas'),
              LineSeries(d.utilizacao, AppColors.blue, 'Utilização'),
            ],
          ),
          side: DonutChartCard(
            title: 'Utilização das vendas',
            centerValue: '${pctUso.round()}%',
            centerLabel: saldo >= 0 ? 'utilizado' : 'das vendas',
            format: fmtMoney,
            slices: fatias,
          ),
        ),
        SplitRow(
          mainFlex: 1,
          sideFlex: 1,
          main: BarChartCard(
            title: 'Comparativo de vendas por mês (R\$) · Set = 1ª quinzena',
            labels: [for (final m in meses) m.rotulo.substring(0, 3)],
            values: [for (final m in meses) m.totalVendas],
            color: AppColors.teal,
            formatoTooltip: fmtMoney,
          ),
          side: GroupedBarChartCard(
            title: 'Passageiros x receita por semana (em milhares)',
            labels: rotulosSemana,
            formatoTooltip: (v) => fmtDec(v, 1),
            series: [
              BarSeries('Passageiros (mil)', [for (final v in semPass) v / 1000], AppColors.blue),
              BarSeries('Receita (R\$ mil)', [for (final v in semVendas) v / 1000], AppColors.teal),
            ],
          ),
        ),
        if (d.nota != null)
          Text('Obs.: ${d.nota}',
              style: TextStyle(fontSize: 12, color: context.cores.muted)),
      ],
    );
  }
}
