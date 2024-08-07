import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import para Supabase
import 'package:hive/hive.dart'; // Import para Hive

import '../../components/bottom_navigation_bar.dart'; // Import para CustomBottomNavigationBar

class AdMovements extends StatefulWidget {
  @override
  _AdMovementsState createState() => _AdMovementsState();
}

class _AdMovementsState extends State<AdMovements> {
  String? _selectedMovement;
  String? _selectedExpense;
  final List<String> _movements = [];
  final List<String> _expenses = [];
  final Map<String, int> _movementIdMap = {};
  final Map<String, int> _expenseIdMap = {};
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovementTypes();
    _loadExpenseTypes();
  }

  Future<void> _loadMovementTypes() async {
    final response = await Supabase.instance.client
        .from('tipo_movimiento')
        .select()
        .execute();
    if (response.error == null) {
      final List<dynamic> data = response.data;
      setState(() {
        _movements.clear();
        _movementIdMap.clear();
        for (var item in data) {
          _movements.add(item['nombre']);
          _movementIdMap[item['nombre']] = item['id'];
        }
      });
    } else {
      print('Error fetching movement types: ${response.error!.message}');
    }
  }

  Future<void> _loadExpenseTypes() async {
    final response = await Supabase.instance.client
        .from('tipo_gasto')
        .select()
        .execute();
    if (response.error == null) {
      final List<dynamic> data = response.data;
      setState(() {
        _expenses.clear();
        _expenseIdMap.clear();
        for (var item in data) {
          _expenses.add(item['nombre']);
          _expenseIdMap[item['nombre']] = item['id'];
        }
      });
    } else {
      print('Error fetching expense types: ${response.error!.message}');
    }
  }

  Future<void> _insertMovement() async {
    var box = Hive.box('userBox');
    final int? userId = box.get('id_usuario') as int?;

    if (_selectedMovement == null ||
        _selectedExpense == null ||
        _amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        userId == null) {
      print('Please fill in all fields.');
      return;
    }

    final movementTypeId = _movementIdMap[_selectedMovement!];
    final expenseTypeId = _expenseIdMap[_selectedExpense!];
    final amount = int.tryParse(_amountController.text);
    final description = _descriptionController.text;

    final response = await Supabase.instance.client
        .from('movimientos')
        .insert([
          {
            'tipo_movimiento_id': movementTypeId,
            'tipo_gasto_id': expenseTypeId,
            'monto': amount,
            'descripcion': description,
            'usuario_id': userId,
          },
        ])
        .execute();

    if (response.error == null) {
      _showSuccessDialog();
    } else {
      print('Error inserting movement: ${response.error!.message}');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¡Éxito!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(height: 16),
              Text('El movimiento se registró correctamente.', style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF5AB2FF),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registro de movimiento',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/images/avatars_3_davatar_21.png'),
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildDropdownSection('Movimiento', _selectedMovement, _movements, (value) {
                        setState(() {
                          _selectedMovement = value;
                        });
                      }),
                      _buildDropdownSection('Gasto', _selectedExpense, _expenses, (value) {
                        setState(() {
                          _selectedExpense = value;
                        });
                      }),
                      _buildTextField('Monto', 'Ingresa el monto', _amountController),
                      _buildTextField('Descripción', 'Ingresa la descripción', _descriptionController),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _insertMovement,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            primary: Colors.white,
                            onPrimary: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            minimumSize: Size(150, 48),
                            side: BorderSide.none,
                          ),
                          child: Text(
                            'Confirmar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildDropdownSection(String label, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, // Cambiado a negrita
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                hint: Text(
                  'Selecciona una opción',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF7D7D7D),
                  ),
                ),
                isExpanded: true,
                onChanged: onChanged,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hintText, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, // Cambiado a negrita
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFFB3B3B3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
