import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Pantalla de inicio que muestra el nombre de usuario y correo electrónico obtenidos de Hive.
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Abre la caja de Hive donde se almacenan los datos del usuario.
    var box = Hive.box('userBox');

    // Obtiene el nombre de usuario y correo electrónico de la caja de Hive.
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
