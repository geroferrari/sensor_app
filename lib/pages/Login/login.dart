// ignore_for_file: deprecated_member_use, unnecessary_new

import 'package:flutter/material.dart';
import 'package:agricultura_inteligente/authentication/api_service.dart';
import 'package:agricultura_inteligente/pages/login/components/login_model.dart';
import 'package:agricultura_inteligente/pages/home.dart';
import 'package:agricultura_inteligente/widgets/ProgressHUD.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;
  bool isApiCallProcess = false;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  LoginRequestModel? loginRequestModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    loginRequestModel = LoginRequestModel();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 1,
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 85, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).hintColor.withOpacity(0.8),
                          offset: const Offset(0, 10),
                          blurRadius: 20)
                    ],
                  ),
                  child: Form(
                    key: globalFormKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 25),
                        const Icon(
                          Icons.person,
                          color: Colors.greenAccent,
                          size: 75,
                        ),
                        const SizedBox(height: 20),
                        new TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (input) => loginRequestModel!.token = input!,
                          decoration: new InputDecoration(
                            hintText: "Token",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.8))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary)),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextButton(
                          onPressed: () {
                            if (validateAndSave()) {
                              print(loginRequestModel?.toJson());

                              setState(() {
                                isApiCallProcess = true;
                              });

                              APIService apiService = new APIService();
                              apiService
                                  .login(loginRequestModel!)
                                  .then((value) {
                                setState(() {
                                  isApiCallProcess = false;
                                });

                                if (value.token != "0") {
                                  const snackBar = SnackBar(
                                      content: Text("Login Successful"));
                                  scaffoldKey.currentState!
                                      .showSnackBar(snackBar);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MainPage(),
                                    ),
                                  );
                                } else {
                                  const snackBar =
                                      SnackBar(content: Text("ERROR"));
                                  scaffoldKey.currentState!
                                      .showSnackBar(snackBar);
                                }
                              });
                            }
                          },
                          child: const Text(
                            "Iniciar Sesion",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
