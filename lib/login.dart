import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/user.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  static const errorSnackbar =
      SnackBar(content: Text('There was an error logging into the app'));

  @override
  Widget build(BuildContext context) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 50, bottom: 20),
              child: TextFormField(
                  controller: userCtrl,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                  ))),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                  ))),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 30),
              child: Provider.of<User>(context).status == LoginStatus.TRY
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            Future<bool> success =
                                Provider.of<User>(context, listen: false)
                                    .tryLogIn(userCtrl.text, passCtrl.text);
                            if (await success) {
                              Navigator.of(context).pop();
                            } else
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(errorSnackbar);
                          },
                          child: Text('Log In'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: StadiumBorder(),
                              textStyle: TextStyle(fontSize: 18))),
                    )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return _buildConfirmSheet(
                                context, userCtrl, confirmCtrl, passCtrl);
                          });
                    },
                    child: Text('New User? Click to Sign Up'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: StadiumBorder(),
                        textStyle: TextStyle(fontSize: 18))),
              ))
        ]);
  }

  _buildConfirmSheet(BuildContext context, TextEditingController userCtrl,
      TextEditingController confirmCtrl, TextEditingController passCtrl) {
    return Container(
      height: 200 + MediaQuery.of(context).viewInsets.top,
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.all(12),
              child: Text("Please confirm your password:")),
          Divider(),
          TextFormField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password',
              )),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Provider.of<User>(context).status != LoginStatus.OUT
                ? CircularProgressIndicator()
                : ElevatedButton(
                onPressed: () async {
                  if (passCtrl.text == confirmCtrl.text) {
                    await Provider.of<User>(context, listen: false)
                        .signUpAndLogin(userCtrl.text, passCtrl.text);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    confirmCtrl.clear();
                    final alert = AlertDialog(
                      content: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("Passwords must match",
                                  style: TextStyle(color: Colors.red))
                              ])),
                    );
                    showDialog(context: context, builder: (context) => alert);
                  }
                },
                child: Text("Confirm")),
          ),
        ],
      ),
    );
  }
}
