import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/emprestimo_controller.dart';
import '../controllers/livro_controller.dart';

class AppRoutes {
  final _emprestimoController = EmprestimoController();
  final _livroController = LivroController();

  Router get router {
    final router = Router();

    // Rota de teste
    router.get('/ping', (Request req) => Response.ok('pong'));

    // Empréstimos
    router.post('/emprestimos', _emprestimoController.adicionar);
    router.get('/emprestimos', _emprestimoController.listarTodos);
    router.get('/emprestimos/<id>', _emprestimoController.buscarPorId);
    router.put('/emprestimos/<nomePessoa>', _emprestimoController.atualizar);
    router.delete('/emprestimos/<nomePessoa>', _emprestimoController.remover);

    // Livros
    router.post('/livros', _livroController.adicionar);
    router.get('/livros', _livroController.listarTodos);
    router.get('/livros/<id>', _livroController.buscarPorId);
    router.put('/livros/<id>', _livroController.atualizar);
    router.delete('/livros/<id>', _livroController.remover);

    // Emprestar o livro
    router.post('/livros/<id>/emprestar', _livroController.emprestar);

    return router;
  }
}
