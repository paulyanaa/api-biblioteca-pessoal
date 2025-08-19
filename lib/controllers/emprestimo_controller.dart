import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/emprestimo.dart';
import '../repositories/emprestimo_repository.dart';

class EmprestimoController {
  final EmprestimoRepository _repo = EmprestimoRepository();

  // CREATE
  Future<Response> adicionar(Request req) async {
    final payload = await req.readAsString();
    final data = jsonDecode(payload);

    final emprestimo = Emprestimo(
      nomePessoa: data['nomePessoa'], // novo campo
      dataEmprestimo: DateTime.parse(data['dataEmprestimo']),
      dataDevolucao: data['dataDevolucao'] != null
          ? DateTime.parse(data['dataDevolucao'])
          : null,
    );

    _repo.adicionar(emprestimo);
    return Response.ok(jsonEncode({'message': 'Empréstimo adicionado'}));
  }

  // READ
  Response listarTodos(Request req) {
    final lista = _repo.listarTodos();
    final jsonList = lista.map((e) => e.toJson()).toList();
    return Response.ok(jsonEncode(jsonList));
  }

  Response buscarPorId(Request req, int id) {
    final emprestimo = _repo.buscarPorId(id);
    if (emprestimo == null) {
      return Response.notFound(
        jsonEncode({'error': 'Empréstimo não encontrado'}),
      );
    }
    return Response.ok(jsonEncode(emprestimo.toJson()));
  }

  // UPDATE
  Future<Response> atualizar(Request req, int id) async {
    final payload = await req.readAsString();
    final data = jsonDecode(payload);

    final novoEmprestimo = Emprestimo(
      id: id,
      nomePessoa: data['nomePessoa'], // novo campo
      dataEmprestimo: DateTime.parse(data['dataEmprestimo']),
      dataDevolucao: data['dataDevolucao'] != null
          ? DateTime.parse(data['dataDevolucao'])
          : null,
    );

    final atualizado = _repo.atualizar(id, novoEmprestimo);
    if (!atualizado) {
      return Response.notFound(
        jsonEncode({'error': 'Empréstimo não encontrado'}),
      );
    }

    return Response.ok(jsonEncode({'message': 'Empréstimo atualizado'}));
  }

  // DELETE
  Response remover(Request req, int id) {
    final removido = _repo.remover(id);
    if (!removido) {
      return Response.notFound(
        jsonEncode({'error': 'Empréstimo não encontrado'}),
      );
    }
    return Response.ok(jsonEncode({'message': 'Empréstimo removido'}));
  }
}
