import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Moldura padrão de cada página: título, subtítulo e lista de blocos.
/// O conteúdo é centralizado e limitado a 1400 px (telas muito largas).
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
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: context.cores.text)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13, color: context.cores.muted)),
            const SizedBox(height: 20),
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) const SizedBox(height: 16),
            ],
          ]),
    final horizontalPadding = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 20),
              for (final c in children) ...[c, const SizedBox(height: 16)],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Card branco (ou escuro) com título.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: context.cores.text)),
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
  final String? hint; // linha pequena abaixo do rótulo (ex.: "44,8% das vendas")
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
      decoration: cardDecoration(context),
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
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: context.cores.text)),
            ),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: context.cores.muted)),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(hint!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hintColor ?? context.cores.muted)),
              ),
          ]),
        ),
      ]),
    );
  }
}
          
/// Grade de KPIs: 4 colunas no desktop, 2 no tablet e 1 no celular estreito.
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
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: sideFirst ? sideFlex : mainFlex, child: primeiro),
            const SizedBox(width: 16),
            Expanded(flex: sideFirst ? mainFlex : sideFlex, child: segundo),
          ],
        ),
      );
    });
  }
}

/// Selo colorido (ex.: gravidade e status dos alertas).
class Pilula extends StatelessWidget {
  final String texto;
  final Color cor;
  const Pilula(this.texto, this.cor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor)),
    );
  }
}

/// Card de filtro por período: o usuário escolhe e clica em "Filtrar".
class FiltroPeriodoCard extends StatefulWidget {
  final String titulo;
  final List<String> opcoes;
  final String inicial;
  final String? descricao; // texto ao lado do botão (ex.: período exibido)
  final ValueChanged<String> aoFiltrar;
  const FiltroPeriodoCard({
    super.key,
    required this.titulo,
    required this.opcoes,
    required this.inicial,
    required this.aoFiltrar,
    this.descricao,
  });

  @override
  State<FiltroPeriodoCard> createState() => _FiltroPeriodoCardState();
}

class _FiltroPeriodoCardState extends State<FiltroPeriodoCard> {
  late String _selecionado = widget.inicial;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: widget.titulo,
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: DropdownButtonFormField<String>(
              initialValue: _selecionado,
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Período', border: OutlineInputBorder(), isDense: true),
              items: [
                for (final o in widget.opcoes) DropdownMenuItem(value: o, child: Text(o)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selecionado = v);
              },
            ),
          ),
          FilledButton.icon(
            onPressed: () => widget.aoFiltrar(_selecionado),
            icon: const Icon(Icons.filter_alt_outlined, size: 18),
            label: const Text('Filtrar'),
          ),
          if (widget.descricao != null)
            Text(widget.descricao!,
                style: TextStyle(fontSize: 12, color: context.cores.muted)),
        ],
      ),
    );
  }
}
