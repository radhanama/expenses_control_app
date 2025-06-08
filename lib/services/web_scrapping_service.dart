// import 'package:html/parser.dart' show parse;
// import 'package:html/dom.dart' as dom;
// import 'dart:io'; // Para leitura de arquivos (se estiver rodando como script Dart puro)
// // Em Flutter, para assets: import 'package:flutter/services.dart' show rootBundle;

// // Funções Auxiliares
// String cleanText(String? text) {
//   return text?.trim() ?? "";
// }

// double toFloat(String? textValue) {
//   if (textValue == null || textValue.isEmpty) return 0.0;
//   final cleanedValue = cleanText(textValue)
//       .replaceAll('R\$', '')
//       .replaceAll('.', '') // Remove separadores de milhar
//       .replaceAll(',', '.') // Substitui vírgula decimal
//       .trim();
//   try {
//     return double.parse(cleanedValue);
//   } catch (e) {
//     // print("Erro ao converter para float: '$textValue' -> $e");
//     return 0.0;
//   }
// }

// int toInt(String? textValue) {
//   if (textValue == null || textValue.isEmpty) return 0;
//   final cleanedValue = cleanText(textValue).replaceAll(RegExp(r'\D'), ''); // Remove não dígitos
//   try {
//     return int.parse(cleanedValue);
//   } catch (e) {
//     // print("Erro ao converter para int: '$textValue' -> $e");
//     return 0;
//   }
// }

// Map<String, dynamic> parseNfceHtmlDart(String htmlContent) {
//   final document = parse(htmlContent);
//   Map<String, dynamic> data = {};

//   // 1. Estabelecimento
//   Map<String, String?> estabelecimento = {};
//   final nomeEstabelecimentoTag = document.querySelector('div.txtTopo#u20');
//   estabelecimento['nome'] = cleanText(nomeEstabelecimentoTag?.text);

//   final divTextElements = document.querySelectorAll('div.txtCenter > div.text');
//   String? cnpjTextContent;
//   String? enderecoTextContent;

//   if (divTextElements.isNotEmpty) {
//     cnpjTextContent = cleanText(divTextElements[0].text);
//     if (divTextElements.length > 1) {
//       // Verifica se o segundo elemento já não é o endereço diretamente
//       // (considerando que o primeiro pode ter CNPJ e endereço concatenados em alguns layouts)
//       if (divTextElements[0].innerHtml.toLowerCase().contains('cnpj') &&
//           !divTextElements[1].innerHtml.toLowerCase().contains('cnpj')) {
//         enderecoTextContent = cleanText(divTextElements[1].text);
//       } else if (divTextElements.length > 1 && divTextElements[1].innerHtml.toLowerCase().contains('cnpj')) {
//         // Caso raro onde CNPJ está no segundo
//          enderecoTextContent = cleanText(divTextElements[0].text); // Assume que o primeiro é endereço
//       } else {
//         // Se ambos parecem ser endereço ou o primeiro contém tudo
//         enderecoTextContent = cleanText(divTextElements[0].text.replaceFirst(RegExp(r'CNPJ:\s*[\d./-]+', caseSensitive: false), '').trim());
//          if (divTextElements.length > 1 && !cnpjTextContent.contains(divTextElements[1].text)) { // Se o segundo for diferente e não estiver no primeiro
//             enderecoTextContent += " " + cleanText(divTextElements[1].text);
//         }
//       }
//     } else {
//          enderecoTextContent = cleanText(divTextElements[0].text.replaceFirst(RegExp(r'CNPJ:\s*[\d./-]+', caseSensitive: false), '').trim());
//     }
//   }


//   final cnpjMatch = RegExp(r'CNPJ:\s*([\d./-]+)', caseSensitive: false).firstMatch(cnpjTextContent ?? "");
//   estabelecimento['cnpj'] = cnpjMatch?.group(1);
//   estabelecimento['endereco_completo'] = enderecoTextContent?.replaceAll(RegExp(r'CNPJ:\s*([\d./-]+)', caseSensitive: false), '').trim(); // Remove CNPJ do endereço se estiver lá

//   data['estabelecimento'] = estabelecimento;

//   // 2. Itens Comprados
//   List<Map<String, dynamic>> itens = [];
//   final tableResult = document.querySelector('table#tabResult');
//   if (tableResult != null) {
//     final rows = tableResult.querySelectorAll('tr');
//     for (var row in rows) {
//       Map<String, dynamic> item = {};
      
