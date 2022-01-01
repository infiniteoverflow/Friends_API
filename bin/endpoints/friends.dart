import 'dart:convert';

import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/database.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../configuration.dart';

class Friends {
  Future<FirebaseApp> initApp() async {
    late FirebaseApp app;

    try {
      app = Firebase.app();
    } catch (e) {
      app = await Firebase.initializeApp(
          options: FirebaseOptions.fromMap(Configurations.firebaseConfig));
    }

    return app;
  }

  Handler get handler {
    var router = Router();

    router.get('/all', (request) async {
      var app = await initApp();

      final db =
          FirebaseDatabase(app: app, databaseURL: Configurations.databaseUrl);
      final ref = db.reference().child('characters');

      var responseData;

      await ref.once().then((value) {
        responseData = value.value;
      });

      return Response.ok(json.encode(responseData),
          headers: {'content-type': 'application/json'});
    });

    router.post('/add', (Request request) async {
      var projectData = await request.readAsString();
      if (projectData.isEmpty) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'No data found'}),
            headers: {'Content-Type': 'application/json'});
      }
      final payload = jsonDecode(projectData);
      final name = payload['name'];
      final age = payload['age'];

      if (name == null) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'Missing name'}),
            headers: {'Content-Type': 'application/json'});
      } else if (age == null) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'Missing color'}),
            headers: {'Content-Type': 'application/json'});
      }

      final app = await initApp();
      final db =
          FirebaseDatabase(app: app, databaseURL: Configurations.databaseUrl);
      final ref = db.reference().child('characters');
      await ref.set({
        name: age,
      });

      return Response.ok(jsonEncode({'success': true}),
          headers: {'Content-Type': 'application/json'});
    });

    router.put('/update', (Request request) async {
      var projectData = await request.readAsString();
      if (projectData.isEmpty) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'No data found'}),
            headers: {'Content-Type': 'application/json'});
      }
      final payload = jsonDecode(projectData);
      final name = payload['name'];
      final age = payload['age'];

      if (name == null) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'Missing name'}),
            headers: {'Content-Type': 'application/json'});
      } else if (age == null) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'Missing color'}),
            headers: {'Content-Type': 'application/json'});
      }

      final app = await initApp();
      final db =
          FirebaseDatabase(app: app, databaseURL: Configurations.databaseUrl);
      final ref = db.reference().child('characters');
      await ref.update({
        name: age,
      });

      return Response.ok(jsonEncode({'success': true}),
          headers: {'Content-Type': 'application/json'});
    });

    router.delete('/delete', (Request request) async {
      var projectData = await request.readAsString();
      if (projectData.isEmpty) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'No data found'}),
            headers: {'Content-Type': 'application/json'});
      }
      final payload = jsonDecode(projectData);
      final name = payload['name'];

      if (name == null) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'Missing name'}),
            headers: {'Content-Type': 'application/json'});
      }

      final app = await initApp();
      final db =
          FirebaseDatabase(app: app, databaseURL: Configurations.databaseUrl);
      final ref = db.reference().child('characters');
      await ref.child(name).remove();

      return Response.ok(jsonEncode({'success': true}),
          headers: {'Content-Type': 'application/json'});
    });
    return router;
  }
}
