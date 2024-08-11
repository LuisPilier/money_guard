import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/bottom_navigation_bar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<Map<String, dynamic>> _movimientosData = [];
  bool _isLoading = true;
  double _balancePromedio = 0.0;
  double _totalCreditos = 0.0;
  double _totalDebitos = 0.0;

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
          'descripcion' : item['descripcion']
        };
      }).toList();
      _isLoading = false;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(nombreUsuario, screenWidth),
              _buildBalanceCard(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Movimientos',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.055,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
              Expanded(
                child: _buildMovementsList(),
              ),
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

  Widget _buildMovementsList() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFB3E5FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
            : ListView.builder(
                itemCount: _movimientosData.length,
                itemBuilder: (context, index) {
                  final item = _movimientosData[index];
                  return _buildMovementItem(
                    item['monto'],
                    _formatDate(item['fecha']),
                    item['tipo_movimiento_nombre'],
                    item['tipo_gasto_nombre'],
                    _getIconPath(item['tipo_movimiento_nombre']),
                    item['descripcion']
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMovementItem(String amount, String date, String title,
      String tipoGastoNombre, String iconPath, String descripcion) {
    final isDebit = tipoGastoNombre == 'Débito';
    final amountColor = isDebit ? Color(0xFFF23838) : Color(0xFF319F28);
    final amountPrefix = isDebit ? '- ' : '+ ';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 3))
        ],
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          iconPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 4), // Adds spacing between the title and the subtitle
            Text(
              descripcion,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF8F8F8F),
              ),
            ),
          ],
        ),
        subtitle: Text(
          date,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF8F8F8F),
          ),
        ),
        trailing: Text(
          '$amountPrefix$amount',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: amountColor,
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _getIconPath(String tipoMovimientoNombre) {
    final iconPaths = {
      'Comida': 'assets/images/icon_19_x2.svg',
      'Compras Online': 'assets/images/icon_7_x2.svg',
      'Servicios': 'assets/images/icon_11_x2.svg',
      'Pago Nomina': 'assets/images/icon_28_x2.svg',
    };

    return iconPaths[tipoMovimientoNombre] ?? 'assets/icons/default_icon.svg';
  }
}
