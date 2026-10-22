import 'package:flutter/material.dart';

class SideNavbar extends StatefulWidget {
  const SideNavbar({super.key});

  @override
  State<SideNavbar> createState() => _SideNavbarState();
}

class _SideNavbarState extends State<SideNavbar> {
  int _indiceAtivo = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity, // o container vai esticar e ocupar 100% da altura da tela
      decoration: const BoxDecoration( 
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF004B93),
            Color(0xFF002244),
          ],
        )
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEMOB-SCS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4), // caixa invisível para empurrar o próximo elemento para baixo
          const Text(
            'Dashboard de Transporte',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 40), // Espaço antes dos itens

          _paginas('Dashboard', numeroDaPagina: 0),
          _paginas('Operação da Frota', numeroDaPagina: 1),
          _paginas('Passageiros', numeroDaPagina: 2),
          _paginas('Financeiro', numeroDaPagina: 3),
          _paginas('Alertas', numeroDaPagina: 4),
          _paginas('Relatórios', numeroDaPagina: 5),
          _paginas('Configurações', numeroDaPagina: 6),
        ],
      ),
    );
  }

  Widget _paginas(String title, {required int numeroDaPagina}) {
    bool ativo = _indiceAtivo == numeroDaPagina;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: ativo ? const Color(0xFF0073D6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      
      child: InkWell( // tranforma em botao
        onTap: () {
          setState(() {
            _indiceAtivo = numeroDaPagina;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            title,
            style: TextStyle(
              color: ativo ? Colors.white : Colors.white.withValues(alpha: 0.75),
              fontSize: 15,
              fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
