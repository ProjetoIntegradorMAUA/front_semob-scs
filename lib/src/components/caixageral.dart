
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CaixaGeral extends StatelessWidget {
  const CaixaGeral({super.key});

  @override
  Widget build(BuildContext context) {
    // Valores temporários para testar o visual
    const int quilometragem = 124580;
    const double variacao = 3.2;

    final formatoKm = NumberFormat.decimalPattern('pt_BR');

    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD7E4F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFF19A99D),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Quilometragem',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64809E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${formatoKm.format(quilometragem)} km',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF142E4D),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '+${variacao.toStringAsFixed(1).replaceAll('.', ',')}% no período',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00AE9C),
            ),
          ),
        ],
      ),
    );
  }
}
