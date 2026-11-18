// Funções de formatação (padrão brasileiro) e agregações simples.

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

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

/// 2026-08-02 -> "02/08"
String fmtDiaMes(DateTime d) => '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}';

/// -> "28/10/2026 14:05"
String fmtDataHora(DateTime d) =>
    '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year} ${_doisDigitos(d.hour)}:${_doisDigitos(d.minute)}';

/// 1234.5 -> "1.234,50"  (casas decimais ajustáveis)
String fmtDec(double v, [int casas = 2]) {
  final partes = v.abs().toStringAsFixed(casas).split('.');
  final inteiro = fmtInt(int.parse(partes[0]));
  final decimal = casas > 0 ? ',${partes[1]}' : '';
  return '${v < 0 ? '-' : ''}$inteiro$decimal';
}

/// "Relatório Operação" -> "relatorio_operacao" (para nomes de arquivo)
String slug(String texto) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const para = 'aaaaaeeeeiiiiooooouuuucn';
  var r = texto.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i], para[i]);
  }
  r = r.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return r.replaceAll(RegExp(r'^_+|_+$'), '');
}

/// Quantas semanas (blocos de 7 dias) o mês tem, pelo maior dia informado.
int semanasDoMes(List<int> dias) =>
    dias.isEmpty ? 1 : ((dias.reduce((a, b) => a > b ? a : b) - 1) ~/ 7) + 1;

/// Soma [valores] por semana do mês (dias 1-7 = Sem 1, 8-14 = Sem 2, ...).
List<double> somaPorSemana(List<int> dias, List<num> valores, int semanas) {
  final r = List<double>.filled(semanas, 0);
  for (var i = 0; i < dias.length; i++) {
    final s = (dias[i] - 1) ~/ 7;
    if (s >= 0 && s < semanas) r[s] += valores[i];
  }
  return r;
}

/// Quantos dias com dados cada semana tem.
List<int> diasComDadosPorSemana(List<int> dias, int semanas) {
  final r = List<int>.filled(semanas, 0);
  for (final d in dias) {
    final s = (d - 1) ~/ 7;
    if (s >= 0 && s < semanas) r[s]++;
  }
  return r;
}

/// -> "20261110_1530" (para nomes de arquivo)
String fmtCarimbo(DateTime d) =>
    '${d.year}${_doisDigitos(d.month)}${_doisDigitos(d.day)}_${_doisDigitos(d.hour)}${_doisDigitos(d.minute)}';

/// 5 -> "05"
String doisDigitos(int n) => _doisDigitos(n);
