import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app/pages/splashscreen.dart';

void main() {
  runApp(const BetTvPlusApp());
}

class BetTvPlusApp extends StatelessWidget {
  const BetTvPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BetTvPlus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF1A4C9A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A4C9A),
          primary: const Color(0xFF1A4C9A),
          secondary: const Color(0xFF2D73D5),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WebViewController _controller;
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _hasInternet = true;

  final List<String> _urls = [
    "https://64177f0ce1006.site123.me/",
    "https://64177f0ce1006.site123.me/o-nama-1",
    "https://64177f0ce1006.site123.me/kontakt",
    "https://64177f0ce1006.site123.me/mac-payment-lifetime",
  ];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    Connectivity().onConnectivityChanged.listen((_) => _checkInternet());

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) async {
            final url = request.url;

            // WhatsApp links handled via web
            if (url.startsWith("whatsapp://") || url.startsWith("https://wa.me/")) {
              String webUrl;

              if (url.startsWith("whatsapp://send/")) {
                // Convert whatsapp://send/?text=... to https://wa.me/?text=...
                Uri uri = Uri.parse(url);
                String text = uri.queryParameters['text'] ?? '';
                webUrl = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
              } else {
                webUrl = url; // already wa.me link
              }

              if (await canLaunchUrl(Uri.parse(webUrl))) {
                await launchUrl(
                  Uri.parse(webUrl),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cannot open WhatsApp link")),
                );
              }

              return NavigationDecision.prevent;
            }

            // Facebook links
            if (url.contains("facebook.com")) {
              final fbUri = Uri.parse("fb://facewebmodal/f?href=$url");
              if (await canLaunchUrl(fbUri)) {
                await launchUrl(fbUri, mode: LaunchMode.externalApplication);
              } else {
                await launchUrl(
                  Uri.parse("https://www.facebook.com/sharer/sharer.php?u=$url"),
                  mode: LaunchMode.externalApplication,
                );
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_urls[_selectedIndex]));
  }

  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() => _hasInternet = false);
    } else {
      try {
        final lookup = await InternetAddress.lookup('google.com');
        setState(() => _hasInternet = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty);
      } on SocketException {
        setState(() => _hasInternet = false);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(_urls[index]));
  }

  Future<void> _reloadPage() async {
    await _checkInternet();
    if (_hasInternet) await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_hasInternet
          ? _buildNoInternetScreen()
          : Stack(
        children: [
          RefreshIndicator(
            onRefresh: _reloadPage,
            color: const Color(0xFF1A4C9A),
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D73D5)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF2D73D5),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "O NAMA"),
          BottomNavigationBarItem(icon: Icon(Icons.contact_page), label: "KONTAKT"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payment"),
        ],
      ),
    );
  }

  Widget _buildNoInternetScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Color(0xFF2D73D5)),
            const SizedBox(height: 20),
            const Text(
              "No Internet Connection",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reloadPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4C9A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
