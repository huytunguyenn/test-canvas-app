import 'package:flutter/material.dart';

import 'scenes/dashboard_scene.dart';
import 'scenes/home_scene.dart';
import 'scenes/login_scene.dart';
import 'scenes/scene.dart';
import 'widgets/remote_canvas.dart';

void main() {
  runApp(const CanvasTestApp());
}

class CanvasTestApp extends StatelessWidget {
  const CanvasTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas Test App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const CanvasShell(),
    );
  }
}

class CanvasShell extends StatefulWidget {
  const CanvasShell({super.key});

  @override
  State<CanvasShell> createState() => _CanvasShellState();
}

class _CanvasShellState extends State<CanvasShell> {
  String _currentScene = 'home';
  final Map<String, Scene> _sceneCache = {};

  Scene _getScene(String name) {
    return _sceneCache.putIfAbsent(name, () => _createScene(name));
  }

  Scene _createScene(String name) {
    switch (name) {
      case 'login':
        return LoginScene(onNavigate: _navigate);
      case 'dashboard':
        return DashboardScene(onNavigate: _navigate);
      default:
        return HomeScene(onNavigate: _navigate);
    }
  }

  void _navigate(String sceneName) {
    setState(() {
      _currentScene = sceneName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RemoteCanvas(scene: _getScene(_currentScene)),
    );
  }
}
