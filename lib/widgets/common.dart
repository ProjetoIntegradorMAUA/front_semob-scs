import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Moldura padrão de cada página: título, subtítulo e lista de blocos.
class PageScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const PageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 20),
        for (final c in children) ...[c, const SizedBox(height: 16)],
      ]),
    );
  }
}

/// Card branco com título.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

/// Card de indicador (ícone colorido + valor + rótulo).
class KpiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? hint; // linha pequena abaixo do rótulo (ex.: "+11,2% vs período")
  final Color? hintColor;
  const KpiCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.hint,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration,
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
            ),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(hint!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hintColor ?? AppColors.muted)),
              ),
          ]),
        ),
      ]),
    );
  }
}

/// Grade de KPIs: 4 colunas no desktop, 2 no mobile.
class KpiGrid extends StatelessWidget {
  final List<Widget> children;
  const KpiGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 900 ? 4 : 2;
      const gap = 16.0;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final k in children) SizedBox(width: w, child: k)],
      );
    });
  }
}

/// Duas colunas no desktop (padrão 2/3 + 1/3); empilha no mobile.
/// Com [sideFirst], a coluna [side] vem primeiro (esquerda / topo).
class SplitRow extends StatelessWidget {
  final Widget main;
  final Widget side;
  final bool sideFirst;
  final int mainFlex;
  final int sideFlex;
  const SplitRow({
    super.key,
    required this.main,
    required this.side,
    this.sideFirst = false,
    this.mainFlex = 2,
    this.sideFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final primeiro = sideFirst ? side : main;
      final segundo = sideFirst ? main : side;
      if (c.maxWidth < 900) {
        return Column(children: [primeiro, const SizedBox(height: 16), segundo]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: sideFirst ? sideFlex : mainFlex, child: primeiro),
          const SizedBox(width: 16),
          Expanded(flex: sideFirst ? mainFlex : sideFlex, child: segundo),
        ],
      );
    });
  }
}
