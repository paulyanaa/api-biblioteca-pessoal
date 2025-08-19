import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:api_biblioteca_pessoal/routes/routes.dart';

void main(List<String> arguments) async {
  final appRoutes = AppRoutes();

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(appRoutes.router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Servidor rodando em http://${server.address.host}:${server.port}');
}