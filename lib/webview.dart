import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:web_webview_messaging/logger.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({Key? key}) : super(key: key);

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  late final PlatformWebViewController _controller;
  final String htmlString = '''
<!DOCTYPE html>
<html>
<head>
    <title>HTML String Test</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script>
        function onSubmitEvent() {
            window.parent.postMessage("message from webview", "http://localhost:8081/");
        }
    </script>
</head>
<body>
    <form name="form" onsubmit="onSubmitEvent()">
        <div style="text-align: center;">
          <p>Submit the form, then close this sheet with message "message from webview"</p>
          <input type="submit" value="Submit" style="padding: 6px 12px;">
        </div>
    </form>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )..loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    window.onMessage.listen((event) {
      logger.info('Received message from webview: ${event.data}');
      Navigator.of(context).pop(event.data);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        actions: <Widget>[
          _SampleMenu(_controller),
        ],
      ),
      body: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _controller),
      ).build(context),
    );
  }
}

enum _MenuOptions {
  closeRequest,
}

class _SampleMenu extends StatelessWidget {
  const _SampleMenu(this.controller);

  final PlatformWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      onSelected: (_MenuOptions value) {
        switch (value) {
          case _MenuOptions.closeRequest:
            _onCloseRequest(controller, context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: _MenuOptions.closeRequest,
          child: Text('Close'),
        ),
      ],
    );
  }

  Future<void> _onCloseRequest(
      PlatformWebViewController controller, BuildContext context) async {
    Navigator.of(context).pop();
  }
}
