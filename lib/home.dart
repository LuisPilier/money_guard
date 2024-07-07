import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('userBox');
    String nombreUsuario = box.get('nombre_usuario', defaultValue: 'Usuario');
    String correo = box.get('correo', defaultValue: 'Correo');

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nombre de Usuario: $nombreUsuario',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Correo: $correo',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
