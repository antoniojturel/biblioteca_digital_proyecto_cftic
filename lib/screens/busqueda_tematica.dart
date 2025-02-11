
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

// Importar libreria para acceso documentos locales
import 'package:path_provider/path_provider.dart';

import 'dart:io';

// Importamos Widgets personalizados
import 'package:biblioteca_digital_proyecto_cftic/widgets/widgets.dart';


class BusquedaTematica extends StatefulWidget {
  // Se define ruta de PantallaLoginEmail
  const BusquedaTematica({Key? key}) : super(key: key);

  @override
  BusquedaTematicaState createState() => BusquedaTematicaState();
}

class BusquedaTematicaState extends State<BusquedaTematica> {
  final _dropdownFormKey = GlobalKey<FormState>();
  final TextEditingController busquedaController = TextEditingController();

  String valorseleccionado = "Programacion";

  final String urlbuscar = "https://apibiblioteca.azurewebsites.net/biblioteca/GetTematica/";
  String urlapi = "";
  // La variable data recupera los datos del webapi en una lista o coleccion
  List? data;

  // Para sacar URL de Imagen a mostrar
  String? downloadURL;
  // Referencia para Storage
  FirebaseStorage storageRefImagen = FirebaseStorage.instance;
  String collectionNameFile = "libros";
  FirebaseStorage storageRefLibro = FirebaseStorage.instance;
  String collectionNameImage = "portadas";

  String nombreimagen = "";
  String nombrefichero = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('BIBLIOTECA ONLINE',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }
          )
        ),
        endDrawer: const MenuLateral(),
        body: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text("Busqueda por Tematica",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ],
              ),
            Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 30, right: 10),
                    child: Form(
                      key: _dropdownFormKey,
                      // Llamo a Funcion Lista Desplegable
                          child: listaDesplegable(),
                      ),
                    ),
                ],
              ),
            Row(
              // Centra los elementos en la fila horizontalmente
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: BotonIconoAnimado(
                    accion: () {
                      //if (_dropdownFormKey.currentState!.validate()) {
                      getLibrosTematica(valorseleccionado);
                      //Acciones si el desplegable es correcto
                      //}
                    },
                    icono: Icons.search,
                    texto: 'Buscar',
                  ),
                ),
              ],
            ),
            // Añadimos Linea Divisoria
            const Divider(
              thickness: 5,
              color: Colors.brown,
            ),
            Expanded(
                child: listado()
            ),
              //Container(child: listado()),
          ]
        )
    );
  }

  // Generamos en Lista los elementos del menu desplegable
  List<DropdownMenuItem<String>> get elementosLista{
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          value: 'Programacion',
          child: Text('Programación')
      ),
      const DropdownMenuItem(
          value: 'Sistemas',
          child: Text('Sistemas')
      ),
      const DropdownMenuItem(
          value: 'Ciberseguridad',
          child: Text('Ciberseguridad')
      ),
      const DropdownMenuItem(
          value: 'Bases_Datos',
          child: Text('Bases de Datos')
      ),
      const DropdownMenuItem(
          value: 'Web',
          child: Text('Web')
      ),
    ];
    return menuItems;
  }

  DropdownButtonFormField<String> listaDesplegable() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      validator: (value) => value == null ? "Selecciona una Temática" : null,
      //dropdownColor: Colors.white60,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        //height: 8
      ),
      //icon: const Icon(Icons.flag),
      value: valorseleccionado,
      items: elementosLista,
      onChanged: (String? nuevovalor){
        setState(() {
          valorseleccionado = nuevovalor!;
        });
      },
    );
  }

  ListView listado() {
    return ListView.builder(
      // El numero de elementos será la longitud de la lista data
        itemCount: data == null ? 0 : data!.length,
        // Por cada registro recorro el json
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: const EdgeInsets.only(left:10.0, right:5.0),
              child: Column(
                children: [
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, right:10.0, top: 10),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                FutureBuilder(
                                  future: loadUbicacionImagen(data![index]["imagenPortada"]),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text("Something went wrong",);
                                    }
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return SizedBox(
                                        height: 80,
                                        width: 50,
                                        child: Image.network(
                                          snapshot.data.toString(),
                                        ),
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                ),
                              ]
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, right:5.0, top: 10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Alineamos en la columna los textos a la izquierda
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: <Widget>[
                                  Text(data![index]["titulo"],
                                      style: const TextStyle(
                                        fontSize: 14.0, color: Colors.black,)),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(data![index]["autor"],
                                      style: const TextStyle(
                                          fontSize: 14.0, color: Colors.black)),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(data![index]["tematica"],
                                      style: const TextStyle(
                                          fontSize: 14.0, color: Colors.grey)),
                                ],
                              ),
                            ]
                        ),
                      ),
                      // Usamos Spacer para que alinea la ultima fia a la derecha
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left:5.0, right:5.0, top: 10),
                        child: Column(
                          // Alineamos Icono en Fila despues de Datos
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                                icon: const Icon(Icons.download_rounded),
                                splashColor: Colors.brown,
                                // Al presionar en boton muestra dialogo de descarga
                              onPressed: () async {
                                nombrefichero = data![index]["urlDescarga"];
                                final url = await loadUbicacionFile(nombrefichero);
                                openFile(
                                  url,
                                  nombrefichero,
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Añadimos dentro la columna un segundo elemento el divider
                  const Padding(
                    padding: EdgeInsets.only(top:5.0),
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                ],
              )
          );
        }
    );
  }

  // Future para cargar URL segun nombre de fichero guardado
  Future loadUbicacionFile(nombrelibro) async {
    try {
      await downloadURLFile(nombrelibro);
      return downloadURL;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  // Future que recupera la URL de la Imagen
  Future<void> downloadURLFile(nombrelibro) async {
    downloadURL = await FirebaseStorage.instance
        .ref("libros")
        .child(nombrelibro)
        .getDownloadURL();
    debugPrint(downloadURL.toString());
  }

  Future openFile(String url, String nombrefichero) async {
    final file = await downloadFile(url,nombrefichero);
    if (file == null) return;
    OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url, String nombrefichero) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/$nombrefichero');
    try{
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: 0,
        ),
      );
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return file;
    } catch(e){
      return null;
    }
  }

  // Future para cargar URL segun nombre de fichero guardado
  Future loadUbicacionImagen(nombrefichero) async {
    try {
      await downloadURLImagen(nombrefichero);
      return downloadURL;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  // Future que recupera la URL de la Imagen
  Future<void> downloadURLImagen(nombrefichero) async {
    downloadURL = await FirebaseStorage.instance
        .ref("portadas")
        .child(nombrefichero)
        .getDownloadURL();
    debugPrint(downloadURL.toString());
  }

  // Generamos con Future funcion asincrona getDoctoresData
  // Tipo Future que devolvera un String (al ser consulta)
  Future<String> getLibrosTematica(String filtro) async {
    urlapi = "$urlbuscar$filtro";
    // Para poder usar await el metodo tiene que ser asincrono en el Future
    var res = await http.get(Uri.parse(urlapi), headers: {"Accept": "application/json"});
    int statusCode = res.statusCode;
    if (statusCode != 200){
      mensaje(context, 'No hay datos a mostrar');
    }
    // Entrara en SetState cuando haya obtenido los resultados
    setState(() {
      data = json.decode(res.body);
    });
    return "Realizado!";
  }

}

