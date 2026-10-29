import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../services/mock_data.dart';
import '../services/mock_dados_mes.dart';
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

    final semVendas = porSemana(vendas);
    final semUso = porSemana(uso);
    final semLabels = [for (var i = 0; i < semVendas.length; i++) 'Sem ${i + 1}'];

    return PageScaffold(
      title: 'Indicadores Financeiros',
      subtitle: 'Venda x utilização de créditos · Agosto de 2026',
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
              label: 'Total de vendas'),
          KpiCard(
              icon: Icons.credit_card_outlined,
              color: AppColors.blue,
              value: fmtMoney(totalUso),
              label: 'Créditos utilizados'),
          KpiCard(
              icon: Icons.account_balance_wallet_outlined,
              color: saldo >= 0 ? AppColors.orange : AppColors.red,
              value: fmtMoney(saldo),
              label: 'Crédito circulante (vendas − utilização)'),
          KpiCard(
              icon: Icons.percent,
              color: AppColors.green,
              value: fmtPct(pctUso),
              label: 'Utilização sobre as vendas'),
        ]),
        SplitRow(
          main: LineChartCard(
            title: 'Vendas x utilização por dia (R\$)',
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
          main: GroupedBarChartCard(
            title: 'Comparativo por semana (R\$)',
            labels: semLabels,
            series: [
              BarSeries('Vendas', semVendas, AppColors.teal),
              BarSeries('Utilização', semUso, AppColors.blue),
            ],
          ),
          side: SectionCard(
            title: 'Resumo por semana',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Semana')),
                  DataColumn(label: Text('Vendas (R\$)'), numeric: true),
                  DataColumn(label: Text('Uso (R\$)'), numeric: true),
                  DataColumn(label: Text('Saldo (R\$)'), numeric: true),
                ],
                rows: [
                  for (var i = 0; i < semVendas.length; i++)
                    DataRow(cells: [
                      DataCell(Text(semLabels[i])),
                      DataCell(Text(fmtInt(semVendas[i]))),
                      DataCell(Text(fmtInt(semUso[i]))),
                      DataCell(Text(
                        fmtInt(semVendas[i] - semUso[i]),
                        style: TextStyle(
                            color: semVendas[i] - semUso[i] < 0
                                ? AppColors.red
                                : null),
                      )),
                    ]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
