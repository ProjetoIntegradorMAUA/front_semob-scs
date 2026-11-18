import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import '../services/mock_data.dart';
import '../services/mock_dados_mes.dart';
import '../widgets/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class IndicadoresFinanceirosPage extends StatefulWidget {
  const IndicadoresFinanceirosPage({super.key});

  @override
  State<IndicadoresFinanceirosPage> createState() => _IndicadoresFinanceirosPageState();
}

class _IndicadoresFinanceirosPageState extends State<IndicadoresFinanceirosPage> {
  String _mes = 'Agosto/2026';

  @override
  Widget build(BuildContext context) {
    final vendas = MockFinanceiro.vendasPorDia;
    final uso = MockFinanceiro.utilizacaoPorDia;
    final totalVendas = vendas.fold<double>(0, (a, b) => a + b);
    final totalUso = uso.fold<double>(0, (a, b) => a + b);
    final saldo = totalVendas - totalUso;
    final pctUso = totalUso / totalVendas * 100;
    final mediaDia = totalVendas / vendas.length;

    final semVendas = porSemana(vendas);
    final semPass = porSemana(MockPassageiros.total);
    final semLabels = [
      for (var i = 0; i < semVendas.length; i++) 'Sem ${i + 1}${i == 4 ? '*' : ''}'
    ];
    // Sem 4 x Sem 3 (a semana 5 tem só 3 dias, então não entra na comparação)
    final varSemanal = semVendas[3] / semVendas[2] * 100 - 100;

    return PageScaffold(
      title: 'Indicadores Financeiros',
      subtitle: 'Acompanhamento de vendas e utilização de créditos · Agosto de 2026',
      children: [
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
              hint: '${fmtMoney(mediaDia)} por dia',
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
              hint: '${fmtPct(100 - pctUso)} das vendas',
              hintColor: saldo >= 0 ? AppColors.orange : AppColors.red),
          KpiCard(
              icon: Icons.trending_up,
              color: AppColors.green,
              value: fmtVar(varSemanal),
              label: 'Variação semanal das vendas',
              hint: 'Sem 4 x Sem 3',
              hintColor: varSemanal >= 0 ? AppColors.green : AppColors.red),
        ]),
        SplitRow(
          main: LineChartCard(
            title: 'Evolução da receita: vendas x utilização por dia (R\$)',
            labels: MockPassageiros.dias,
            series: [
              LineSeries(vendas, AppColors.teal, 'Vendas'),
              LineSeries(uso, AppColors.blue, 'Utilização'),
            ],
          ),
          side: DonutChartCard(
            title: 'Utilização das vendas',
            centerValue: '${pctUso.round()}%',
            centerLabel: 'utilizado',
            format: fmtMoney,
            slices: [
              DonutSlice('Utilizado', totalUso, AppColors.blue),
              DonutSlice('Crédito em aberto', saldo, AppColors.orange),
            ],
          ),
        ),
        SplitRow(
          mainFlex: 1,
          sideFlex: 1,
          main: BarChartCard(
            title: 'Comparativo de receita por mês (R\$)',
            labels: MockFinanceiro.mesesLabels,
            values: MockFinanceiro.vendasMensais,
            color: AppColors.teal,
          ),
          side: GroupedBarChartCard(
            title: 'Passageiros x receita por semana (em milhares) · * parcial',
            labels: semLabels,
            series: [
              BarSeries('Passageiros (mil)', [for (final v in semPass) v / 1000], AppColors.blue),
              BarSeries('Receita (R\$ mil)', [for (final v in semVendas) v / 1000], AppColors.teal),
            ],
          ),
        ),
      ],
    );
  }
}