//       // Nome do Item: Captura o primeiro nó de texto dentro do span.txtTit
//       final nomeTag = row.querySelector('span.txtTit');
//       item['nome'] = nomeTag?.nodes
//           .firstWhere((node) => node.nodeType == dom.Node.TEXT_NODE, orElse: () => dom.Text(""))
//           .text
//           ?.trim();

//       final qtdTag = row.querySelector('span.Rqtd > strong');
//       item['qtd'] = toInt(getTextAfterElement(qtdTag));

//       final vlUnitTag = row.querySelector('span.RvlUnit > strong');
//       item['valor_unitario'] = toFloat(getTextAfterElement(vlUnitTag)?.replaceAll('&nbsp;', ''));
      
//       final vlTotalTag = row.querySelector('td.txtTit.noWrap > span.valor');
//       item['valor_total_item'] = toFloat(vlTotalTag?.text);

//       if (item['nome'] != null && item['nome']!.isNotEmpty && item['nome'] != "N/A") {
//         itens.add(item);
//       }
//     }
//   }
//   data['itens'] = itens;

//   // 3. Compra (Totais)
//   Map<String, dynamic> compra = {};
//   final totalNotaDiv = document.querySelector('div#totalNota');
//   if (totalNotaDiv != null) {
//     totalNotaDiv.querySelectorAll('div#linhaTotal, div.linhaShade#linhaTotal').forEach((div) {
//       final label = div.querySelector('label');
//       final valueSpan = div.querySelector('span.totalNumb');
//       if (label != null && valueSpan != null) {
//         String labelText = cleanText(label.text);
//         String valueText = cleanText(valueSpan.text);

//         if (labelText == 'Qtd. total de itens:') {
//           compra['qtd_total_itens'] = toInt(valueText);
//         } else if (labelText == 'Valor a pagar R\$:') {
//           compra['valor_a_pagar'] = toFloat(valueText);
//         } else if (labelText == 'Descontos R\$:') {
//           compra['descontos'] = toFloat(valueText);
//         } else if (labelText == 'Valor total R\$:') { // Fallback se valor a pagar não existir
//             if (compra['valor_a_pagar'] == null || compra['valor_a_pagar'] == 0.0) {
//                  compra['valor_a_pagar'] = toFloat(valueText);
//             }
//         }
//       }
//     });
//      if (compra['descontos'] == null) compra['descontos'] = 0.0;


//     // Forma de pagamento
//     List<Map<String, dynamic>> formasPagamento = [];
//     dom.Element? formaPagamentoHeaderDiv;
//     try {
//       formaPagamentoHeaderDiv = totalNotaDiv.children.firstWhere(
//         (el) => (el.id == 'linhaForma' && (el.querySelector('label')?.text.contains('Forma de pagamento:') ?? false))
//       );
//     } catch (e) {
//       formaPagamentoHeaderDiv = null;
//     }

//     if (formaPagamentoHeaderDiv != null) {
//         var currentElement = formaPagamentoHeaderDiv.nextElementSibling;
//         while (currentElement != null && currentElement.id == 'linhaTotal') {
//             final labelTx = currentElement.querySelector('label.tx');
//             final valorPagoSpan = currentElement.querySelector('span.totalNumb');

//             if (valorPagoSpan != null) {
//                 final descricaoPagamento = cleanText(labelTx?.text);
//                 final valorPagamento = toFloat(valorPagoSpan.text);
//                  if (valorPagamento > 0 || (descricaoPagamento.isNotEmpty && descricaoPagamento != "null")) { // Adiciona se houver valor ou descrição explícita
//                     formasPagamento.add({'descricao': descricaoPagamento.isEmpty || descricaoPagamento == "null" ? "Não especificado" : descricaoPagamento, 'valor': valorPagamento});
//                 }
//             }
//             currentElement = currentElement.nextElementSibling;
//             // Condição de parada mais robusta
//             if (currentElement == null || currentElement.id != 'linhaTotal' || (currentElement.querySelector('label.txtObs') != null)) {
//                 break;
//             }
//         }
//     }
//     compra['formas_pagamento'] = formasPagamento;
//   }
//   data['compra'] = compra;

