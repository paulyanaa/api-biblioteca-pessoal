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
      final host = env['DB_HOST'] ?? 'aws-1-us-east-2.pooler.supabase.com';
      final port = 6543;
      final db   = env['DB_NAME'] ?? 'postgres';
      final user = env['DB_USER'] ?? 'postgres.zyuffpdceibvhkkrhnhb';
      final pass = env['DB_PASSWORD'] ?? 'Pauly20122000!';

      _conn = PostgreSQLConnection(host, port, db, username: user, password: pass);
      await _conn!.open();
    }
    return _conn!;
  }
}
