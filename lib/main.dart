import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login/animation_enum.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Artboard? myArtboard;
  late RiveAnimationController controllerIdle;
  late RiveAnimationController controllerSuccess;
  late RiveAnimationController controllerFail;
  late RiveAnimationController controllerHandsUp;
  late RiveAnimationController controllerHandsDown;
  late RiveAnimationController controllerLookDownRight;
  late RiveAnimationController controllerLookDownLeft;
  late RiveAnimationController controllerLookIdle;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final passwordFocusNode = FocusNode();

  String testEmail = "ahmed@gmail.com";
  String testPassword = "123456";
  bool isLookingRight = false;
  bool isLookingLeft = false;
  

  void removeAllControllers() {
    myArtboard?.artboard.removeController(controllerIdle);
    myArtboard?.artboard.removeController(controllerHandsUp);
    myArtboard?.artboard.removeController(controllerHandsDown);
    myArtboard?.artboard.removeController(controllerLookDownLeft);
    myArtboard?.artboard.removeController(controllerLookDownLeft);
    myArtboard?.artboard.removeController(controllerSuccess);
    myArtboard?.artboard.removeController(controllerFail);
    isLookingLeft = false;
    isLookingRight = false;
  }

  void addSpecifcAnimationAction(
      RiveAnimationController<dynamic> neededAnimationAction) {
    removeAllControllers();
    myArtboard?.artboard.addController(neededAnimationAction);
  }

  @override
  void dispose() {
    passwordFocusNode.removeListener;
    super.dispose();
  }


  

 


  @override
  void initState() {
    super.initState();
    controllerIdle = SimpleAnimation(AnimationEnum.idle.name);
    controllerSuccess = SimpleAnimation(AnimationEnum.success.name);
    controllerFail = SimpleAnimation(AnimationEnum.fail.name);
    controllerHandsUp = SimpleAnimation(AnimationEnum.Hands_up.name);
    controllerHandsDown = SimpleAnimation(AnimationEnum.hands_down.name);
    controllerLookDownRight =
        SimpleAnimation(AnimationEnum.Look_down_right.name);
    controllerLookDownLeft = SimpleAnimation(AnimationEnum.Look_down_left.name);
    controllerLookIdle = SimpleAnimation(AnimationEnum.look_idle.name);

    rootBundle.load('assets/animated_login.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        artboard.addController(controllerIdle);
        setState(() => myArtboard = artboard);
      },
    );
  }

   void checkForPasswordFocusNodeToChangeAnimationState() {
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        addSpecifcAnimationAction(controllerHandsUp);
      } else if (!passwordFocusNode.hasFocus) {
        addSpecifcAnimationAction(controllerHandsDown);
      }
    });
  }

   void validateEmailAndPassword() {
    Future.delayed(const Duration(seconds: 1), () {
      if (formKey.currentState!.validate()) {
        addSpecifcAnimationAction(controllerSuccess);
      } else {
        addSpecifcAnimationAction(controllerFail);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xffC2DBE1),
        appBar: AppBar(
          title: const Text('Animated Login',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: myArtboard == null
                    ? const SizedBox.shrink()
                    : Rive(
                        artboard: myArtboard!,
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      validator: (value) =>
                          value != testEmail ? "Wrong email" : null,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            value.length < 16 &&
                            !isLookingLeft) {
                          addSpecifcAnimationAction(controllerLookDownLeft);
                        } else if (value.isNotEmpty &&
                            value.length > 16 &&
                            !isLookingRight) {
                          addSpecifcAnimationAction(controllerLookDownRight);
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 25,
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      focusNode: passwordFocusNode,
                      validator: (value) =>
                          value != testPassword ? "Wrong password" : null,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 18,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 8,
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          passwordFocusNode.unfocus();
                          validateEmailAndPassword();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
