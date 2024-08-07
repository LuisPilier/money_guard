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
  bool _isLoading = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeHive();
  }

  /// Carga los datos desde Hive y los pone en los campos correspondientes.
  void _cargarDatosDesdeHive() {
    final box = Hive.box('userBox');
    final nombreUsuario = box.get('nombre_usuario', defaultValue: '');
    _usuarioController.text = nombreUsuario;

    // Verifica si existe un usuario en la base de datos de Hive
    setState(() {
      _isUserLoggedIn = nombreUsuario.isNotEmpty;
    });
  }

  /// Inicia sesión con el usuario y contraseña proporcionados.
  Future<void> _iniciarSesion() async {
    final String usuario = _usuarioController.text.trim();
    final String contrasena = _contrasenaController.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty) {
      _mostrarDialogo('Error', 'Por favor, ingresa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Realiza la consulta a la base de datos para obtener el usuario y su ID.
    final response = await supabaseClient
        .from('usuarios')
        .select('id, nombre_usuario, correo, clave_hash')
        .eq('nombre_usuario', usuario)
        .single()
        .execute();

    setState(() {
      _isLoading = false;
    });

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

    // Verifica la contraseña
    if (contrasena == claveHash) {
      var box = Hive.box('userBox');
      box.put('nombre_usuario', data['nombre_usuario']);
      box.put('correo', data['correo']);
      box.put('id_usuario', data['id']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      _mostrarDialogo('Error', 'Contraseña incorrecta.');
    }
  }

  /// Muestra un diálogo con un mensaje.
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

  /// Muestra un diálogo con un mensaje de éxito al desvincular la cuenta.
  void _mostrarDialogoDesvinculacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Text('Usuario desvinculado exitosamente.'),
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

  /// Limpia todos los datos almacenados en Hive.
  void _desvincularCuenta() {
    var box = Hive.box('userBox');
    box.clear(); // Limpia todos los datos almacenados en Hive
    _usuarioController.clear();
    _contrasenaController.clear();

    setState(() {
      _isUserLoggedIn = false; // Actualiza el estado para ocultar el botón 'Desvincular'
    });

    _mostrarDialogoDesvinculacion();
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

  /// Construye el contenido de la pantalla de inicio de sesión.
  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Text(
          'Iniciar Sesión',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.6,
          child: Image.asset(
            'assets/images/enter_otp_amico_1.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 20),
        _buildTextField('Usuario', 'Ingresa tu usuario', _usuarioController, context),
        SizedBox(height: 20),
        _buildTextField('Contraseña', 'Ingresa tu contraseña', _contrasenaController, context, obscureText: true),
        SizedBox(height: 20),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.5),
          ),
          child: TextButton(
            onPressed: _isLoading ? null : _iniciarSesion,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.black)
                : Text(
                    'Acceder',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {
            // Acción al presionar el botón de ¿Todavía no tienes cuenta?
          },
          child: Text(
            '¿Todavía no tienes cuenta?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
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
        SizedBox(height: 20),
        if (_isUserLoggedIn) // Muestra el botón solo si hay un usuario registrado
          ElevatedButton(
            onPressed: _desvincularCuenta,
            style: ElevatedButton.styleFrom(
              primary: Colors.red, // Color rojo para el botón
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Desvincular',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  /// Construye un campo de texto personalizado.
  Widget _buildTextField(String label, String hint, TextEditingController controller, BuildContext context, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 45,
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
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
