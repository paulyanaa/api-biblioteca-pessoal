import 'dart:convert';
import 'package:postgres/postgres.dart';
import '../db.dart';
import '../models/livro.dart';
import '../models/emprestimo.dart';
import '../models/status_leitura.dart';

class LivroRepository {
  // ----- Helpers -----

  double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  StatusLeitura _statusFromDb(dynamic value) {
    if (value is int) {
      switch (value) {
        case 1:
          return StatusLeitura.naoLido;
        case 2:
          return StatusLeitura.lendo;
        case 3:
          return StatusLeitura.lido;
        default:
          return StatusLeitura.naoLido;
      }
    } else if (value is String) {
      return StatusLeituraExtension.fromString(value) ?? StatusLeitura.naoLido;
    }
    return StatusLeitura.naoLido;
  }

  Livro fromRow(List<dynamic> row) {
    Emprestimo? emprestimo;
    final emprestimoId = row.length > 8 ? row[8] : null;

    return Livro(
      id: row[0] as int,
      titulo: row[1] as String,
      autor: row[2] as String,
      capaUrl: row[3] as String?,
      categoria: row[4] as String?,
      status: _statusFromDb(row[5]),
      anotacoes: row[6] as String?,
      avaliacao: parseDouble(row[7]),
      emprestimo: emprestimo,
    );
  }

  // ----- CRUD -----

  Future<List<Livro>> listarTodos() async {
    final conn = await Db.instance.connection;

    // Seleciona todos os livros e faz LEFT JOIN para trazer dados do empréstimo, se existir
    final result = await conn.query('''
        SELECT 
      l.id, l.titulo, l.autor, l.capaurl, l.categoria, l.statusleitura_id,
      l.anotacoes, l.avaliacao, l.emprestimo_id,
      e.nomepessoa, e.dataemprestimo, e.datadevolucao
    FROM public.livro l
    LEFT JOIN public.emprestimo e ON l.emprestimo_id = e.id
  ''');

    return result.map((row) {
      // Extrai dados do empréstimo
      Emprestimo? emprestimo;
      final emprestimoId = row[8];
      final nomePessoa = row[9];
      final dataEmprestimo = row[10];
      final dataDevolucao = row[11];

      if (emprestimoId != null &&
          nomePessoa != null &&
          dataEmprestimo != null) {
        emprestimo = Emprestimo(
          id: emprestimoId as int,
          nomePessoa: nomePessoa as String,
          dataEmprestimo: dataEmprestimo as DateTime,
          dataDevolucao: dataDevolucao as DateTime?,
        );
      }

      return Livro(
        id: row[0] as int,
        titulo: row[1] as String,
        autor: row[2] as String,
        capaUrl: row[3] as String?,
        categoria: row[4] as String?,
        status: _statusFromDb(row[5]),
        anotacoes: row[6] as String?,
        avaliacao: parseDouble(row[7]),
        emprestimo: emprestimo,
      );
    }).toList();
  }

  Future<void> adicionar(Livro livro) async {
    final conn = await Db.instance.connection;

    await conn.query(
      '''
      INSERT INTO public.livro
        (titulo, autor, capaurl, categoria, statusleitura_id, anotacoes, avaliacao, emprestimo_id)
      VALUES
        (@titulo, @autor, @capaurl, @categoria, @status_id, @anotacoes, @avaliacao, @emprestimo_id)
    ''',
      substitutionValues: {
        'titulo': livro.titulo,
        'autor': livro.autor,
        'capaurl': livro.capaUrl,
        'categoria': livro.categoria,
        'status_id': livro.status.index + 1,
        'anotacoes': livro.anotacoes,
        'avaliacao': livro.avaliacao,
        'emprestimo_id': livro.emprestimo?.id,
      },
    );
  }

  Future<Livro?> buscarPorId(int id) async {
    final conn = await Db.instance.connection;
    final result = await conn.query(
      '''
      SELECT l.id, l.titulo, l.autor, l.capaurl, l.categoria, l.statusleitura_id,
             l.anotacoes, l.avaliacao, l.emprestimo_id
      FROM public.livro l
      WHERE l.id=@id
      ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return fromRow(result.first);
  }

  Future<bool> atualizar(int id, Livro livro) async {
    final conn = await Db.instance.connection;
    final updated = await conn.execute(
      '''
      UPDATE public.livro SET
        titulo=@titulo,
        autor=@autor,
        capaurl=@capa_url,
        categoria=@categoria,
        statusleitura_id=@status_id,
        anotacoes=@anotacoes,
        avaliacao=@avaliacao,
        emprestimo_id=@emprestimo_id
      WHERE id=@id
    ''',
      substitutionValues: {
        'id': id,
        'titulo': livro.titulo,
        'autor': livro.autor,
        'capa_url': livro.capaUrl,
        'categoria': livro.categoria,
        'status_id': livro.status.index + 1,
        'anotacoes': livro.anotacoes,
        'avaliacao': livro.avaliacao,
        'emprestimo_id': livro.emprestimo?.id,
      },
    );

    return updated > 0;
  }

  Future<bool> remover(int id) async {
    final conn = await Db.instance.connection;
    final removed = await conn.execute(
      'DELETE FROM public.livro WHERE id=@id',
      substitutionValues: {'id': id},
    );
    return removed > 0;
  }

  Future<bool> emprestar(int livroId, Emprestimo emprestimo) async {
    final conn = await Db.instance.connection;

    // Verifica se o livro existe
    final livro = await buscarPorId(livroId);
    if (livro == null) return false;

    // Cria o empréstimo incluindo nomePessoa
    final result = await conn.query(
      '''
    INSERT INTO emprestimo (nomePessoa, dataEmprestimo, dataDevolucao)
    VALUES (@nomePessoa, @dataEmprestimo, @dataDevolucao)
    RETURNING id
  ''',
      substitutionValues: {
        'nomePessoa': emprestimo.nomePessoa,
        'dataEmprestimo': emprestimo.dataEmprestimo,
        'dataDevolucao': emprestimo.dataDevolucao,
      },
    );

    final emprestimoId = result.first[0] as int;

    // Atualiza o livro com o id do empréstimo
    await conn.execute(
      '''
    UPDATE livro
    SET emprestimo_id=@emprestimoId
    WHERE id=@livroId
  ''',
      substitutionValues: {'emprestimoId': emprestimoId, 'livroId': livroId},
    );

    return true;
  }
}
