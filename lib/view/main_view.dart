import 'package:expenses_control_app/view/adicionar_gasto_view.dart';
import 'package:expenses_control_app/view/categoria_view.dart';
import 'package:expenses_control_app/view/dashboard_view.dart';
import 'package:expenses_control_app/view/gasto_view.dart';
import 'package:flutter/material.dart';
import 'package:expenses_control_app/view/extrato_view.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    ExtratoView(),
    DashboardView(),
    AdicionarGastoView(), 
    CategoriaView(),
  ];

  @override
Widget build(BuildContext context) {
   return Scaffold(
     body: IndexedStack(
       index: _selectedIndex,
       children: _screens,
     ),
     bottomNavigationBar: BottomNavigationBar(
       currentIndex: _selectedIndex,
       onTap: (index) {
         setState(() {
           _selectedIndex = index;
         });
       },
       items: [
         BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Extrato'),
         BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
         // Item do meio para adicionar despesa
         BottomNavigationBarItem(
           icon: Icon(Icons.add),
           label: 'Adicionar', // O protótipo HTML tem um label aqui
           backgroundColor: Colors.blue, // Propriedade de estilo do item
         ),
         BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Categorias'),
       ],
       selectedItemColor: Colors.blue,
       unselectedItemColor: Colors.grey,
       showSelectedLabels: true,
       showUnselectedLabels: true,
       type: BottomNavigationBarType.fixed,
     ),
   );
  }
}