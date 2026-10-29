import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/formatadores.dart';
import 'app_theme.dart';
import 'common.dart';

const _axisStyle = TextStyle(fontSize: 11, color: AppColors.muted);

FlGridData _grid() => FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) =>
          const FlLine(color: AppColors.border, strokeWidth: 1),
    );

FlTitlesData _titles(List<String> labels) => FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (v, _) => Text(fmtInt(v), style: _axisStyle),
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
              child: Text(labels[i], style: _axisStyle),
            );
          },
        ),
      ),
    );

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
          Text(nome, style: _axisStyle),
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
  const LineChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    final nomeadas = [
      for (final s in series)
        if (s.name != null) (s.name!, s.color)
    ];
    return SectionCard(
      title: title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (nomeadas.isNotEmpty) ...[
          _Legend(nomeadas),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 220,
          child: LineChart(LineChartData(
            gridData: _grid(),
            borderData: FlBorderData(show: false),
            titlesData: _titles(labels),
            lineBarsData: [
              for (final s in series)
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < s.values.length; i++)
                      FlSpot(i.toDouble(), s.values[i])
                  ],
                  isCurved: true,
                  color: s.color,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData:
                      BarAreaData(show: true, color: s.color.withOpacity(0.07)),
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
  const BarChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    this.color = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      child: SizedBox(
        height: 220,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          gridData: _grid(),
          borderData: FlBorderData(show: false),
          titlesData: _titles(labels),
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
  const GroupedBarChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Legend([for (final s in series) (s.name, s.color)]),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: _grid(),
            borderData: FlBorderData(show: false),
            titlesData: _titles(labels),
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
          height: 180,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 58,
              sections: [
                for (final s in slices)
                  PieChartSectionData(
                      value: s.value, color: s.color, title: '', radius: 22),
              ],
            )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(centerValue,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(centerLabel, style: _axisStyle),
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