//   // 4. Informação Geral
//   Map<String, String?> informacaoGeral = {};
//   final infosDiv = document.querySelector('div#infos');
//   if (infosDiv != null) {
//     infosDiv.querySelectorAll('div.ui-collapsible').forEach((collapsible) {
//       final heading = collapsible.querySelector('h4.ui-collapsible-heading');
//       if (heading != null) {
//         String headingText = cleanText(heading.text);
//         final content = collapsible.querySelector('div.ui-collapsible-content');
//         if (content != null) {
//           if (headingText.contains('Chave de acesso')) {
//             informacaoGeral['chave_acesso'] = cleanText(content.querySelector('span.chave')?.text).replaceAll(" ", "");
//           } else if (headingText.contains('Informações gerais da Nota')) {
//             final liContentText = content.querySelector('li.ui-li-static')?.text;
//             if (liContentText != null) {
//               final emissaoMatch = RegExp(r'Emissão:\s*(\d{2}/\d{2}/\d{4}\s*\d{2}:\d{2}:\d{2}-\d{2}:\d{2})').firstMatch(liContentText);
//               informacaoGeral['data_hora_emissao'] = cleanText(emissaoMatch?.group(1));

//               final protocoloMatch = RegExp(r'Protocolo de Autorização:\s*([\d\s]+?)\s*(\d{2}/\d{2}/\d{4})\s*às\s*(\d{2}:\d{2}:\d{2}-\d{2}:\d{2})').firstMatch(liContentText);
//               if (protocoloMatch != null) {
//                 informacaoGeral['protocolo_autorizacao'] = "${cleanText(protocoloMatch.group(1))} ${protocoloMatch.group(2)} ${protocoloMatch.group(3)}";
//               }
//             }
//           }
//         }
//       }
//     });
//   }
//   data['informacao_geral'] = informacaoGeral;
  
//   // Outras Informações (Consumidor)
//   Map<String, String?> outrasInfos = {};
//   if (infosDiv != null) {
//       var consumidorCollapsible = infosDiv.querySelectorAll('div.ui-collapsible')
//           .firstWhere((collapsible) => collapsible.querySelector('h4.ui-collapsible-heading')?.text.contains('Consumidor') ?? false,
//               orElse: () => dom.Element.html('<div></div>')); // Dummy element se não encontrar
      
//       if (consumidorCollapsible.localName != 'div' || consumidorCollapsible.text.isEmpty) consumidorCollapsible = dom.Element.html('<div></div>');


//       final ulConsumidor = consumidorCollapsible.querySelector('ul.ui-listview');
//       if (ulConsumidor != null) {
//           final liElements = ulConsumidor.querySelectorAll('li.ui-li-static');
//           String cpfText = "N/A";
//           String nomeText = "N/A";

//           for (var li in liElements) {
//               String currentLiText = cleanText(li.text);
//               if (currentLiText.startsWith('CPF:')) {
//                   cpfText = cleanText(currentLiText.replaceFirst('CPF:', '').trim());
//               } else if (currentLiText.startsWith('Nome:')) {
//                   nomeText = cleanText(currentLiText.replaceFirst('Nome:', '').trim());
//                   if (nomeText.isEmpty) nomeText = "N/A";
//               } else if (currentLiText == 'Consumidor não identificado') {
//                   cpfText = "Não identificado";
//               }
//           }
//           outrasInfos['consumidor_cpf'] = cpfText;
//           outrasInfos['consumidor_nome'] = nomeText;
//       }
//   }
//   data['outras_informacoes'] = outrasInfos;

//   return data;
// }

// // --- Função Principal para Exemplo (pode ser chamada de um widget Flutter) ---
// Future<void> processarNotasFiscais(String fileName) async {
//   String? htmlContent;

//   // Para rodar como script Dart puro com arquivos locais:
//   // (Comente ou ajuste esta parte se estiver em um widget Flutter e carregando de assets)
//   try {
//     final file = File(fileName); // Coloque os arquivos no diretório raiz do seu projeto Dart/Flutter

//     if (await file.exists()) {
//       htmlContent = await file.readAsString();
//     } else {
//       print("Arquivo 'kfc-Consulta DF-e.html' não encontrado.");
//     }
//   } catch (e) {
//     print("Erro ao ler arquivos locais: $e");
//   }


//   // Em um app Flutter, você carregaria de assets assim:
//   // try {
//   //   htmlContent1 = await rootBundle.loadString('assets/kfc-Consulta DF-e.html');
//   //   // Certifique-se de ter os arquivos em uma pasta 'assets' e declarado no pubspec.yaml
//   // } catch (e) {
//   //   print("Erro ao carregar HTML dos assets: $e");
//   // }

