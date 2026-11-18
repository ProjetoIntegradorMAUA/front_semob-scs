import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../models/dados_mes.dart';
import '../services/alertas_service.dart';
import '../services/dados_service.dart';
import '../services/formatadores.dart';
import '../services/api_config.dart';
import '../services/formatadores.dart';
import '../services/mock_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/tabela.dart';

class DashboardGeralPage extends StatelessWidget {
  const DashboardGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final d = DadosService.agosto;
    final total = d.passageirosTotal;

    return PageScaffold(
      title: 'Dashboard de Operação',
      subtitle: '${d.rotulo} · São Caetano do Sul',
      children: [
        const DataSourceBanner(
          isMock: ApiConfig.useMocks,
          source: ApiConfig.sourceLabel,
          period: 'Atualização de referência: 04/09/2026 às 08:00',
        ),
        KpiGrid(children: [
          KpiCard(
              icon: Icons.groups_outlined,
              color: AppColors.teal,
              value: fmtInt(total),
              label: 'Passageiros no mês'),
          KpiCard(
              icon: Icons.alt_route,
              color: AppColors.blue,
              value: fmtInt(d.viagensRealizadas),
              label: 'Viagens realizadas'),
          KpiCard(
              icon: Icons.route_outlined,
              color: AppColors.orange,
              value: '${fmtInt(d.kmTotal)} km',
              label: 'Quilometragem total'),
          KpiCard(
              icon: Icons.check_circle_outline,
              color: AppColors.green,
              value: fmtPct(d.fcv),
              label: 'Cumprimento de viagens'),
        ]),
        SplitRow(
          main: LineChartCard(
            title: 'Evolução de passageiros por dia',
            labels: [for (final dia in d.diasPass) doisDigitos(dia)],
            series: [
              LineSeries([for (final p in d.passageirosPorDia) p.toDouble()], AppColors.blue),
            ],
          ),
          side: DonutChartCard(
            title: 'Distribuição de passageiros',
            centerValue: '${fmtDec(total / 1000000)} mi',
            centerLabel: 'total',
            slices: [
              DonutSlice('Não pagantes', d.passageirosNaoPagantes.toDouble(), AppColors.blue),
              DonutSlice('Catraca', d.passageirosCatraca.toDouble(), AppColors.teal),
              DonutSlice('Antecipados', d.passageirosAntecipados.toDouble(), AppColors.orange),
            ],
          ),
        ),
        SplitRow(main: _TopLinhas(d), side: _Alertas(d)),
      ],
    );
  }
}

class _TopLinhas extends StatelessWidget {
  final DadosMes d;
  const _TopLinhas(this.d);

  @override
  Widget build(BuildContext context) {
    final top = d.linhasOrdenadas.take(6).toList();
    final totalViagens = d.viagensRealizadas;
    return SectionCard(
      title: 'Linhas com mais viagens',
      child: TabelaCheia(
        colunas: const [
          TabCol('Linha', flex: 3),
          TabCol('Viagens', flex: 2, direita: true),
          TabCol('Km', flex: 2, direita: true),
          TabCol('% do total', flex: 2, direita: true),
        ],
        linhas: [
          for (final l in top)
            [
              celulaLinha(context, l.linha),
              Text(fmtInt(l.viagens)),
              Text(fmtInt(l.km)),
              Text(fmtPct(l.viagens / totalViagens * 100)),
            ],
        ],
      ),
    );
  }
}

class _Alertas extends StatelessWidget {
  final DadosMes d;
  const _Alertas(this.d);

  Widget _linha(IconData icone, Color cor, String texto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icone, size: 18, color: cor),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final doMes = AlertasService.listar().where((a) => a.data.month == d.mes);
    final criticos = doMes.where((a) => a.gravidade == Gravidade.critico).length;
    final atencao = doMes.where((a) => a.gravidade == Gravidade.atencao).length;

    return SectionCard(
      title: 'Alertas',
      child: Column(children: [
        _linha(Icons.error_outline, AppColors.red,
            '$criticos ${criticos == 1 ? 'alerta crítico' : 'alertas críticos'} em aberto'),
        _linha(Icons.warning_amber_rounded, AppColors.orange,
            '$atencao ${atencao == 1 ? 'alerta' : 'alertas'} em atenção'),
        _linha(Icons.directions_bus_outlined, AppColors.orange,
            '${d.viagensNaoRealizadas} viagens não realizadas no mês'),
        _linha(
            Icons.account_balance_wallet_outlined,
            d.diasSaldoNegativo == 0 ? AppColors.green : AppColors.red,
            d.diasSaldoNegativo == 0
                ? 'Nenhum dia com crédito circulante negativo'
                : 'Crédito circulante negativo em ${d.diasSaldoNegativo} dia(s)'),
        _linha(Icons.check_circle_outline, AppColors.green,
            'Cumprimento de viagens: ${fmtPct(d.fcv)}'),
      ]),
    );
  }
}
