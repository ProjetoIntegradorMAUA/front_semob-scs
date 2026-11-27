import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import 'app_theme.dart';
import 'common.dart';

/// Escala "bonita" para o eixo Y: começa em 0, anda de passo redondo
/// (1, 2 ou 5 x potência de 10) e termina SEMPRE acima do maior valor.
/// Ex.: maior valor 41.562 -> passo 10.000, eixo de 0 a 50.000.
({double max, double passo}) escalaEixo(double maiorValor, {int divisoes = 5}) {
  if (maiorValor <= 0) return (max: 1.0, passo: 1.0);
  final bruto = maiorValor / divisoes;
  final potencia = math.pow(10, (math.log(bruto) / math.ln10).floor()).toDouble();
  final fator = bruto / potencia;
  final bonito = fator <= 1
      ? 1
      : fator <= 2
          ? 2
          : fator <= 5
              ? 5
              : 10;
  final passo = bonito * potencia;
  final max = ((maiorValor / passo).floor() + 1) * passo;
  return (max: max, passo: passo);
}

double _maior(Iterable<List<double>> series) {
  var m = 0.0;
  for (final s in series) {
    for (final v in s) {
      if (v > m) m = v;
    }
  }
  return m;
}

TextStyle _axisStyle(BuildContext context) =>
    TextStyle(fontSize: 11, color: context.cores.muted);

FlGridData _grid(BuildContext context, double passo) => FlGridData(
      drawVerticalLine: false,
      horizontalInterval: passo,
      getDrawingHorizontalLine: (_) =>
          FlLine(color: context.cores.border, strokeWidth: 1),
    );

FlTitlesData _titles(BuildContext context, List<String> labels, double passo) =>
    FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 56,
          interval: passo, // um rótulo por degrau: nunca ficam um sobre o outro
          getTitlesWidget: (v, _) => Text(fmtInt(v), style: _axisStyle(context)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          // muitos rótulos (ex.: 31 dias) -> mostra de 3 em 3
          interval: labels.length > 12 ? 3.0 : 1.0,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= labels.length) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(labels[i], style: _axisStyle(context)),
            );
          },
        ),
      ),
    );

const _tooltipStyle =
    TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12);

/// Legenda simples: bolinha colorida + nome.
class _Legend extends StatelessWidget {
  final List<(String, Color)> itens;
  const _Legend(this.itens);

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 16, runSpacing: 4, children: [
      for (final (nome, cor) in itens)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(nome, style: _axisStyle(context)),
        ]),
    ]);
  }
}

class LineSeries {
  final List<double> values;
  final Color color;
  final String? name; // se informado, aparece na legenda
  const LineSeries(this.values, this.color, [this.name]);
}

/// Gráfico de linha (uma ou mais séries).
class LineChartCard extends StatelessWidget {
  final String title;
  final List<String> labels;
  final List<LineSeries> series;
  final String Function(double)? formatoTooltip;
  const LineChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.series,
    this.formatoTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final nomeadas = [
      for (final s in series)
        if (s.name != null) (s.name!, s.color)
    ];
    final escala = escalaEixo(_maior(series.map((s) => s.values)));
    final fmt = formatoTooltip ?? (double v) => fmtInt(v);
    final pontos = series.fold<int>(0, (a, s) => s.values.length > a ? s.values.length : a);

    return SectionCard(
      title: title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (nomeadas.isNotEmpty) ...[
          _Legend(nomeadas),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 240,
          child: LineChart(LineChartData(
            minY: 0,
            maxY: escala.max,
            minX: 0,
            maxX: pontos > 1 ? (pontos - 1).toDouble() : 1,
            gridData: _grid(context, escala.passo),
            borderData: FlBorderData(show: false),
            titlesData: _titles(context, labels, escala.passo),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => [
                  for (final s in spots) LineTooltipItem(fmt(s.y), _tooltipStyle),
                ],
              ),
            ),
            lineBarsData: [
              for (final s in series)
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < s.values.length; i++)
                      FlSpot(i.toDouble(), s.values[i])
                  ],
                  isCurved: true,
                  curveSmoothness: 0.15,
                  preventCurveOverShooting: true,
                  color: s.color,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData:
                      BarAreaData(show: true, color: s.color.withValues(alpha: 0.07)),
                ),
            ],
          )),
        ),
      ]),
    );
  }
}

/// Gráfico de barras verticais (uma série).
class BarChartCard extends StatelessWidget {
  final String title;
  final List<String> labels;
  final List<double> values;
  final Color color;
  final String Function(double)? formatoTooltip;
  const BarChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    this.color = AppColors.blue,
    this.formatoTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final escala = escalaEixo(_maior([values]));
    final fmt = formatoTooltip ?? (double v) => fmtInt(v);
    return SectionCard(
      title: title,
      child: SizedBox(
        height: 240,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: escala.max,
          gridData: _grid(context, escala.passo),
          borderData: FlBorderData(show: false),
          titlesData: _titles(context, labels, escala.passo),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(fmt(rod.toY), _tooltipStyle),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ]),
          ],
        )),
      ),
    );
  }
}

class BarSeries {
  final String name;
  final List<double> values;
  final Color color;
  const BarSeries(this.name, this.values, this.color);
}

/// Barras agrupadas (várias séries lado a lado) com legenda.
class GroupedBarChartCard extends StatelessWidget {
  final String title;
  final List<String> labels;
  final List<BarSeries> series;
  final String Function(double)? formatoTooltip;
  const GroupedBarChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.series,
    this.formatoTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final escala = escalaEixo(_maior(series.map((s) => s.values)));
    final fmt = formatoTooltip ?? (double v) => fmtInt(v);
    return SectionCard(
      title: title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Legend([for (final s in series) (s.name, s.color)]),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            minY: 0,
            maxY: escala.max,
            gridData: _grid(context, escala.passo),
            borderData: FlBorderData(show: false),
            titlesData: _titles(context, labels, escala.passo),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(fmt(rod.toY), _tooltipStyle),
              ),
            ),
            barGroups: [
              for (var i = 0; i < labels.length; i++)
                BarChartGroupData(x: i, barsSpace: 4, barRods: [
                  for (final s in series)
                    BarChartRodData(
                      toY: s.values[i],
                      color: s.color,
                      width: 12,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                ]),
            ],
          )),
        ),
      ]),
    );
  }
}

class DonutSlice {
  final String label;
  final double value;
  final Color color;
  const DonutSlice(this.label, this.value, this.color);
}

/// Gráfico de rosca com legenda. [format] formata os valores da legenda
/// (padrão: número inteiro com ponto de milhar).
class DonutChartCard extends StatelessWidget {
  final String title;
  final List<DonutSlice> slices;
  final String centerValue;
  final String centerLabel;
  final String Function(double)? format;
  const DonutChartCard({
    super.key,
    required this.title,
    required this.slices,
    required this.centerValue,
    required this.centerLabel,
    this.format,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = format ?? ((double v) => fmtInt(v));
    return SectionCard(
      title: title,
      child: Column(children: [
        SizedBox(
          height: 190,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 62,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                      value: s.value, color: s.color, title: '', radius: 22),
              ],
            )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(centerValue,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Text(centerLabel, style: _axisStyle(context)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(s.label, style: const TextStyle(fontSize: 12))),
              Text(fmt(s.value),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
      ]),
    );
  }
}
