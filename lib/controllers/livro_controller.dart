import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/livro.dart';
import '../models/emprestimo.dart';
import '../repositories/livro_repository.dart';
import '../models/status_leitura.dart';

class LivroController {
  final LivroRepository _repo = LivroRepository();

  Future<Response> adicionar(Request req) async {
    final payload = await req.readAsString();
    final data = jsonDecode(payload);

    final livro = Livro(
      id: data['id'],
      titulo: data['titulo'],
      autor: data['autor'],
      capaUrl: data['capaUrl'],
      categoria: data['categoria'],
      status: StatusLeituraExtension.fromString(data['status']) ?? StatusLeitura.naoLido,
      anotacoes: data['anotacoes'],
      avaliacao: data['avaliacao'] != null ? (data['avaliacao'] as num).toDouble() : null,
      emprestimo: data['emprestimo'] != null ? Emprestimo.fromJson(data['emprestimo']) : null,
    );

    await _repo.adicionar(livro);
    return Response.ok(jsonEncode({'message': 'Livro adicionado'}),
        headers: {'Content-Type': 'application/json'});
  }

  // <<-- AQUI: virou async e aguarda o SELECT do Postgres
  Future<Response> listarTodos(Request req) async {
    final lista = await _repo.listarTodos();
    final jsonList = lista.map((l) => l.toJson()).toList();
    return Response.ok(jsonEncode(jsonList),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> buscarPorId(Request req, String idStr) async {
    final id = int.tryParse(idStr);
    if (id == null) {
      return Response(400,
          body: jsonEncode({'error': 'ID inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final livro = await _repo.buscarPorId(id);
    if (livro == null) {
      return Response.notFound(jsonEncode({'error': 'Livro não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(livro.toJson()),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> atualizar(Request req, String idStr) async {
    final id = int.tryParse(idStr);
    if (id == null) {
      return Response(400,
          body: jsonEncode({'error': 'ID inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final payload = await req.readAsString();
    final data = jsonDecode(payload);

    final novoLivro = Livro(
      id: id,
      titulo: data['titulo'],
      autor: data['autor'],
      capaUrl: data['capaUrl'],
      categoria: data['categoria'],
      status: StatusLeituraExtension.fromString(data['status']) ?? StatusLeitura.naoLido,
      anotacoes: data['anotacoes'],
      avaliacao: data['avaliacao'] != null ? (data['avaliacao'] as num).toDouble() : null,
      emprestimo: data['emprestimo'] != null ? Emprestimo.fromJson(data['emprestimo']) : null,
    );

    final ok = await _repo.atualizar(id, novoLivro);
    if (!ok) {
      return Response.notFound(jsonEncode({'error': 'Livro não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode({'message': 'Livro atualizado'}),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> remover(Request req, String idStr) async {
    final id = int.tryParse(idStr);
    if (id == null) {
      return Response(400,
          body: jsonEncode({'error': 'ID inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final ok = await _repo.remover(id);
    if (!ok) {
      return Response.notFound(jsonEncode({'error': 'Livro não encontrado'}),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode({'message': 'Livro removido'}),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> emprestar(Request req, String idStr) async {
  final id = int.tryParse(idStr);
  if (id == null) {
    return Response(400,
        body: jsonEncode({'error': 'ID inválido'}),
        headers: {'Content-Type': 'application/json'});
  }

  final payload = await req.readAsString();
  final data = jsonDecode(payload);

  final emprestimo = Emprestimo(
    id: null,
    nomePessoa: data['nomePessoa'], // novo campo
    dataEmprestimo: DateTime.parse(data['dataEmprestimo']),
    dataDevolucao: data['dataDevolucao'] != null
        ? DateTime.parse(data['dataDevolucao'])
        : null,
  );

  final ok = await _repo.emprestar(id, emprestimo);

  if (!ok) {
    return Response.notFound(
        jsonEncode({'error': 'Livro não encontrado'}),
        headers: {'Content-Type': 'application/json'});
  }

  return Response.ok(
      jsonEncode({'message': 'Livro emprestado com sucesso'}),
      headers: {'Content-Type': 'application/json'});
  }
}
