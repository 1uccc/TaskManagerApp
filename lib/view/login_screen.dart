import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final PageController _pageController = PageController(initialPage: 0);
  Color left = Colors.black;
  Color right = Colors.white;
  final Color GradientStart = const Color(0xff66fb9a);
  final Color GradientEnd = const Color(0xff002d88);
  final UserService _userService = UserService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _userService.loginWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      _goToHome();
    } on Exception catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      await _userService.loginWithGoogle();
      _goToHome();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
    setState(() {
      left = Colors.black;
      right = Colors.white;
    });
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
    setState(() {
      right = Colors.black;
      left = Colors.white;
    });
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: const BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  splashFactory:
                      NoSplash.splashFactory, // Loại bỏ hiệu ứng ripple
                ),
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Đăng nhập",
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0,
                    fontFamily: "WorkSansSemiBold",
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "Đăng ký",
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0,
                    fontFamily: "WorkSansSemiBold",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
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
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                            bottom: 12.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.envelope,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              hintText: "Email",
                              hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold",
                                fontSize: 17.0,
                              ),
                            ),
                            validator:
                                (value) =>
                                    value != null && value.contains('@')
                                        ? null
                                        : "Email sai",
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                            bottom: 12.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          child: TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            style: const TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                size: 22.0,
                                color: Colors.black,
                              ),
                              hintText: "Mật khẩu",
                              hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold",
                                fontSize: 17.0,
                              ),
                            ),
                            validator:
                                (value) =>
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
                margin: const EdgeInsets.only(top: 160.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: GradientStart,
                      offset: const Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: GradientEnd,
                      offset: const Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [GradientEnd, GradientStart],
                    begin: const FractionalOffset(0.2, 0.2),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: const [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: GradientEnd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 42.0,
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontFamily: "WorkSansBold",
                              ),
                            ),
                  ),
                  onPressed: _login,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: OutlinedButton.icon(
              onPressed: _loginWithGoogle,
              icon: Image.asset(
                'assets/images/google-logo.png',
                height: 30,
                width: 30,
              ),
              label: const Text(
                "Đăng nhập bằng Google",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "WorkSansMedium",
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                side: const BorderSide(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [GradientStart, GradientEnd],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.0),
            stops: const [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                "TaskManager",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "WorkSansBold",
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Image(
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/luk_logo.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildMenuBar(context),
              ),
              Expanded(
                flex: 2,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildSignIn(context),
                    LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '© nguyendinhluc',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabIndicationPainter extends CustomPainter {
  Paint painter = Paint();
  final double dxTarget = 125.0;
  final double dxEntry = 25.0;
  final double radius = 21.0;
  final double dy = 25.0;
  final double pi = 3.14;

  final PageController pageController;

  TabIndicationPainter({required this.pageController})
    : super(repaint: pageController) {
    painter =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pos = pageController.position;
    double fullExtent =
        (pos.maxScrollExtent - pos.minScrollExtent + pos.viewportDimension);

    double pageOffset = pos.extentBefore / fullExtent;

    bool left2right = dxEntry < dxTarget;
    Offset entry = Offset(left2right ? dxEntry : dxTarget, dy);
    Offset target = Offset(left2right ? dxTarget : dxEntry, dy);

    Path path = Path();
    path.addArc(
      Rect.fromCircle(center: entry, radius: radius),
      0.5 * pi,
      1 * pi,
    );
    path.addRect(Rect.fromLTRB(entry.dx, dy - radius, target.dx, dy + radius));
    path.addArc(
      Rect.fromCircle(center: target, radius: radius),
      1.5 * pi,
      1 * pi,
    );

    canvas.translate(size.width * pageOffset, 0.0);

    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(TabIndicationPainter oldDelegate) => true;
}
