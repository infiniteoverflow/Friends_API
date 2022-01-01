import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import 'auth.dart';
import 'friends.dart';

class Starter {
  Handler get handler {
    var router = Router();

    router.mount('/auth', Authentication().handler);
    router.mount('/friends', Friends().handler);

    return router;
  }
}