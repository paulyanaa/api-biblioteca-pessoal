class Emprestimo {
  final int? id;
  final String nomePessoa;
  final DateTime dataEmprestimo;
  final DateTime? dataDevolucao;

  Emprestimo({
    this.id,
    required this.nomePessoa,
    required this.dataEmprestimo,
    this.dataDevolucao,
  });

  factory Emprestimo.fromJson(Map<String, dynamic> json) => Emprestimo(
    id: json['id'],
    nomePessoa: json['nomePessoa'],
    dataEmprestimo: DateTime.parse(json['dataEmprestimo']),
    dataDevolucao: json['dataDevolucao'] != null
        ? DateTime.parse(json['dataDevolucao'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomePessoa': nomePessoa,
    'dataEmprestimo': dataEmprestimo.toIso8601String(),
    'dataDevolucao': dataDevolucao?.toIso8601String(),
  };
}
