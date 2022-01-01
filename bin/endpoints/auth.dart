import 'dart:convert';

import 'package:firebase_dart/auth.dart';
import 'package:firebase_dart/core.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import '../configuration.dart';

class Authentication {
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

  Future<List> registerUser({
    String? username,
    String? password,
    FirebaseAuth? auth,
  }) async {
    try {
      var userCredential = await auth!.createUserWithEmailAndPassword(
        email: '$username@doit.com'.toLowerCase(),
        password: password!,
      );

      return [
        1,
        json.encode({
          'username': username,
          'uid': userCredential.user!.uid,
          'message': 'User created'
        })
      ];
    } on FirebaseAuthException catch (e) {
      print(e.code);
      switch (e.code) {
        case 'weak-password':
          return [
            0,
            json.encode({'error': e.message})
          ];

        case 'internal-error':
          return [
            0,
            json.encode({'error': e.message})
          ];

        default:
          return [
            0,
            json.encode({'error': e.message})
          ];
      }
    } on Exception catch (e) {
      print('Exception: $e');
      return [
        0,
        json.encode({'error': e.toString()})
      ];
    }
  }

  Future loginUser({
    String? username,
    String? password,
    FirebaseAuth? auth,
  }) async {
    try {
      var userCredential = await auth!.signInWithEmailAndPassword(
        email: '$username@doit.com',
        password: password!,
      );

      return [
        1,
        json.encode({
          'username': username,
          'uid': userCredential.user!.uid,
          'message': 'User logged in'
        })
      ];
    } on FirebaseAuthException catch (e) {
      print(e.code);
      switch (e.code) {
        case 'wrong-password':
          return [
            0,
            json.encode({'error': e.message})
          ];

        case 'user-not-found':
          return [
            0,
            json.encode({'error': e.message})
          ];

        case 'internal-error':
          return [
            0,
            json.encode({'error': e.message})
          ];

        default:
          return [
            0,
            json.encode({'error': e.message})
          ];
      }
    }
  }

  Handler get handler {
    var router = Router();

    router.post('/register', (Request request) async {
      var payloadData = await request.readAsString();
      if (payloadData.isEmpty) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'No data found'}),
            headers: {'Content-Type': 'application/json'});
      }

      final payload = json.decode(payloadData);
      String? username = payload['username'];
      String? password = payload['password'];

      if (username == null || password == null) {
        return Response.notFound(
            json.encode({'error': 'Missing username or password'}),
            headers: {'content-type': 'application/json'});
      } else if (username.contains(' ')) {
        return Response.forbidden(
            json.encode({'error': 'Username cannot contain spaces'}),
            headers: {'content-type': 'application/json'});
      }

      var app = await initApp();
      var auth = FirebaseAuth.instanceFor(app: app);

      var response = await registerUser(
        username: username,
        password: password,
        auth: auth,
      );

      if (response[0] == 0) {
        return Response.notFound(response[1],
            headers: {'content-type': 'application/json'});
      } else {
        return Response.ok(response[1],
            headers: {'content-type': 'application/json'});
      }
    });

    router.post('/login', (Request request) async {
      var projectData = await request.readAsString();
      if (projectData.isEmpty) {
        return Response.notFound(
            jsonEncode({'success': false, 'error': 'No data found'}),
            headers: {'Content-Type': 'application/json'});
      }
      final payload = json.decode(projectData);
      String? username = payload['username'];
      String? password = payload['password'];

      if (username == null || password == null) {
        return Response.notFound(
            json.encode({'error': 'Missing username or password'}),
            headers: {'content-type': 'application/json'});
      } else if (username.contains(' ')) {
        return Response.forbidden(
            json.encode({'error': 'Username cannot contain spaces'}),
            headers: {'content-type': 'application/json'});
      }

      var app = await initApp();
      var auth = FirebaseAuth.instanceFor(app: app);

      var response =
          await loginUser(username: username, password: password, auth: auth);

      if (response[0] == 0) {
        return Response.notFound(response[1],
            headers: {'content-type': 'application/json'});
      } else {
        return Response.ok(response[1],
            headers: {'content-type': 'application/json'});
      }
    });

    return router;
  }
}
