String normalizeText(String input) {
  const map = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'Á': 'a',
    'À': 'a',
    'Â': 'a',
    'Ã': 'a',
    'Ä': 'a',
    'É': 'e',
    'È': 'e',
    'Ê': 'e',
    'Ë': 'e',
    'Í': 'i',
    'Ì': 'i',
    'Î': 'i',
    'Ï': 'i',
    'Ó': 'o',
    'Ò': 'o',
    'Ô': 'o',
    'Õ': 'o',
    'Ö': 'o',
    'Ú': 'u',
    'Ù': 'u',
    'Û': 'u',
    'Ü': 'u',
    'Ç': 'c',
  };

  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final mapped = map[char] ?? char.toLowerCase();
    if (RegExp(r'[a-z0-9 ]').hasMatch(mapped)) {
      buffer.write(mapped);
    } else if (mapped.trim().isEmpty) {
      buffer.write(' ');
    } else {
      buffer.write(mapped);
    }
  }

  final normalized =
      buffer.toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
  return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
}
