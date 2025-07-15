import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'gemini_service.dart';

class WebScrapingService {
  final GeminiService _gemini;

  WebScrapingService({required GeminiService geminiService})
      : _gemini = geminiService;

  /// Busca o conteúdo HTML de uma URL da NFC-e e o analisa.
  Future<Map<String, dynamic>> scrapeNfceFromUrl(String url,
      {List<String> categorias = const [], bool ignoreBadCertificate = false}) async {
    try {
      http.Client client;
      if (ignoreBadCertificate) {
        final ioHttpClient = HttpClient()
          ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        client = IOClient(ioHttpClient);
      } else {
        client = http.Client();
      }

      final response = await client.get(Uri.parse(url));
      client.close();

      if (response.statusCode == 200) {
        try {
          final data = _parseNfceHtmlDart(response.body);
          if (data['itens'] == null || (data['itens'] as List).isEmpty) {
            return await _gemini.parseExpenseFromHtml(response.body,
                categorias: categorias);
          }
          return data;
        } catch (_) {
          return await _gemini.parseExpenseFromHtml(response.body,
              categorias: categorias);
        }
      } else {
        throw Exception('Falha ao carregar a página da nota fiscal. Status: ${response.statusCode}');
      }
    } catch (e) {
      // print("Erro no scraping: $e");
      throw Exception('Não foi possível conectar ao serviço da nota fiscal. Verifique sua conexão.');
    }
  }

  /// Analisa o HTML de uma NFC-e já carregado no navegador.
  Future<Map<String, dynamic>> parseNfceHtml(String html,
      {List<String> categorias = const []}) async {
    try {
      final data = _parseNfceHtmlDart(html);
      if (data['itens'] == null || (data['itens'] as List).isEmpty) {
        return await _gemini.parseExpenseFromHtml(html, categorias: categorias);
      }
      return data;
    } catch (_) {
      return await _gemini.parseExpenseFromHtml(html, categorias: categorias);
    }
  }

