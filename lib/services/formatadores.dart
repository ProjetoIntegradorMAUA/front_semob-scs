/// 1050248 -> "1.050.248"
String fmtInt(num n) => n
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

/// 99.84 -> "99,84%"
String fmtPct(double v) => '${v.toStringAsFixed(2).replaceAll('.', ',')}%';

/// 668605.71 -> "R$ 668.605,71"
String fmtMoney(double v) {
  final partes = v.abs().toStringAsFixed(2).split('.');
  return '${v < 0 ? '-' : ''}R\$ ${fmtInt(int.parse(partes[0]))},${partes[1]}';
}

/// Soma a lista em blocos de 7 dias (Sem 1 = dias 1–7, etc.).
List<double> porSemana(List<num> v) => [
      for (var i = 0; i < v.length; i += 7)
        v.skip(i).take(7).fold<double>(0, (a, b) => a + b),
    ];

/// Quantos dias cada semana tem (a última pode ter menos de 7).
List<int> diasPorSemana(int n) =>
    [for (var i = 0; i < n; i += 7) (n - i < 7 ? n - i : 7)];

/// 12.34 -> "+12,3%"
String fmtVar(double p) =>
    '${p >= 0 ? '+' : ''}${p.toStringAsFixed(1).replaceAll('.', ',')}%';
