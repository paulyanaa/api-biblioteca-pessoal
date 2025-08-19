import '../models/emprestimo.dart';

class EmprestimoRepository {
  final List<Emprestimo> _emprestimos = [];

  // CREATE
  void adicionar(Emprestimo emprestimo) {
    // Se o id for nulo, gera um id incremental
    final id = emprestimo.id ?? (_emprestimos.isNotEmpty ? _emprestimos.last.id! + 1 : 1);
    final novoEmprestimo = Emprestimo(
      id: id,
      nomePessoa: emprestimo.nomePessoa,
      dataEmprestimo: emprestimo.dataEmprestimo,
      dataDevolucao: emprestimo.dataDevolucao,
    );
    _emprestimos.add(novoEmprestimo);
  }

  // READ
  List<Emprestimo> listarTodos() => List.unmodifiable(_emprestimos);

  Emprestimo? buscarPorId(int id) {
  for (var e in _emprestimos) {
    if (e.id == id) {
      return e;
    }
  }
  return null; 
}

  // UPDATE
  bool atualizar(int id, Emprestimo emprestimoAtualizado) {
    final index = _emprestimos.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    _emprestimos[index] = emprestimoAtualizado;
    return true;
  }

   // DELETE
  bool remover(int id) {
    for (var e in _emprestimos) {
      if (e.id == id) {
        _emprestimos.remove(e);
        return true;
      }
    }
    return false;
  }
}
