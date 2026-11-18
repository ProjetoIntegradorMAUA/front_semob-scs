# front_semob-scs
Front-end Flutter do SEMOB-SCS (dashboards de transporte municipal).

## Como rodar

```bash
flutter pub get
flutter run -d chrome
```

## Estrutura da lib

```
lib/
 ├─ main.dart                       app + troca de páginas pela navbar
 ├─ models/
 │   ├─ dados_mes.dart              todos os números de um mês (+ ocorrências por linha)
 │   ├─ linha_resumo.dart           linha, km e viagens
 │   ├─ faixa_fcv.dart              faixa horária: programadas x realizadas
 │   ├─ alerta.dart                 ocorrência (gravidade e status)
 │   ├─ relatorio.dart              relatório gerado e tipos de relatório
 │   └─ relatorio_conteudo.dart     tabelas de um relatório (antes de virar arquivo)
 ├─ services/
 │   ├─ dados_meses.dart            dados de Jul, Ago e Set/2026 (GERADO do ZIP)
 │   ├─ dados_service.dart          acesso aos dados (trocar pela API depois)
 │   ├─ alertas_service.dart        regras que geram as ocorrências
 │   ├─ relatorio_service.dart      monta o conteúdo de cada tipo de relatório
 │   ├─ relatorio_exportador.dart   gera PDF, Excel (.xlsx) e CSV
 │   ├─ arquivos/                   salvar/baixar arquivo (web e desktop)
 │   ├─ mock_relatorios.dart        tipos e formatos de relatório
 │   ├─ perfil_service.dart         nome e senha do perfil (simulado)
 │   ├─ tema_service.dart           tema claro/escuro
 │   ├─ alertas_service.dart        regras que geram as ocorrências
 │   ├─ mock_relatorios.dart        tipos e relatórios de exemplo
 │   ├─ mock_dados_mes.dart         dados de agosto/2026 (Passageiros e Financeiro)
 │   └─ formatadores.dart           formatação pt-BR e somas por semana
 ├─ widgets/
 │   ├─ navbar.dart                 menu lateral (SideNavbar)
 │   ├─ app_theme.dart              cores e tema claro/escuro
 │   ├─ common.dart                 cards, KPIs, filtro e grades responsivas
 │   ├─ tabela.dart                 tabela que ocupa toda a largura do card
 │   └─ charts.dart                 gráficos (linha, barras, rosca) com eixo 0..máx
 └─ pages/
     ├─ dashboard_geral.dart
     ├─ operacao_frota.dart
     ├─ analise_passageiros.dart
     ├─ indicadores_financeiros.dart
     ├─ alertas_operacionais.dart
     ├─ relatorios_gerenciais.dart
     └─ configuracoes.dart          tema claro/escuro, nome e senha
```

Dependências: `fl_chart` (gráficos), `pdf` e `excel` (relatórios), `web` (download no navegador).


