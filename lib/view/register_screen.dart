import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeyRegister = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  bool _isLoadingRegister = false;

  Color loginGradientStart = const Color(0xff66fb9a);
  Color loginGradientEnd = const Color(0xff002d88);

  Future<void> _registerUser() async {
    if (!_formKeyRegister.currentState!.validate()) return;
    setState(() => _isLoadingRegister = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': user.uid,
          'username': _usernameCtrl.text.trim(),
          'password': '***hidden***',
          'email': _emailCtrl.text.trim(),
          'avatar': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Lỗi không xác định')));
    } finally {
      setState(() => _isLoadingRegister = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKeyRegister,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0, left: 16.0, right: 16.0),
                          child: TextFormField(
                            controller: _usernameCtrl,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                                fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.user,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              hintText: "Tên người dùng",
                              hintStyle: TextStyle(
                                  fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                            ),
                            validator: (value) =>
                            value!.isEmpty ? "Nhập tên người dùng" : null,
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0, left: 16.0, right: 16.0),
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                                fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.envelope,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              hintText: "Email",
                              hintStyle: TextStyle(
                                  fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                            ),
                            validator: (value) =>
                            value != null && value.contains('@')
                                ? null
                                : "Email không hợp lệ",
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 12.0, left: 16.0, right: 16.0),
                          child: TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            style: const TextStyle(
                                fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              hintText: "Mật khẩu",
                              hintStyle: TextStyle(
                                  fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                            ),
                            validator: (value) =>
                            value != null && value.length >= 6
                                ? null
                                : "Ít nhất 6 ký tự",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 220.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: loginGradientStart,
                      offset: const Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: loginGradientEnd,
                      offset: const Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: [loginGradientEnd, loginGradientStart],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: const [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: loginGradientEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 42.0),
                    child: _isLoadingRegister
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      "Đăng ký",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontFamily: "WorkSansBold"),
                    ),
                  ),
                  onPressed: _registerUser,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}