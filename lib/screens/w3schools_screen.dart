import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/models.dart';

class W3SchoolsScreen extends StatefulWidget {
  const W3SchoolsScreen({Key? key}) : super(key: key);

  @override
  State<W3SchoolsScreen> createState() => _W3SchoolsScreenState();
}

class _W3SchoolsScreenState extends State<W3SchoolsScreen> {

  final GlobalKey w3WebViewKey = GlobalKey();
  final TextEditingController w3SearchController = TextEditingController();

  double w3Progress = 0;

  InAppWebViewController? w3InAppWebViewController;
  late PullToRefreshController w3PullToRefreshController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  wikiInitRefreshController() async {
    w3PullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: w3SchoolsColor),
        onRefresh: () async {
          if (Platform.isAndroid) {
            w3InAppWebViewController?.reload();
          } else if (Platform.isIOS) {
            w3InAppWebViewController?.loadUrl(
                urlRequest: URLRequest(
                    url: await w3InAppWebViewController?.getUrl()));
          }
        });
  }

  @override
  initState() {
    super.initState();
    wikiInitRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: w3SchoolsColor,
        title: const Text('W3Schools'),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/w3.png',scale: 17,),
            onPressed: () async {
              await w3InAppWebViewController!.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse("https://www.w3schools.com/"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              await w3InAppWebViewController!.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () async {
              await w3InAppWebViewController!.goForward();
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh,),
            onPressed: () async {
              if (Platform.isAndroid) {
                w3InAppWebViewController?.reload();
              } else if (Platform.isIOS) {
                w3InAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await w3InAppWebViewController?.getUrl()));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: TextField(
                  controller: w3SearchController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await w3InAppWebViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search on web...",
                    prefixIcon: Icon(Icons.search,color: w3SchoolsColor,),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: w3SchoolsColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: w3SchoolsColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (w3Progress < 1)
              ? LinearProgressIndicator(
            value: w3Progress,
            color: w3SchoolsColor,
          )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: w3WebViewKey,
              pullToRefreshController: w3PullToRefreshController,
              onWebViewCreated: (controller) {
                w3InAppWebViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest:
              URLRequest(url: Uri.parse("https://www.w3schools.com/")),
              onLoadStart: (controller, uri) {
                setState(() {
                  w3SearchController.text =
                  "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                w3PullToRefreshController.endRefreshing();
                setState(() {
                  w3SearchController.text =
                  "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              onProgressChanged: (controller, val) {
                if (val == 100) {
                  w3PullToRefreshController.endRefreshing();
                }
                setState(() {
                  w3Progress = val / 100;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: w3SchoolsColor,
            child: const Icon(Icons.bookmark),
            onPressed: () async {
              Uri? uri = await w3InAppWebViewController!.getUrl();

              String myURL = "${uri!.scheme}://${uri.host}${uri.path}";

              setState(() {
                bookmarks.add(myURL);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: w3SchoolsColor,
                  content: const Text("Successfully Bookmarked..."),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: w3SchoolsColor,
            child: const Icon(Icons.star),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Center(
                      child: Text('My BookMarks'),
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: bookmarks
                          .map(
                            (e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await w3InAppWebViewController!.loadUrl(
                                urlRequest: URLRequest(url: Uri.parse(e)),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              e,
                              style: TextStyle(
                                color: w3SchoolsColor,
                              ),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
