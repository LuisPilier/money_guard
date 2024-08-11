import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/bottom_navigation_bar.dart'; // Asegúrate de importar el archivo correcto

class Maintenance extends StatefulWidget {
  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  final SupabaseClient supabase =
      Supabase.instance.client; // Instancia de Supabase

  List<dynamic> _movimientos = [];
  List<dynamic> _tipoGasto = [];
  List<dynamic> _tipoMovimiento = [];
  String _errorMessage = '';
  int? _selectedTipoGastoId;
  int? _selectedTipoMovimientoId;

  @override
  void initState() {
    super.initState();
    _fetchMovimientos();
    _fetchTipoGasto();
    _fetchTipoMovimiento();
  }

  Future<void> _fetchMovimientos() async {
    try {
      final response = await supabase.from('movimientos').select().execute();

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error!.message;
        });
        return;
      }

      setState(() {
        _movimientos = response.data as List<dynamic>;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error al leer movimientos: $error';
      });
    }
  }

  Future<void> _fetchTipoGasto() async {
    try {
      final response = await supabase.from('tipo_gasto').select().execute();

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error!.message;
        });
        return;
      }

      setState(() {
        _tipoGasto = response.data as List<dynamic>;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error al leer tipo_gasto: $error';
      });
    }
  }

  Future<void> _fetchTipoMovimiento() async {
    try {
      final response =
          await supabase.from('tipo_movimiento').select().execute();

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error!.message;
        });
        return;
      }

      setState(() {
        _tipoMovimiento = response.data as List<dynamic>;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error al leer tipo_movimiento: $error';
      });
    }
  }

  Future<void> _updateMovimientos(
      int id, Map<String, dynamic> updatedData) async {
    try {
      final response = await supabase
          .from('movimientos')
          .update(updatedData)
          .eq('id', id)
          .select()
          .execute();

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error!.message;
        });
        return;
      }

      _fetchMovimientos(); // Refresca los datos después de la actualización
      _showConfirmationDialog('Movimiento actualizado con éxito.');
    } catch (error) {
      setState(() {
        _errorMessage = 'Error al actualizar movimiento: $error';
      });
    }
  }

  Future<void> _deleteMovimientos(int id) async {
    try {
      final response =
          await supabase.from('movimientos').delete().eq('id', id).execute();

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error!.message;
        });
        return;
      }

      _fetchMovimientos(); // Refresca los datos después de la eliminación
      _showConfirmationDialog('Movimiento eliminado con éxito.');
    } catch (error) {
      setState(() {
        _errorMessage = 'Error al eliminar movimiento: $error';
      });
    }
  }

  void _showEditDialog(int id, Map<String, dynamic> movimiento) {
    final _descripcionController =
        TextEditingController(text: movimiento['descripcion']);
    final _montoController =
        TextEditingController(text: movimiento['monto'].toString());

    // Initialize dropdown values
    _selectedTipoGastoId = movimiento['tipo_gasto_id'];
    _selectedTipoMovimientoId = movimiento['tipo_movimiento_id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Movimiento',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                TextField(
                  controller: _montoController,
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedTipoGastoId,
                  items: _tipoGasto.map((tipoGasto) {
                    return DropdownMenuItem<int>(
                      value: tipoGasto['id'],
                      child: Text(tipoGasto['nombre'],
                          style: TextStyle(fontFamily: 'Poppins')),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Tipo Gasto'),
                  onChanged: (value) {
                    setState(() {
                      _selectedTipoGastoId = value;
                    });
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _selectedTipoMovimientoId,
                  items: _tipoMovimiento.map((tipoMovimiento) {
                    return DropdownMenuItem<int>(
                      value: tipoMovimiento['id'],
                      child: Text(tipoMovimiento['nombre'],
                          style: TextStyle(fontFamily: 'Poppins')),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Tipo Movimiento'),
                  onChanged: (value) {
                    setState(() {
                      _selectedTipoMovimientoId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            TextButton(
              onPressed: () {
                final updatedData = {
                  'descripcion': _descripcionController.text,
                  'monto': double.tryParse(_montoController.text) ??
                      0.0, // Convertir el monto a tipo numérico
                  'tipo_gasto_id': _selectedTipoGastoId,
                  'tipo_movimiento_id': _selectedTipoMovimientoId,
                };
                _updateMovimientos(id, updatedData);
                Navigator.of(context).pop();
              },
              child: Text(
                'Actualizar',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmación',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar Eliminación',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar este movimiento?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMovimientos(id);
              },
              child: Text(
                'Eliminar',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red),
              ),
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
        color: Color(0xFF5AB2FF), // Color de fondo agregado
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                    'Mantenimiento',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/images/avatars_3_davatar_21.png'),
                    radius: 24,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        _errorMessage,
                        style:
                            TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _movimientos.length,
                      itemBuilder: (context, index) {
                        final movimiento = _movimientos[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              movimiento['descripcion'],
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Monto: ${movimiento['monto'].toString()}',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(
                                      movimiento['id'], movimiento),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteConfirmation(movimiento['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(), // Componente personalizado de navegación
    );
  }
}
