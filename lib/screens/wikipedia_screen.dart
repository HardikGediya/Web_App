import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/models.dart';

class WikipediaScreen extends StatefulWidget {
  const WikipediaScreen({Key? key}) : super(key: key);

  @override
  State<WikipediaScreen> createState() => _WikipediaScreenState();
}

class _WikipediaScreenState extends State<WikipediaScreen> {

  final GlobalKey wikiWebViewKey = GlobalKey();
  final TextEditingController wikiSearchController = TextEditingController();

  double wikiProgress = 0;

  InAppWebViewController? wikiInAppWebViewController;
  late PullToRefreshController wikiPullToRefreshController;

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
    wikiPullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: wikipediaColor),
        onRefresh: () async {
          if (Platform.isAndroid) {
            wikiInAppWebViewController?.reload();
          } else if (Platform.isIOS) {
            wikiInAppWebViewController?.loadUrl(
                urlRequest: URLRequest(
                    url: await wikiInAppWebViewController?.getUrl()));
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
        backgroundColor: wikipediaColor,
        title: const Text('Wikipedia'),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/wiki.png',scale: 17,),
            onPressed: () async {
              await wikiInAppWebViewController!.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse("https://www.wikipedia.org/"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              await wikiInAppWebViewController!.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () async {
              await wikiInAppWebViewController!.goForward();
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh,),
            onPressed: () async {
              if (Platform.isAndroid) {
                wikiInAppWebViewController?.reload();
              } else if (Platform.isIOS) {
                wikiInAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await wikiInAppWebViewController?.getUrl()));
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
                  controller: wikiSearchController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await wikiInAppWebViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search on web...",
                    prefixIcon: Icon(Icons.search,color: wikipediaColor,),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: wikipediaColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: wikipediaColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (wikiProgress < 1)
              ? LinearProgressIndicator(
                  value: wikiProgress,
                  color: wikipediaColor,
                )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: wikiWebViewKey,
              pullToRefreshController: wikiPullToRefreshController,
              onWebViewCreated: (controller) {
                wikiInAppWebViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest:
                  URLRequest(url: Uri.parse("https://www.wikipedia.org/")),
              onLoadStart: (controller, uri) {
                setState(() {
                  wikiSearchController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                wikiPullToRefreshController.endRefreshing();
                setState(() {
                  wikiSearchController.text =
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
                  wikiPullToRefreshController.endRefreshing();
                }
                setState(() {
                  wikiProgress = val / 100;
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
            backgroundColor: wikipediaColor,
            child: const Icon(Icons.bookmark),
            onPressed: () async {
              Uri? uri = await wikiInAppWebViewController!.getUrl();

              String myURL = "${uri!.scheme}://${uri.host}${uri.path}";

              setState(() {
                bookmarks.add(myURL);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: wikipediaColor,
                  content: const Text("Successfully Bookmarked..."),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: wikipediaColor,
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
                                  await wikiInAppWebViewController!.loadUrl(
                                    urlRequest: URLRequest(url: Uri.parse(e)),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    color:wikipediaColor
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
