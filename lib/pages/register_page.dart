import 'package:file_picker/file_picker.dart';
import '../provider/authentication_provider.dart';
import '../services/cloud_storage_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_services.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../widgets/rounded_image.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  PlatformFile? _profileImage;

  late AuthenticationProvider _auth;
  late DatabaseService _db;
  late CloudStorageService _cloudStorage;
  late NavigationService _navigation;

  String? _name;
  String? _email;
  String? _password;

  bool isLoading = false;
  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    _auth = Provider.of<AuthenticationProvider>(context);
    _db = GetIt.instance.get<DatabaseService>();
    _cloudStorage = GetIt.instance.get<CloudStorageService>();
    _navigation = GetIt.instance.get<NavigationService>();




    return Container(


        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _deviceHeight * .04,
            ),
            _profileImageField(),
            SizedBox(
              height: _deviceHeight * 0.03,
            ),
            _registerForm(),
            SizedBox(
              height: _deviceHeight * 0.03,
            ),
            _registerButton(),
            SizedBox(
              height: _deviceHeight * 0.08,
            ),
          ],
        ),

    );
  }

  _profileImageField() {
    return GestureDetector(onTap: () {
      GetIt.instance.get<MediaService>().pickImageFromLibrary().then((_file) {
        setState(() {
          _profileImage = _file;
        });
      });
    }, child: () {
      if (_profileImage != null) {
        return RoundedImageFile(
            image: _profileImage!, size: _deviceHeight * 0.1);
      } else {
        return Column(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              radius: 50,
              child: Icon(
                Icons.person_outline_sharp,
                size: 60,
                color: Colors.blue.shade100,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              "Add photo*".toUpperCase(),
              style: TextStyle(color: Colors.white),
            )
          ],
        );
      }
    }());
  }

  _registerForm() {
    return Container(

      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
              validationMsg: "Enter valid name",
                textColor: Colors.white,
                bgColor: Theme.of(context).secondaryHeaderColor,
                onSaved: (_value) {
                  setState(() {
                    _name = _value;
                  });
                },
                regEx: r".{3}",
                hintText: "Name",
                obscureText: false),
            SizedBox(height: 20,),
            CustomTextFormField(
              validationMsg: "enter valid email",
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
                obscureText: false),            SizedBox(height: 20,),

            CustomTextFormField(
              validationMsg: "Enter valid password",
                textColor: Colors.white,
                bgColor: Theme.of(context).secondaryHeaderColor,
                onSaved: (_value) {
                  setState(() {
                    _password = _value;
                  });
                },
                regEx: r'^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                hintText: "Password",
                obscureText: true),
          ],
        ),
      ),
    );
  }

  _registerButton() {
    return ElevatedButton(
      child:isLoading?Padding(

        padding: const EdgeInsets.all(12.0),
        child: CircularProgressIndicator(color: Colors.white,strokeWidth: 4,),
      ) : Text("Register",style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor,fontWeight: FontWeight.w500),),
        style: ElevatedButton.styleFrom(primary: Colors.white,elevation: 0, minimumSize: Size(double.infinity,50),shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),

        onPressed: () async {
        if(_profileImage == null){
          const snackBar = SnackBar(content: Text('Please Select Profile Image!'));

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

          if (_registerFormKey.currentState!.validate() &&
              _profileImage != null) {

            _registerFormKey.currentState!.save();
            setState(() {
              isLoading = true;
            });

            String? _uid =
                await _auth.regiSterUserUsingEmai(_name!, _password!, _email!);
            String? _imageUrl = await _cloudStorage
                .saveUserImageToStorage(_uid!, _profileImage!);
            await _db.createUser(_uid, _email!, _imageUrl!, _name!);
            await _auth.logout();
            await _auth.loginWithEmail(_email!, _password!);
            setState(() {
              isLoading = false;
            });

          }
        });
  }
}
