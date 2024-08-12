import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  final SupabaseClient supabaseClient = Supabase.instance.client;
  bool _isLoading = false;

  /// Registra un nuevo usuario en la base de datos.
  Future<void> _registrarUsuario() async {
    final String usuario = _usuarioController.text.trim();
    final String correo = _correoController.text.trim();
    final String contrasena = _contrasenaController.text.trim();
    final String confirmarContrasena = _confirmarContrasenaController.text.trim();

    if (usuario.isEmpty || correo.isEmpty || contrasena.isEmpty || confirmarContrasena.isEmpty) {
      _mostrarDialogo('Error', 'Por favor, completa todos los campos.', Icons.error);
      return;
    }

    if (contrasena != confirmarContrasena) {
      _mostrarDialogo('Error', 'Las contraseñas no coinciden.', Icons.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final existingUserResponse = await supabaseClient
        .from('usuarios')
        .select('id')
        .eq('nombre_usuario', usuario)
        .execute();

    if (existingUserResponse.data.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      _mostrarDialogo('Error', 'El nombre de usuario ya existe.', Icons.error);
      return;
    }

    final response = await supabaseClient
        .from('usuarios')
        .insert({
          'nombre_usuario': usuario,
          'correo': correo,
          'clave_hash': contrasena,
        })
        .execute();

    setState(() {
      _isLoading = false;
    });

    final error = response.error;

    if (error != null) {
      _mostrarDialogo('Error', 'Ocurrió un error al registrar el usuario: ${error.message}', Icons.error);
      return;
    }

    _mostrarDialogo('Éxito', 'Usuario registrado exitosamente.', Icons.check_circle, isSuccess: true);
  }

  /// Muestra un diálogo con un mensaje e ícono.
  void _mostrarDialogo(String titulo, String contenido, IconData icono, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icono, color: Colors.blue),
              SizedBox(width: 10),
              Text(titulo),
            ],
          ),
          content: Text(contenido),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.pop(context); // Regresa a la pantalla de inicio de sesión después de registrarse
                }
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

  /// Construye el contenido de la pantalla de registro.
  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Text(
          'Registro',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        _buildTextField('Usuario', 'Ingresa tu usuario', _usuarioController),
        SizedBox(height: 20),
        _buildTextField('Correo', 'Ingresa tu correo', _correoController),
        SizedBox(height: 20),
        _buildTextField('Contraseña', 'Ingresa tu contraseña', _contrasenaController, obscureText: true),
        SizedBox(height: 20),
        _buildTextField('Confirmar Contraseña', 'Confirma tu contraseña', _confirmarContrasenaController, obscureText: true),
        SizedBox(height: 30),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: _isLoading ? null : _registrarUsuario,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.black)
                : Text(
                    'Registrar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Construye un campo de texto personalizado.
  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
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
              fontSize: 14,
              color: Color(0xFF333333),
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
