import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_strings.dart';

class TicketWebViewScreen extends StatefulWidget {
  final String url;

  const TicketWebViewScreen({super.key, required this.url});

  @override
  State<TicketWebViewScreen> createState() => _TicketWebViewScreenState();
}

class _TicketWebViewScreenState extends State<TicketWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('buyTicket'))),
      body: WebViewWidget(controller: _controller),
    );
  }
}
