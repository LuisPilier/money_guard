import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/bottom_navigation_bar.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> _movimientosData = [];
  bool _isLoading = true;
  double _balancePromedio = 0.0;
  double _totalCreditos = 0.0;
  double _totalDebitos = 0.0;
  int _numMovimientos = 0; // Variable para el número de movimientos
  Map<String, double> _movimientosByCategory = {};

  @override
  void initState() {
    super.initState();
    _fetchMovimientos();
    _fetchBalances();
  }

  Future<void> _fetchMovimientos() async {
    var box = Hive.box('userBox');
    final int? userId = box.get('id_usuario') as int?;

    if (userId == null) {
      _showErrorDialog('ID de usuario no encontrado',
          'El ID del usuario no se encontró en la base de datos.');
      return;
    }

    final response = await _supabaseClient
        .rpc('movimientos_usuario', params: {'user_id': userId}).execute();

    if (response.error != null) {
      _showErrorDialog('Error al obtener movimientos', response.error!.message);
      return;
    }

    setState(() {
      _movimientosData = (response.data as List<dynamic>).map((item) {
        return {
          'fecha': item['fecha'],
          'monto': item['monto'].toString(),
          'tipo_movimiento_nombre': item['tipo_movimiento_nombre'],
          'tipo_gasto_nombre': item['tipo_gasto_nombre'],
        };
      }).toList();
      _isLoading = false;
      _numMovimientos = _movimientosData.length; // Actualiza el número de movimientos
      _updateMovimientosByCategory();
    });
  }

  void _updateMovimientosByCategory() {
    final Map<String, double> categoryTotals = {};

    for (var movimiento in _movimientosData) {
      final category = movimiento['tipo_movimiento_nombre'];
      final monto = double.tryParse(movimiento['monto']) ?? 0.0;

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + monto;
      } else {
        categoryTotals[category] = monto;
      }
    }

    setState(() {
      _movimientosByCategory = categoryTotals;
    });
  }

  Future<void> _fetchBalances() async {
    var box = Hive.box('userBox');
    final int? userId = box.get('id_usuario') as int?;

    if (userId == null) {
      _showErrorDialog('ID de usuario no encontrado',
          'El ID del usuario no se encontró en la base de datos.');
      return;
    }

    final response = await _supabaseClient
        .rpc('calcular_balances', params: {'user_id': userId}).execute();

    if (response.error != null) {
      _showErrorDialog('Error al obtener balances', response.error!.message);
      return;
    }

    final data = response.data as List<dynamic>;
    if (data.isNotEmpty) {
      setState(() {
        _totalCreditos =
            double.tryParse(data[0]['total_creditos'].toString()) ?? 0.0;
        _totalDebitos =
            double.tryParse(data[0]['total_debitos'].toString()) ?? 0.0;
        _balancePromedio =
            double.tryParse(data[0]['balance_promedio'].toString()) ?? 0.0;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('userBox');
    String? nombreUsuario = box.get('nombre_usuario', defaultValue: 'Invitado');

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFF5AB2FF),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(nombreUsuario, screenWidth),
              _buildBalanceCard(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Salud Financiera',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.055,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              _buildFinancialHealthCard(),
              
              _buildImportantDataCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildHeader(String? nombreUsuario, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: Color(0xE8FFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '¡Bienvenido, $nombreUsuario!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: screenWidth * 0.045,
                  color: Color(0xFF000000),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              radius: screenWidth * 0.08,
              backgroundImage:
                  AssetImage('assets/images/avatars_3_davatar_21.png'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Balance Promedio',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$ ${_balancePromedio.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: Color(0xFF319F28),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail('Ingresos',
                  '\$ ${_totalCreditos.toStringAsFixed(2)}', Color(0xFF319F28)),
              _buildBalanceDetail('Gastos',
                  '\$ ${_totalDebitos.toStringAsFixed(2)}', Color(0xFFF23838)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF000000),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialHealthCard() {
    // Calcula la salud financiera estimada
    double estimatedHealth = _balancePromedio > 0 ? (_balancePromedio / 1000) * 100 : 0.0; // Ajusta según tu lógica

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Balance ideal',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${estimatedHealth.toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: Color(0xFF319F28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantDataCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Datos Importantes',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 16),
          _buildImportantDataDetail('Saldo Total', '\$ ${(_totalCreditos - _totalDebitos).toStringAsFixed(2)}'),
          _buildImportantDataDetail('Número de Movimientos', _numMovimientos.toString()),
        ],
      ),
    );
  }

  Widget _buildImportantDataDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}
