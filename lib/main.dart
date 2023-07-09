import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRCode Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const QRCodeSeite(title: 'QrCode Scanner'),
    );
  }
}

class QRCodeSeite extends StatefulWidget {
  const QRCodeSeite({super.key, required String title});

  @override
  State<QRCodeSeite> createState() => QRCodeSeiteState();
}

class QRCodeSeiteState extends State<QRCodeSeite> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;
  String result = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Qr Code Scanner"),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    flex: 3,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Theme.of(context).canvasColor,
                        borderRadius: 10,
                        borderLength: 50,
                        borderWidth: 10,
                        cutOutSize: MediaQuery.of(context).size.width * 0.6,
                      ),
                    )),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "Scan Result: $result",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (result.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: result));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Is kopiert Meister"),
                              ),
                            );
                          }
                        },
                        child: Text("COPY"),
                      ),
                      Column(

                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          ElevatedButton(
                            onPressed: () async {
                              if (result.isNotEmpty) {
                                final Uri _url = Uri.parse(result);
                                await launchUrl(_url);
                              }
                            },
                            child: Text("OPEN IN WEBVIEW"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (result.isNotEmpty) {
                                final Uri _url = Uri.parse(result);
                                await launchUrl(_url, mode:LaunchMode.externalApplication);
                              }
                            },
                            child: Text("OPEN IN BROWSER"),
                          ),

                        ],
                      )

                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: FutureBuilder<bool?>(
                    future: controller?.getFlashStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return Icon(
                            snapshot.data! ? Icons.flash_off : Icons.flash_on);
                      } else {
                        return Icon(Icons.flash_auto);
                      }
                    },
                  ),
                  onPressed: () async {
                    await controller?.toggleFlash();
                  },
                ),
                IconButton(
                    onPressed: () async {
                      await controller?.flipCamera();
                    },
                    icon: Icon(Icons.switch_camera))
              ],
            ),
          ],
        ));
  }
}
