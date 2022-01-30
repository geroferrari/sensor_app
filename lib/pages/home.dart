// ignore_for_file: prefer_collection_literals
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:untitled/pages/bluetooth/SelectBondedDevicePage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:untitled/bluetooth/BackgroundCollectedPage.dart';
import 'package:untitled/bluetooth/BackgroundCollectingTask.dart';
import 'package:untitled/pages/bluetooth/DiscoveryPage.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor App'),
      ),
      body: ListView(
        children: <Widget>[
          const Divider(),
          SwitchListTile(
            title: const Text('Habilitar Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text('Estado de Conexión'),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(
              child: const Text('Ajustes'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          ListTile(
            title: const Text('Dirección del dispositivo'),
            subtitle: Text(_address),
          ),
          ListTile(
            title: const Text('Nombre del dispositivo'),
            subtitle: Text(_name),
            onLongPress: null,
          ),
          const Divider(),
          const ListTile(title: Text('Funciones de emparejamiento y conexión')),
          SwitchListTile(
            title: const Text('Usar PIN para emparejamiento'),
            subtitle: const Text('Pin 1234'),
            value: _autoAcceptPairingRequests,
            onChanged: (bool value) {
              setState(() {
                _autoAcceptPairingRequests = value;
              });
              if (value) {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(
                    (BluetoothPairingRequest request) {
                  print("intentando conexión con Pin 1234");
                  if (request.pairingVariant == PairingVariant.Pin) {
                    return Future.value("1234");
                  }
                  return Future.value(null);
                });
              } else {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
              }
            },
          ),
          ListTile(
            title: ElevatedButton(
                child: const Text('Buscar nuevos dispositivos'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const DiscoveryPage();
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Discovery -> selected ' + selectedDevice.address);
                  } else {
                    print('Discovery -> no device selected');
                  }
                }),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Connectar nodo a la red'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  print('Connect -> selected ' + selectedDevice.address);
                } else {
                  print('Connect -> no device selected');
                }
              },
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: ((_collectingTask?.inProgress ?? false)
                  ? const Text('Desconectar Nodo')
                  : const Text('Conectar Nodo')),
              onPressed: () async {
                if (_collectingTask?.inProgress ?? false) {
                  await _collectingTask!.cancel();
                  setState(() {
                    /* Update for `_collectingTask.inProgress` */
                  });
                } else {
                  final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const SelectBondedDevicePage(
                            checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    await _startBackgroundTask(context, selectedDevice);
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  }
                }
              },
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Ver información del Nodo'),
              onPressed: (_collectingTask != null)
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ScopedModel<BackgroundCollectingTask>(
                              model: _collectingTask!,
                              child: BackgroundCollectedPage(),
                            );
                          },
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startBackgroundTask(
    BuildContext context,
    BluetoothDevice server,
  ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask!.start();
    } catch (ex) {
      _collectingTask?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text(ex.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
