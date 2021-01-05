import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity/connectivity.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     debug: true // optional: set false to disable printing logs to console
  // );
    await Permission.storage.request();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Werefa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(
        seconds: 2,
        navigateAfterSeconds: new MyHomePage(),

        image: new Image.asset('assets/images/logo.jpg'),
        // backgroundGradient: new LinearGradient(colors: [Colors.cyan, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        backgroundColor: Colors.black,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 150.0,
        onClick: ()=>print("Something to print when u click <Werefa, A life of ease>"),
        loaderColor: Colors.white,

      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  InAppWebViewController _webViewController;
  BuildContext lodingcontext;
  BuildContext maincontext;
  BuildContext notificationcontext;
  BuildContext notificationcontext1;
  String urls;
  bool check=false;
  bool ch=true;
  bool nach=false;
  bool lela=true;
  bool _isDialogShowing = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onbackpressd() async {


    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();

    } else{

      return (await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
        new AlertDialog(

          title: new Text('Are you sure?'),
          content: new Text('Do you want to exit the App'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () async { Navigator.of(context).pop(false);

              },
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('Yes'),
            ),
          ],
        ),
      )) ?? false;
    }
  }

  Future<void> _error() async {
    _isDialogShowing=true;
    if(lodingcontext!=null){
      Navigator.of(lodingcontext).pop(true);
    }
     return showDialog<void> (
       context: context,
      barrierDismissible: false, // user must tap button!
      barrierColor: Colors.black,
      builder: (BuildContext context) {
         notificationcontext=context;

        return AlertDialog(
          title: Text("Caution"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Connection Failed'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Try again'),
              onPressed: () async{
                var res = await Connectivity().checkConnectivity();

                if(res == ConnectivityResult.none){
                  Navigator.of(notificationcontext).pop(true);
                  _error();
                }else if(res == ConnectivityResult.wifi){
                  _lodding();
                  check=true;
                  _webViewController.reload();
                }else if(res == ConnectivityResult.mobile){
                  _lodding();
                  check=true;
                  _webViewController.reload();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _notifiy(String paths) async {
    if(lodingcontext!=null){
      Navigator.of(lodingcontext).pop(true);
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {


        return AlertDialog(
          title: Text("Caution"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Download completed. You can find the ticket in your gallery.'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              onPressed: ()  {
                Navigator.of(context).pop(false);

              },
              child: new Text('cancel'),
            ),

          ],
        );
      },
    );
  }

  Future<void> _lodding() async {
   // _islodingShowing=true;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      barrierColor: Colors.black,
      builder: (BuildContext context) {

          lodingcontext=context;


        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text('Werefa',style: TextStyle(fontSize: 50, color: Colors.white,decoration: TextDecoration.none),)),
              SizedBox(height: 30,),
              SpinKitCubeGrid(
                color: Colors.white,
                size: 80.0,
              ),
            ],

          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {


    return WillPopScope(

      onWillPop: _onbackpressd,
      child: Scaffold(

        body: SafeArea(
          child: InAppWebView(

            initialUrl: "https://werefa.biz/home",

            initialOptions: InAppWebViewGroupOptions(

                crossPlatform: InAppWebViewOptions(

                    javaScriptCanOpenWindowsAutomatically: true,
                    debuggingEnabled: true,
                    useOnDownloadStart: true
                ),

                android: AndroidInAppWebViewOptions(
                // on Android you need to set supportMultipleWindows to true,
                // otherwise the onCreateWindow event won't be called
                supportMultipleWindows: true
            )
            ),

            onWebViewCreated: (InAppWebViewController controller) async{
                _webViewController = controller;
              _lodding();

            },
            onLoadStart: (InAppWebViewController controller, String url) async{
              print('start');
              setState(() {
                ch=true;
                nach=false;
              });

              var res = await Connectivity().checkConnectivity();
              if(res == ConnectivityResult.none && lela){
                setState(() {
                  if(_isDialogShowing){
                    //_isDialogShowing=false;
                    Navigator.of(notificationcontext).pop(true);
                  }
                  _error();
                });
              }
                if(!url.contains('https://werefa.biz')){
                  setState(() {
                  _lodding();
                  });
                }
            },

            onLoadStop: (InAppWebViewController controller, String url) {

              print('stop $ch $check $_isDialogShowing');

                if(lodingcontext!=null){
                  Navigator.of(lodingcontext).pop(true);
                  lodingcontext=null;
                }
                if(_isDialogShowing && check==true && ch==true){
                  print('checked');
                  Navigator.of(notificationcontext).pop(true);
                }
                 if(nach){
                   setState(() {
                     print(_isDialogShowing);
                   if(_isDialogShowing){
                     print('delet');
                    // _isDialogShowing=false;
                     Navigator.of(notificationcontext).pop(true);
                   }

                     _error();
                   });
                 }


            },
            onLoadError: (InAppWebViewController controller, String url, int i,
                String s) async{
              print('error');

              setState(() {
                nach=true;
                ch=false;
                lela=false;
              });

            },
            onDownloadStart: (controller, url) async {
               _lodding();

              if(Permission.storage.isGranted != null) {

                List<String> strings = url.split(",");
                Uint8List bytes =base64Decode(strings[1]);
                String dir = (await getApplicationDocumentsDirectory()).path;
                String fullPath = '$dir/abc.png';
                print("local file full path ${fullPath}");
                File file = File(fullPath);
                await file.writeAsBytes(bytes);
                print(file.path);
                final result = await ImageGallerySaver.saveImage(bytes);
                _notifiy(result);
              }else{
                Permission.storage.request();
              }
            },

            onCreateWindow: (controller, createWindowRequest) async {

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      child: InAppWebView(
                        // Setting the windowId property is important here!
                        windowId: createWindowRequest.windowId,
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            debuggingEnabled: true,
                          ),
                        ),
                        onWebViewCreated: (InAppWebViewController controller) {
                          _webViewController = controller;
                        },
                        onLoadStart: (InAppWebViewController controller, String url) {
                          print("onLoadStart popup $url");
                        },
                        onLoadStop: (InAppWebViewController controller, String url) {
                          print("onLoadStop popup $url");
                          if(!url.contains('auth.yenepay')){
                            Navigator.of(context).pop(true);
                          }

                        },
                      ),
                    ),
                  );
                },
              );
              //
              return true;
            },
          ),
        ),
      ),
    );
  }
}
