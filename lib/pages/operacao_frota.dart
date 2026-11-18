import 'package:flutter/material.dart';
import '../services/dados_service.dart';
import '../services/formatadores.dart';
import '../widgets/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/tabela.dart';

class OperacaoFrotaPage extends StatefulWidget {
  const OperacaoFrotaPage({super.key});

  @override
  State<OperacaoFrotaPage> createState() => _OperacaoFrotaPageState();
}

class _OperacaoFrotaPageState extends State<OperacaoFrotaPage> {
  // Período aplicado (muda só quando o usuário clica em "Filtrar").
  String _aplicado = DadosService.agosto.rotulo;

  @override
  Widget build(BuildContext context) {
    final d = DadosService.porRotulo(_aplicado);
    final top = d.linhasOrdenadas.take(8).toList();
    final naoRealizadasFaixas = d.faixas.fold<int>(0, (a, f) => a + f.programadas - f.realizadas);
    final progFaixas = d.faixas.fold<int>(0, (a, f) => a + f.programadas);
    final realFaixas = d.faixas.fold<int>(0, (a, f) => a + f.realizadas);

    return PageScaffold(
      title: 'Operação da Frota',
      subtitle: 'Viagens, quilometragem e cumprimento por linha · ${d.rotulo}',
      children: [
        FiltroPeriodoCard(
          titulo: 'Filtros',
          opcoes: DadosService.rotulos,
          inicial: _aplicado,
          descricao: 'Período exibido: ${d.periodo}',
          aoFiltrar: (rotulo) => setState(() => _aplicado = rotulo),
        ),
        KpiGrid(children: [
          KpiCard(
              icon: Icons.event_note_outlined,
              color: AppColors.teal,
              value: fmtInt(d.viagensProgramadas),
              label: 'Viagens programadas'),
          KpiCard(
              icon: Icons.directions_bus_outlined,
              color: AppColors.blue,
              value: fmtInt(d.viagensRealizadas),
              label: 'Viagens realizadas'),
          KpiCard(
              icon: Icons.cancel_outlined,
              color: AppColors.red,
              value: fmtInt(d.viagensNaoRealizadas),
              label: 'Não realizadas'),
          KpiCard(
              icon: Icons.speed,
              color: AppColors.green,
              value: fmtPct(d.fcv),
              label: 'Cumprimento (FCV)'),
        ]),
        SplitRow(
          mainFlex: 1,
          sideFlex: 1,
          main: BarChartCard(
            title: 'Viagens por linha (8 maiores)',
            labels: [for (final l in top) l.linha],
            values: [for (final l in top) l.viagens.toDouble()],
          ),
          side: LineChartCard(
            title: 'Viagens programadas x realizadas por dia',
            labels: [for (final dia in d.diasOper) doisDigitos(dia)],
            series: [
              LineSeries([for (final v in d.viagensProg) v.toDouble()], AppColors.orange,
                  'Programadas'),
              LineSeries([for (final v in d.viagensReal) v.toDouble()], AppColors.blue,
                  'Realizadas'),
            ],
          ),
        ),
        SectionCard(
          title: 'Cumprimento por faixa horária',
          child: TabelaCheia(
            colunas: const [
              TabCol('Faixa', flex: 3),
              TabCol('Programadas', flex: 2, direita: true),
              TabCol('Realizadas', flex: 2, direita: true),
              TabCol('Não realizadas', flex: 2, direita: true),
              TabCol('FCV', flex: 2, direita: true),
            ],
            linhas: [
              for (final f in d.faixas)
                [
                  Text(f.nome),
                  Text(fmtInt(f.programadas)),
                  Text(fmtInt(f.realizadas)),
                  Text(fmtInt(f.programadas - f.realizadas)),
                  Text(fmtPct(f.fcv)),
                ],
              [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(fmtInt(progFaixas), style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(fmtInt(realFaixas), style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(fmtInt(naoRealizadasFaixas),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(fmtPct(progFaixas == 0 ? 0 : realFaixas / progFaixas * 100),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
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
              initialValue: mes,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Período', border: OutlineInputBorder(), isDense: true),
              items: [
                for (final m in MockData.meses)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
