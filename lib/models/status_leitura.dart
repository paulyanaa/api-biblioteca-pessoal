enum StatusLeitura { lido, lendo, naoLido }

extension StatusLeituraExtension on StatusLeitura {
  String get label {
    switch (this) {
      case StatusLeitura.lido:
        return 'Lido';
      case StatusLeitura.lendo:
        return 'Lendo';
      case StatusLeitura.naoLido:
        return 'Não lido';
    }
  }

  static StatusLeitura fromString(String? value) {
    if (value == null) return StatusLeitura.naoLido;

    final normalized = value
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('á', 'a');
    switch (normalized) {
      case 'lido':
        return StatusLeitura.lido;
      case 'lendo':
        return StatusLeitura.lendo;
      case 'naolido':
        return StatusLeitura.naoLido;
      default:
        return StatusLeitura.naoLido;
    }
  }
}
