import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}

const String URL = '[replace_with_widget_webview_url]';
const String AUTH_TOKEN = '[replace_with_user_auth_token]';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binge Wave Sample App',
      theme: ThemeData(
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: WebViewContainer(
          URL,
          'Binge Wave Sample App'),
    );
  }
}

class WebViewContainer extends StatefulWidget {
  final url;
  final title;

  WebViewContainer(this.url, this.title);

  @override
  createState() => _WebViewContainerState(this.url, this.title);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  var _title;
  final _key = UniqueKey();

  _WebViewContainerState(this._url, this._title);

  checkpermissions() async {
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;


    if (!cameraStatus.isGranted) await Permission.camera.request();

    if (!microphoneStatus.isGranted) await Permission.microphone.request();

    if (await Permission.camera.isGranted) {
      if (await Permission.microphone.isGranted) {
      } else {
        Fluttertoast.showToast(
            msg: "Microphone permission is required for app to work", // message
            toastLength: Toast.LENGTH_SHORT, // length
            gravity: ToastGravity.CENTER, // location
            timeInSecForIosWeb: 1 // duration
            );
      }
    } else {
      Fluttertoast.showToast(
          msg: "Camera permission is required for app to work", // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.BOTTOM, // location
          timeInSecForIosWeb: 1 // duration
          );
    }
  }

  @override
  void initState() {
    checkpermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Column(
        children: [
          Expanded(
              child: InAppWebView(
                  key: _key,
                  onWebViewCreated: (controller) {
                    Map<String, String> headers = {
                      "Authorization": "Bearer " + AUTH_TOKEN
                    };
                    URLRequest urlRequest = URLRequest(
                        url: Uri.parse(_url),
                        headers: headers);
                    controller.loadUrl(urlRequest: urlRequest);
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  }))
        ],
      ),
    );
  }
}

