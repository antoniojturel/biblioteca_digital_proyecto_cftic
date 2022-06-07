
import 'package:flutter/material.dart';

// Importamos Widgets personalizados
import 'package:biblioteca_digital_proyecto_cftic/widgets/widgets.dart';

import 'package:biblioteca_digital_proyecto_cftic/routes/app_routes.dart';

class Inicio extends StatelessWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //centerTitle: true,
        title: const Text('BIBLIOTECA ONLINE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Añadimos Menu Lateral
      endDrawer: const MenuLateral(),
        // Con GestureDetector podemos detectar cuando se hace click
      body: Card(
        child: ListView.separated(
          itemBuilder: (context, i) =>
            ListTile(
              leading: Icon(AppRoutes.menuOpciones[i].icono),
              title: Text(AppRoutes.menuOpciones[i].nombre),
                onTap: (){
                  Navigator.pushNamed(context, AppRoutes.menuOpciones[i].ruta);
                  //Navigator.pushNamed(context, '/BuscarAutor');
                },
            ),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: AppRoutes.menuOpciones.length,
        ),
      )
    );
  }
}

