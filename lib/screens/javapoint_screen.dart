import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/models.dart';

class JavaPointsScreen extends StatefulWidget {
  const JavaPointsScreen({Key? key}) : super(key: key);

  @override
  State<JavaPointsScreen> createState() => _JavaPointsScreenState();
}

class _JavaPointsScreenState extends State<JavaPointsScreen> {
  final GlobalKey javaWebViewKey = GlobalKey();
  final TextEditingController javaSearchController = TextEditingController();

  double javaProgress = 0;

  InAppWebViewController? javaInAppWebViewController;
  late PullToRefreshController javaPullToRefreshController;

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
    javaPullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: javaPointsColor),
        onRefresh: () async {
          if (Platform.isAndroid) {
            javaInAppWebViewController?.reload();
          } else if (Platform.isIOS) {
            javaInAppWebViewController?.loadUrl(
                urlRequest: URLRequest(
                    url: await javaInAppWebViewController?.getUrl()));
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
        backgroundColor: javaPointsColor,
        title: const Text('JavaPoints'),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/java.png',
              scale: 7,
            ),
            onPressed: () async {
              await javaInAppWebViewController!.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse("https://www.javatpoint.com/"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              await javaInAppWebViewController!.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () async {
              await javaInAppWebViewController!.goForward();
            },
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.refresh,
            ),
            onPressed: () async {
              if (Platform.isAndroid) {
                javaInAppWebViewController?.reload();
              } else if (Platform.isIOS) {
                javaInAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await javaInAppWebViewController?.getUrl()));
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
                  controller: javaSearchController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await javaInAppWebViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search on web...",
                    prefixIcon: Icon(
                      Icons.search,
                      color: javaPointsColor,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: javaPointsColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: javaPointsColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (javaProgress < 1)
              ? LinearProgressIndicator(
                  value: javaProgress,
                  color: javaPointsColor,
                )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: javaWebViewKey,
              pullToRefreshController: javaPullToRefreshController,
              onWebViewCreated: (controller) {
                javaInAppWebViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest:
                  URLRequest(url: Uri.parse("https://www.javatpoint.com/")),
              onLoadStart: (controller, uri) {
                setState(() {
                  javaSearchController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                javaPullToRefreshController.endRefreshing();
                setState(() {
                  javaSearchController.text =
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
                  javaPullToRefreshController.endRefreshing();
                }
                setState(() {
                  javaProgress = val / 100;
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
            backgroundColor: javaPointsColor,
            child: const Icon(Icons.bookmark),
            onPressed: () async {
              Uri? uri = await javaInAppWebViewController!.getUrl();

              String myURL = "${uri!.scheme}://${uri.host}${uri.path}";

              setState(() {
                bookmarks.add(myURL);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: javaPointsColor,
                  content: const Text("Successfully Bookmarked..."),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: javaPointsColor,
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
                                  await javaInAppWebViewController!.loadUrl(
                                    urlRequest: URLRequest(url: Uri.parse(e)),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color: javaPointsColor,
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
