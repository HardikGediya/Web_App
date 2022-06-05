import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/models.dart';

class TutorialPointsScreen extends StatefulWidget {
  const TutorialPointsScreen({Key? key}) : super(key: key);

  @override
  State<TutorialPointsScreen> createState() => _TutorialPointsScreenState();
}

class _TutorialPointsScreenState extends State<TutorialPointsScreen> {

  final GlobalKey tutorialWebViewKey = GlobalKey();
  final TextEditingController tutorialSearchController = TextEditingController();

  double tutorialProgress = 0;

  InAppWebViewController? tutorialInAppWebViewController;
  late PullToRefreshController tutorialPullToRefreshController;

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
    tutorialPullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: tutorialPointsColor),
        onRefresh: () async {
          if (Platform.isAndroid) {
            tutorialInAppWebViewController?.reload();
          } else if (Platform.isIOS) {
            tutorialInAppWebViewController?.loadUrl(
                urlRequest: URLRequest(
                    url: await tutorialInAppWebViewController?.getUrl()));
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
        backgroundColor: tutorialPointsColor,
        title: const Text('TutorialPoints'),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/tuto.png',scale: 17,),
            onPressed: () async {
              await tutorialInAppWebViewController!.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse("https://www.tutorialspoint.com/index.htm"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              await tutorialInAppWebViewController!.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: () async {
              await tutorialInAppWebViewController!.goForward();
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh,),
            onPressed: () async {
              if (Platform.isAndroid) {
                tutorialInAppWebViewController?.reload();
              } else if (Platform.isIOS) {
                tutorialInAppWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await tutorialInAppWebViewController?.getUrl()));
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
                  controller: tutorialSearchController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await tutorialInAppWebViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search on web...",
                    prefixIcon: Icon(Icons.search,color: tutorialPointsColor,),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: tutorialPointsColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: tutorialPointsColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (tutorialProgress < 1)
              ? LinearProgressIndicator(
            value: tutorialProgress,
            color: tutorialPointsColor,
          )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: tutorialWebViewKey,
              pullToRefreshController: tutorialPullToRefreshController,
              onWebViewCreated: (controller) {
                tutorialInAppWebViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest:
              URLRequest(url: Uri.parse("https://www.tutorialspoint.com/index.htm")),
              onLoadStart: (controller, uri) {
                setState(() {
                  tutorialSearchController.text =
                  "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                tutorialPullToRefreshController.endRefreshing();
                setState(() {
                  tutorialSearchController.text =
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
                  tutorialPullToRefreshController.endRefreshing();
                }
                setState(() {
                  tutorialProgress = val / 100;
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
            backgroundColor: tutorialPointsColor,
            child: const Icon(Icons.bookmark),
            onPressed: () async {
              Uri? uri = await tutorialInAppWebViewController!.getUrl();

              String myURL = "${uri!.scheme}://${uri.host}${uri.path}";

              setState(() {
                bookmarks.add(myURL);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: tutorialPointsColor,
                  content: const Text("Successfully Bookmarked..."),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: tutorialPointsColor,
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
                              await tutorialInAppWebViewController!.loadUrl(
                                urlRequest: URLRequest(url: Uri.parse(e)),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              e,
                              style: TextStyle(
                                  color:tutorialPointsColor
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
