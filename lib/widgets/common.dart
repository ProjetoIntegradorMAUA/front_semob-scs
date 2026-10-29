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
  const KpiCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
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
            color: color.withOpacity(0.12),
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

/// Duas colunas (2/3 + 1/3) no desktop; empilha no mobile.
/// Com [sideFirst], a coluna estreita vem primeiro (esquerda / topo).
class SplitRow extends StatelessWidget {
  final Widget main;
  final Widget side;
  final bool sideFirst;
  const SplitRow({
    super.key,
    required this.main,
    required this.side,
    this.sideFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 900) {
        return Column(children: [
          sideFirst ? side : main,
          const SizedBox(height: 16),
          sideFirst ? main : side,
        ]);
      }
      final a = Expanded(flex: sideFirst ? 1 : 2, child: sideFirst ? side : main);
      final b = Expanded(flex: sideFirst ? 2 : 1, child: sideFirst ? main : side);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [a, const SizedBox(width: 16), b],
      );
    });
  }
}
