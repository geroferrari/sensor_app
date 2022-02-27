// ignore_for_file: prefer_collection_literals, avoid_print
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:scoped_model/scoped_model.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription _subscription;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  String deviceName = "Multi-Sensor";

  String uuidBatteryService = "f000180f-0451-4000-b000-000000000000";
  String uuidBatteryCharacteristic = "f0002a19-0451-4000-b000-000000000000";
  String uuidHumidityService = "f000aa20-0451-4000-b000-000000000000";
  String uuidHumidityCharacteristic = "f000aa21-0451-4000-b000-000000000000";

  //Change for FLOW UUID //
  String uuidFlowService = "f000aa20-0451-4000-b000-000000000000";
  String uuidFlowCharacteristic = "f000aa21-0451-4000-b000-000000000000";

  //change for net UUID //
  String uuidNetService = "f0001110-0451-4000-b000-000000000000";
  String uuidNetCharacteristic = "f0001111-0451-4000-b000-000000000000";

  //change for PIN UUID //
  String uuidValveService = "f0001110-0451-4000-b000-000000000000";
  String uuidValveCharacteristic = "f0001112-0451-4000-b000-000000000000";

  late int battery;
  late int humidity;
  int flow = 0;
  String printMessage = "Bienvenido, Presione el boton CONECTAR";

  void _disconnect() async {
    _subscription.cancel();
    if (_connection != null) {
      await _connection.cancel();
    }
  }

  void _connectBLE() {
    setState(() {
      printMessage = 'Estado: Buscando dispositivos...';
    });
    _disconnect();
    _subscription = _ble.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
        requireLocationServicesEnabled: true).listen((device) {
      if (device.name == deviceName) {
        print('Nodo encontrado!');
        _connection = _ble
            .connectToDevice(
          id: device.id,
        )
            .listen((connectionState) async {
          // Handle connection state updates
          print('connection state:');
          print(connectionState.connectionState);
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            printMessage = "Estado: Nodo conectado";
            //Battery Characteristics
            final batteryCharacteristic = QualifiedCharacteristic(
                serviceId: Uuid.parse(uuidBatteryService),
                characteristicId: Uuid.parse(uuidBatteryCharacteristic),
                deviceId: device.id);
            final batteryResponse =
                await _ble.readCharacteristic(batteryCharacteristic);
            print(batteryResponse);
            //humidiy characteristics
            final humidityCharacteristic = QualifiedCharacteristic(
                serviceId: Uuid.parse(uuidHumidityService),
                characteristicId: Uuid.parse(uuidHumidityCharacteristic),
                deviceId: device.id);
            final humidityResponse =
                await _ble.readCharacteristic(humidityCharacteristic);
            print(humidityCharacteristic);
            //Flow characteristics
            final flowCharacteristic = QualifiedCharacteristic(
                serviceId: Uuid.parse(uuidFlowService),
                characteristicId: Uuid.parse(uuidFlowCharacteristic),
                deviceId: device.id);
            final flowResponse =
                await _ble.readCharacteristic(flowCharacteristic);
            print(flowCharacteristic);
            setState(() {
              battery = batteryResponse[0];
              humidity = humidityResponse[0];
              flow = flowResponse[0];
            });
            _disconnect();
            print('disconnected');
          }
        }, onError: (dynamic error) {
          // Handle a possible error
          print(error.toString());
        });
      }
    }, onError: (error) {
      print('error!');
      print(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nodo APP'),
        ),
        body: ListView(children: <Widget>[
          ListTile(
            title: Text(printMessage),
          ),
          const Divider(),
          ListTile(
            title: const Text('Conectarse con el Nodo'),
            trailing: ElevatedButton(
                onPressed: _connectBLE,
                child: const Text('Conectar'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent,
                )),
          ),
          ListTile(
            title: const Text('Nombre del dispositivo'),
            subtitle: Text(deviceName),
            onLongPress: null,
          ),
          const Divider(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    children: [
                      Text("Información del Nodo",
                          style: TextStyle(
                              fontSize: 35, color: Colors.green.shade900)),
                    ],
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center //Center Row contents vertically,
                    ),
                const SizedBox(height: 30),
                Row(
                    children: [
                      if (printMessage == "Estado: Nodo conectado") ...[
                        const Icon(
                          Icons.water_damage_outlined,
                          color: Colors.greenAccent,
                          size: 28,
                        ),
                        Text("Humedad actual: " + humidity.toString(),
                            style: const TextStyle(
                                fontSize: 28, color: Colors.greenAccent))
                      ] else ...[
                        const Text("Indefinido")
                      ]
                    ],
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center //Center Row contents vertically,
                    ),
                const SizedBox(height: 20),
                Row(
                    children: [
                      if (printMessage == "Estado: Nodo conectado") ...[
                        const Icon(Icons.battery_charging_full_rounded,
                            color: Colors.greenAccent, size: 28),
                        Text("Bateria actual: " + battery.toString(),
                            style: const TextStyle(
                                fontSize: 28, color: Colors.greenAccent)),
                      ] else ...[
                        const Text("Indefinido")
                      ]
                    ],
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center //Center Row contents vertically,
                    ),
                const SizedBox(height: 20),
                Row(
                    children: [
                      if (printMessage == "Estado: Nodo conectado") ...[
                        const Icon(
                          Icons.water_outlined,
                          color: Colors.greenAccent,
                          size: 28,
                        ),
                        Text("Caudal actual: " + flow.toString(),
                            style: const TextStyle(
                                fontSize: 28, color: Colors.greenAccent))
                      ] else ...[
                        const Text("Indefinido")
                      ]
                    ],
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center //Center Row contents vertically,
                    ),
                const SizedBox(height: 20),
                Row(
                    children: [
                      if (printMessage == "Estado: Nodo conectado") ...[
                        const Icon(
                          Icons.connect_without_contact_outlined,
                          color: Colors.greenAccent,
                          size: 28,
                        ),
                        const Text("Agregar a la red ",
                            style: TextStyle(
                                fontSize: 28, color: Colors.greenAccent)),
                        ElevatedButton(
                            onPressed: _connectBLE,
                            child: const Text('Conectar'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.greenAccent,
                            ))
                      ] else ...[
                        const Text("Indefinido")
                      ]
                    ],
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center //Center Row contents vertically,
                    ),
                const SizedBox(height: 20),
                Row(
                    children: [
                      if (printMessage == "Estado: Nodo conectado") ...[
                        const Icon(
                          Icons.connect_without_contact_outlined,
                          color: Colors.greenAccent,
                          size: 28,
                        ),
                        const Text("Encender Riego ",
                            style: TextStyle(
                                fontSize: 28, color: Colors.greenAccent)),
                        ElevatedButton(
                            onPressed: _connectBLE,
                            child: const Text('Encender'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.greenAccent,
                            ))
                      ] else ...[
                        const Text("Indefinido")
                      ]
                    ],
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center //Center Row contents vertically,
                    ),
              ],
            ),
          )
        ]));
  }
}
