class FaixaFcv {
  final String nome;
  final int programadas;
  final int realizadas;
  const FaixaFcv(this.nome, this.programadas, this.realizadas);
  double get fcv => realizadas / programadas * 100;
}
