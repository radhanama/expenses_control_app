# expenses_control_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Configuration

Create a `.env` file in the project root based on `.env.example`:

```
cp .env.example .env
```

Set your Gemini API key and optionally a custom database file name.
The application loads these values at startup.

### Gemini Text Input

After configuring the API key you can cadastrar gastos descrevendo-os em
linguagem natural. Na tela de adição de despesa há um botão **Inserir por
Texto** que abre um campo para digitar frases como:

```
Comprei 5 pães de queijo no Zona Sul do Rio.
```

O Gemini retornará um JSON estruturado e o formulário será preenchido
automaticamente para revisão.

### Falha no scraping de notas fiscais

Quando a leitura direta da NFC-e pelo scraper falha, o aplicativo envia o
HTML obtido da nota fiscal para o Gemini, que extrai os dados no mesmo formato
JSON. Assim ainda é possível preencher a tela mesmo que o layout do site mude.
