import 'dart:developer';

import '../pages/register_page.dart';
import '../provider/authentication_provider.dart';
import '../services/navigation_services.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;

  final _loginFormKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  int switchInx = 0;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body:    _auth.isLoading?Center(child: CircularProgressIndicator(),):
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height:  _deviceHeight * .05,),
                  _pageTitle(),
                  SizedBox(height:  _deviceHeight * .05,),

                  _buildSwitch(),

                 switchInx== 0? AnimatedContainer(
                   duration: Duration(seconds: 1),
                   child: Column(
                      children: [

                        SizedBox(
                          height: _deviceHeight * 0.04,
                        ),
                        _loginForm(),
                        SizedBox(
                          height: _deviceHeight * 0.04,
                        ),
                        _loginButton(),
                        SizedBox(
                          height: _deviceHeight * 0.01,
                        ),
                      ],
                    ),
                 ) : RegisterPage()

                ],
              ),
            ),
          )

    );
  }

  _buildSwitch(){
    return ToggleSwitch(
      minWidth: _deviceWidth/2 -20,
      minHeight: 45,
      cornerRadius: 20.0,
      activeBgColor: [Colors.white, Colors.white],
      activeFgColor: Colors.black,
      inactiveBgColor: Theme.of(context).secondaryHeaderColor,
      inactiveFgColor: Colors.white,
      initialLabelIndex: switchInx,
      customTextStyles: [TextStyle(fontSize: 16,fontWeight: FontWeight.w600),TextStyle(fontSize: 16,fontWeight: FontWeight.w600),],

      totalSwitches: 2,
      labels: ['Login', 'Register'],
      radiusStyle: true,
      onToggle: (int? index) {
        setState(() {
          if(index != null){
            switchInx = index;

          }
        });
      },
    );
  }

  _pageTitle() {
    return Container(
      child: Text(
        "Chat App",
        style: TextStyle(
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
      ),
    );
  }

  _loginForm() {
    return Container(
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            CustomTextFormField(
              validationMsg: "Enter the valid email",
              textColor: Colors.white,
                bgColor: Theme.of(context).secondaryHeaderColor,
                onSaved: (_value) {
                  setState(() {
                    _email = _value;
                  });
                },
                regEx:
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                hintText: "Email",
                obscureText: false),
            SizedBox(height: 20,),
            CustomTextFormField(
              validationMsg: "Enter valid email",
                textColor: Colors.white,
                bgColor: Theme.of(context).secondaryHeaderColor,
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regEx:
                    r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                hintText: "Password",
                obscureText: true),
          ],
        ),
      ),
    );
  }

  _loginButton() {
    return ElevatedButton(
        child:Text("Login",style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor,fontWeight: FontWeight.w500),),
        style: ElevatedButton.styleFrom(primary: Colors.white,elevation: 0, minimumSize: Size(double.infinity,50),shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),

        onPressed: () async {


          if(_loginFormKey.currentState!.validate()){
            _loginFormKey.currentState!.save();

            _auth.loginWithEmail(_email!, _password!);
          }
        });


  }

}
