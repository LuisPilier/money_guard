import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'home.dart'; // Importa tu pantalla Home aquí

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final SupabaseClient supabaseClient = Supabase.instance.client;

  Future<void> _iniciarSesion() async {
    final String usuario = _usuarioController.text;
    final String contrasena = _contrasenaController.text;

    final response = await supabaseClient
        .from('usuarios')
        .select()
        .eq('nombre_usuario', usuario)
        .single()
        .execute();

    final data = response.data;
    final error = response.error;

    if (error != null) {
      _mostrarDialogo('Error', 'Ocurrió un error al buscar el usuario.');
      return;
    }

    if (data == null) {
      _mostrarDialogo('Error', 'Usuario no encontrado.');
      return;
    }

    final String claveHash = data['clave_hash'];

    if (contrasena == claveHash) {
      var box = Hive.box('userBox');
      box.put('nombre_usuario', data['nombre_usuario']);
      box.put('correo', data['correo']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      _mostrarDialogo('Error', 'Contraseña incorrecta.');
    }
  }

  void _mostrarDialogo(String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5AB2FF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Iniciar Sesión',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.6,
          child: Image.asset(
            'assets/images/enter_otp_amico_1.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 10),
        _buildTextField('Usuario', 'Ingresa tu usuario', _usuarioController, context),
        SizedBox(height: 10),
        _buildTextField('Contraseña', 'Ingresa tu contraseña', _contrasenaController, context, obscureText: true),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextButton(
            onPressed: _iniciarSesion,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Acceder',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Acción al presionar el botón de ¿Todavía no tienes cuenta?
          },
          child: Text(
            '¿Todavía no tienes cuenta?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 2),
        TextButton(
          onPressed: () {
            // Acción al presionar el botón de Regístrate
          },
          child: Text(
            'Regístrate',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              decoration: TextDecoration.underline,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, BuildContext context, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFFB3B3B3),
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