//   if (htmlContent != null && htmlContent.isNotEmpty) {
//     print("\n--- Raspando dados de: kfc-Consulta DF-e.html ---");
//     final dadosNfce1 = parseNfceHtmlDart(htmlContent);
//     imprimirDadosNfce(dadosNfce1, "kfc-Consulta DF-e.html");
//   } else {
//     print("Conteúdo de 'kfc-Consulta DF-e.html' está vazio ou não foi carregado.");
//   }
// }

// // Helper para imprimir os dados de forma estruturada (usa print para Flutter)
// void imprimirDadosNfce(Map<String, dynamic> dados, String fileName) {
//   print("\n===========================================");
//   print("Resultados para: $fileName");
//   print("===========================================");

//   final est = dados['estabelecimento'] as Map<String, dynamic>? ?? {};
//   print("\n## Estabelecimento:");
//   print("  Nome: ${est['nome'] ?? 'N/A'}");
//   print("  CNPJ: ${est['cnpj'] ?? 'N/A'}");
//   print("  Endereço Completo: ${est['endereco_completo'] ?? 'N/A'}");

//   final itens = dados['itens'] as List<Map<String, dynamic>>? ?? [];
//   print("\n## Itens Comprados:");
//   if (itens.isNotEmpty) {
//     for (var i = 0; i < itens.length; i++) {
//       final item = itens[i];
//       print("  Item ${i + 1}:");
//       print("    Nome: ${item['nome'] ?? 'N/A'}");
//       print("    Quantidade: ${item['qtd'] ?? 0}");
//       print("    Valor Unitário: R\$ ${(item['valor_unitario'] ?? 0.0).toStringAsFixed(2)}");
//       print("    Valor Total do Item: R\$ ${(item['valor_total_item'] ?? 0.0).toStringAsFixed(2)}");
//     }
//   } else {
//     print("  Nenhum item encontrado.");
//   }

//   final compra = dados['compra'] as Map<String, dynamic>? ?? {};
//   print("\n## Compra:");
//   print("  Quantidade Total de Itens: ${compra['qtd_total_itens'] ?? 0}");
//   print("  Valor a Pagar: R\$ ${(compra['valor_a_pagar'] ?? 0.0).toStringAsFixed(2)}");
//   print("  Descontos: R\$ ${(compra['descontos'] ?? 0.0).toStringAsFixed(2)}");
//   print("  Forma(s) de Pagamento:");
//   final formasPagamento = compra['formas_pagamento'] as List<Map<String, dynamic>>? ?? [];
//   if (formasPagamento.isNotEmpty) {
//     for (var fp in formasPagamento) {
//       print("    - ${fp['descricao'] ?? 'Não especificado'}: R\$ ${(fp['valor'] ?? 0.0).toStringAsFixed(2)}");
//     }
//   } else {
//     print("    Nenhuma forma de pagamento especificada.");
//   }

//   final infoGeral = dados['informacao_geral'] as Map<String, dynamic>? ?? {};
//   print("\n## Informação Geral:");
//   print("  Chave de Acesso: ${infoGeral['chave_acesso'] ?? 'N/A'}");
//   print("  Data/Hora Emissão: ${infoGeral['data_hora_emissao'] ?? 'N/A'}");
//   print("  Protocolo de Autorização: ${infoGeral['protocolo_autorizacao'] ?? 'N/A'}");

//   final outrasInfos = dados['outras_informacoes'] as Map<String, dynamic>? ?? {};
//   print("\n## Outras Informações:");
//   print("  CPF do Consumidor: ${outrasInfos['consumidor_cpf'] ?? 'N/A'}");
//   print("  Nome do Consumidor: ${outrasInfos['consumidor_nome'] ?? 'N/A'}");
// }

// // Para rodar este exemplo como um script Dart puro (não dentro de um app Flutter completo):
// void main() async {
//   await processarNotasFiscais('assets/kfc-Consulta DF-e.html');
// }
// // Se estiver em um app Flutter, você chamaria `processarNotasFiscais()` de algum evento de UI.
// // Por exemplo, em um `onPressed` de um `ElevatedButton`.

// // Helper to get the text node after a given element
// String? getTextAfterElement(dom.Element? element) {
//   if (element == null || element.parent == null) return null;
//   final parent = element.parent!;
//   final children = parent.nodes;
//   final idx = children.indexOf(element);
//   if (idx != -1 && idx + 1 < children.length) {
//     final nextNode = children[idx + 1];
//     if (nextNode.nodeType == dom.Node.TEXT_NODE) {
//       return nextNode.text?.trim();
//     }
//   }
//   return null;
// }