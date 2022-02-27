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
  String deviceID = "";

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
  bool nodoConnectedToNet = false;
  bool irrigationWorking = false;

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
          deviceID = device.id;
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

  void _addNodoToStarNet() {
    if (deviceID != "") {
      final characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse(uuidNetService),
          characteristicId: Uuid.parse(uuidNetCharacteristic),
          deviceId: deviceID);
      _ble.writeCharacteristicWithoutResponse(characteristic, value: [0x01]);
      _connectBLE();
    }
  }

  void _removeNodoToStarNet() {
    if (deviceID != "") {
      final characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse(uuidNetService),
          characteristicId: Uuid.parse(uuidNetCharacteristic),
          deviceId: deviceID);
      _ble.writeCharacteristicWithoutResponse(characteristic, value: [0x00]);
      _connectBLE();
    }
  }

  void _turnOnIrrigation() {
    if (deviceID != "") {
      final characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse(uuidValveService),
          characteristicId: Uuid.parse(uuidValveCharacteristic),
          deviceId: deviceID);
      _ble.writeCharacteristicWithoutResponse(characteristic, value: [1]);
      _connectBLE();
    }
  }

  void _turnOffIrrigation() {
    if (deviceID != "") {
      final characteristic = QualifiedCharacteristic(
          serviceId: Uuid.parse(uuidValveService),
          characteristicId: Uuid.parse(uuidValveCharacteristic),
          deviceId: deviceID);
      _ble.writeCharacteristicWithoutResponse(characteristic, value: [0]);
      _connectBLE();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nodo APP'),
        ),
        body: ListView(children: <Widget>[
          ListTile(
            title: const Center(child: Text('Nombre del dispositivo')),
            subtitle: Center(child: Text(deviceName + " (" + deviceID + ")")),
            onLongPress: null,
          ),
          const Divider(),
          ListTile(
            title: Center(child: Text(printMessage)),
          ),
          ElevatedButton(
              onPressed: _connectBLE,
              child: (printMessage != "Estado: Nodo conectado")
                  ? const Text('Conectarse al Nodo')
                  : const Text('Actualizar la conexión'),
              style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent, fixedSize: const Size(100, 50))),
          const Divider(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    children: [
                      Text("Información del Nodo",
                          style: TextStyle(
                              fontSize: 35,
                              color: Colors.greenAccent.shade700)),
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
                        Text("Humedad actual: " + humidity.toString() + "%",
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
                        Text("Bateria actual: " + battery.toString() + "%",
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
                const SizedBox(height: 30),
                Row(
                    children: [
                      if (printMessage == "Estado: Nodo conectado") ...[
                        if (nodoConnectedToNet = false) ...[
                          ElevatedButton(
                              onPressed: _addNodoToStarNet,
                              child: const Text('Agregar Nodo a la red'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                                minimumSize: const Size(250, 50),
                              ))
                        ] else ...[
                          ElevatedButton(
                              onPressed: _removeNodoToStarNet,
                              child: const Text('Sacar Nodo de la red'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.greenAccent,
                                minimumSize: const Size(250, 50),
                              ))
                        ]
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
                        if (irrigationWorking = false) ...[
                          ElevatedButton(
                              onPressed: _turnOnIrrigation,
                              child: const Text('Encender Riego'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.redAccent,
                                minimumSize: const Size(250, 50),
                              ))
                        ] else ...[
                          ElevatedButton(
                              onPressed: _turnOffIrrigation,
                              child: const Text('Apagar Riego'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.greenAccent,
                                minimumSize: const Size(250, 50),
                              ))
                        ]
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