  /// Analisa o conteúdo HTML de uma NFC-e e extrai os dados.
  Map<String, dynamic> _parseNfceHtmlDart(String htmlContent) {
    final document = parse(htmlContent);
    Map<String, dynamic> data = {};

    // 1. Estabelecimento
    Map<String, String?> estabelecimento = {};
    final nomeEstabelecimentoTag = document.querySelector('div.txtTopo#u20');
    estabelecimento['nome'] = _cleanText(nomeEstabelecimentoTag?.text);

    final divTextElements = document.querySelectorAll('div.txtCenter > div.text');
    String? cnpjTextContent;
    String? enderecoTextContent;

    if (divTextElements.isNotEmpty) {
      cnpjTextContent = _cleanText(divTextElements[0].text);
      if (divTextElements.length > 1) {
        if (divTextElements[0].innerHtml.toLowerCase().contains('cnpj') &&
            !divTextElements[1].innerHtml.toLowerCase().contains('cnpj')) {
          enderecoTextContent = _cleanText(divTextElements[1].text);
        } else if (divTextElements.length > 1 && divTextElements[1].innerHtml.toLowerCase().contains('cnpj')) {
           enderecoTextContent = _cleanText(divTextElements[0].text);
        } else {
          enderecoTextContent = _cleanText(divTextElements[0].text.replaceFirst(RegExp(r'CNPJ:\s*[\d./-]+', caseSensitive: false), '').trim());
           if (divTextElements.length > 1 && !cnpjTextContent.contains(divTextElements[1].text)) {
              enderecoTextContent += " " + _cleanText(divTextElements[1].text);
          }
        }
      } else {
           enderecoTextContent = _cleanText(divTextElements[0].text.replaceFirst(RegExp(r'CNPJ:\s*[\d./-]+', caseSensitive: false), '').trim());
      }
    }

    final cnpjMatch = RegExp(r'CNPJ:\s*([\d./-]+)', caseSensitive: false).firstMatch(cnpjTextContent ?? "");
    estabelecimento['cnpj'] = cnpjMatch?.group(1);
    estabelecimento['endereco_completo'] = enderecoTextContent?.replaceAll(RegExp(r'CNPJ:\s*([\d./-]+)', caseSensitive: false), '').trim();

    data['estabelecimento'] = estabelecimento;

    // 2. Itens Comprados
    List<Map<String, dynamic>> itens = [];
    final tableResult = document.querySelector('table#tabResult');
    if (tableResult != null) {
      final rows = tableResult.querySelectorAll('tr');
      for (var row in rows) {
        Map<String, dynamic> item = {};
        
        final nomeTag = row.querySelector('span.txtTit');
        item['nome'] = nomeTag?.nodes
            .firstWhere((node) => node.nodeType == dom.Node.TEXT_NODE, orElse: () => dom.Text(""))
            .text
            ?.trim();

        final qtdTag = row.querySelector('span.Rqtd > strong');
        item['qtd'] = _toInt(_getTextAfterElement(qtdTag));

        final vlUnitTag = row.querySelector('span.RvlUnit > strong');
        item['valor_unitario'] = _toFloat(_getTextAfterElement(vlUnitTag)?.replaceAll('&nbsp;', ''));
        
        final vlTotalTag = row.querySelector('td.txtTit.noWrap > span.valor');
        item['valor_total_item'] = _toFloat(vlTotalTag?.text);

        if (item['nome'] != null && item['nome']!.isNotEmpty && item['nome'] != "N/A") {
          itens.add(item);
        }
      }
    }
    data['itens'] = itens;

    // 3. Compra (Totais)
    Map<String, dynamic> compra = {};
    final totalNotaDiv = document.querySelector('div#totalNota');
    if (totalNotaDiv != null) {
      totalNotaDiv.querySelectorAll('div#linhaTotal, div.linhaShade#linhaTotal').forEach((div) {
        final label = div.querySelector('label');
        final valueSpan = div.querySelector('span.totalNumb');
        if (label != null && valueSpan != null) {
          String labelText = _cleanText(label.text);
          String valueText = _cleanText(valueSpan.text);

          if (labelText == 'Qtd. total de itens:') {
            compra['qtd_total_itens'] = _toInt(valueText);
          } else if (labelText == 'Valor a pagar R\$:') {
            compra['valor_a_pagar'] = _toFloat(valueText);
          } else if (labelText == 'Descontos R\$:') {
            compra['descontos'] = _toFloat(valueText);
          } else if (labelText == 'Valor total R\$:') {
              if (compra['valor_a_pagar'] == null || compra['valor_a_pagar'] == 0.0) {
                   compra['valor_a_pagar'] = _toFloat(valueText);
              }
          }
        }
      });
       if (compra['descontos'] == null) compra['descontos'] = 0.0;

      List<Map<String, dynamic>> formasPagamento = [];
      dom.Element? formaPagamentoHeaderDiv;
      try {
        formaPagamentoHeaderDiv = totalNotaDiv.children.firstWhere(
          (el) => (el.id == 'linhaForma' && (el.querySelector('label')?.text.contains('Forma de pagamento:') ?? false))
        );
      } catch (e) {
        formaPagamentoHeaderDiv = null;
      }

      if (formaPagamentoHeaderDiv != null) {
          var currentElement = formaPagamentoHeaderDiv.nextElementSibling;
          while (currentElement != null && currentElement.id == 'linhaTotal') {
              final labelTx = currentElement.querySelector('label.tx');
              final valorPagoSpan = currentElement.querySelector('span.totalNumb');

              if (valorPagoSpan != null) {
                  final descricaoPagamento = _cleanText(labelTx?.text);
                  final valorPagamento = _toFloat(valorPagoSpan.text);
                   if (valorPagamento > 0 || (descricaoPagamento.isNotEmpty && descricaoPagamento != "null")) {
                      formasPagamento.add({'descricao': descricaoPagamento.isEmpty || descricaoPagamento == "null" ? "Não especificado" : descricaoPagamento, 'valor': valorPagamento});
                  }
              }
              currentElement = currentElement.nextElementSibling;
              if (currentElement == null || currentElement.id != 'linhaTotal' || (currentElement.querySelector('label.txtObs') != null)) {
                  break;
              }
          }
      }
      compra['formas_pagamento'] = formasPagamento;
    }
    data['compra'] = compra;

    // 4. Informação Geral
    Map<String, String?> informacaoGeral = {};
    final infosDiv = document.querySelector('div#infos');
    if (infosDiv != null) {
      infosDiv.querySelectorAll('div.ui-collapsible').forEach((collapsible) {
        final heading = collapsible.querySelector('h4.ui-collapsible-heading');
        if (heading != null) {
          String headingText = _cleanText(heading.text);
          final content = collapsible.querySelector('div.ui-collapsible-content');
          if (content != null) {
            if (headingText.contains('Chave de acesso')) {
              informacaoGeral['chave_acesso'] = _cleanText(content.querySelector('span.chave')?.text).replaceAll(" ", "");
            } else if (headingText.contains('Informações gerais da Nota')) {
              final liContentText = content.querySelector('li.ui-li-static')?.text;
              if (liContentText != null) {
                final emissaoMatch = RegExp(r'Emissão:\s*(\d{2}/\d{2}/\d{4}\s*\d{2}:\d{2}:\d{2}-\d{2}:\d{2})').firstMatch(liContentText);
                informacaoGeral['data_hora_emissao'] = _cleanText(emissaoMatch?.group(1));

                final protocoloMatch = RegExp(r'Protocolo de Autorização:\s*([\d\s]+?)\s*(\d{2}/\d{2}/\d{4})\s*às\s*(\d{2}:\d{2}:\d{2}-\d{2}:\d{2})').firstMatch(liContentText);
                if (protocoloMatch != null) {
                  informacaoGeral['protocolo_autorizacao'] = "${_cleanText(protocoloMatch.group(1))} ${protocoloMatch.group(2)} ${protocoloMatch.group(3)}";
                }
              }
            }
          }
        }
      });
    }
    data['informacao_geral'] = informacaoGeral;
    
    // 5. Outras Informações (Consumidor)
    Map<String, String?> outrasInfos = {};
    if (infosDiv != null) {
        var consumidorCollapsible = infosDiv.querySelectorAll('div.ui-collapsible')
            .firstWhere((collapsible) => collapsible.querySelector('h4.ui-collapsible-heading')?.text.contains('Consumidor') ?? false,
                orElse: () => dom.Element.html('<div></div>'));
        
        if (consumidorCollapsible.localName != 'div' || consumidorCollapsible.text.isEmpty) consumidorCollapsible = dom.Element.html('<div></div>');

        final ulConsumidor = consumidorCollapsible.querySelector('ul.ui-listview');
        if (ulConsumidor != null) {
            final liElements = ulConsumidor.querySelectorAll('li.ui-li-static');
            String cpfText = "N/A";
            String nomeText = "N/A";

            for (var li in liElements) {
                String currentLiText = _cleanText(li.text);
                if (currentLiText.startsWith('CPF:')) {
                    cpfText = _cleanText(currentLiText.replaceFirst('CPF:', '').trim());
                } else if (currentLiText.startsWith('Nome:')) {
                    nomeText = _cleanText(currentLiText.replaceFirst('Nome:', '').trim());
                    if (nomeText.isEmpty) nomeText = "N/A";
                } else if (currentLiText == 'Consumidor não identificado') {
                    cpfText = "Não identificado";
                }
            }
            outrasInfos['consumidor_cpf'] = cpfText;
            outrasInfos['consumidor_nome'] = nomeText;
        }
    }
    data['outras_informacoes'] = outrasInfos;

    return data;
  }

  // Funções Auxiliares
  String _cleanText(String? text) {
    return text?.trim() ?? "";
  }

  double _toFloat(String? textValue) {
    if (textValue == null || textValue.isEmpty) return 0.0;
    final cleanedValue = _cleanText(textValue)
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    try {
      return double.parse(cleanedValue);
    } catch (e) {
      return 0.0;
    }
  }

  int _toInt(String? textValue) {
    if (textValue == null || textValue.isEmpty) return 0;
    final cleanedValue = _cleanText(textValue).replaceAll(RegExp(r'\D'), '');
    try {
      return int.parse(cleanedValue);
    } catch (e) {
      return 0;
    }
  }

  String? _getTextAfterElement(dom.Element? element) {
    if (element == null || element.parent == null) return null;
    final parent = element.parent!;
    final children = parent.nodes;
    final idx = children.indexOf(element);
    if (idx != -1 && idx + 1 < children.length) {
      final nextNode = children[idx + 1];
      if (nextNode.nodeType == dom.Node.TEXT_NODE) {
        return nextNode.text?.trim();
      }
    }
    return null;
  }
}