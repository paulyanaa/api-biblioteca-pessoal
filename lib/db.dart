// lib/db.dart
import 'dart:io';
import 'package:postgres/postgres.dart';

class Db {
  Db._();
  static final Db instance = Db._();

  PostgreSQLConnection? _conn;

  Future<PostgreSQLConnection> get connection async {
    if (_conn == null || _conn!.isClosed) {
      final env = Platform.environment;
      final host = env['DB_HOST'] ?? 'localhost';
      final port = 5050;
      final db   = env['DB_NAME'] ?? 'minhaEstante';
      final user = env['DB_USER'] ?? 'postgres';
      final pass = env['DB_PASSWORD'] ?? 'postgres';

      _conn = PostgreSQLConnection(host, port, db, username: user, password: pass);
      await _conn!.open();
    }
    return _conn!;
  }
}
