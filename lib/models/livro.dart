import 'emprestimo.dart';
import 'status_leitura.dart';

class Livro {
  final int? id;
  final String titulo;
  final String autor;
  final String? capaUrl;
  final String? categoria;
  final StatusLeitura status;
  final String? anotacoes;
  final double? avaliacao;
  final Emprestimo? emprestimo;

  Livro({
    this.id,
    required this.titulo,
    required this.autor,
    this.capaUrl,
    this.categoria,
    required this.status,
    this.anotacoes,
    this.avaliacao,
    this.emprestimo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'autor': autor,
        'capaUrl': capaUrl,
        'categoria': categoria,
        'status': status.label,
        'anotacoes': anotacoes,
        'avaliacao': avaliacao,
        'emprestimo': emprestimo?.toJson(),
      };
}
