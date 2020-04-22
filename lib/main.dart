import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'screens/home_nav.dart';
import 'package:spotify_manager/creds.dart';

final authorizationUrl = Uri.parse("https://accounts.spotify.com/authorize");
const scopes = [
  'user-read-email',
  'user-read-private',
  'playlist-modify-public',
  'playlist-read-private',
  'playlist-modify-private',
  'user-library-read'
];
final tokenUrl = Uri.parse("https://accounts.spotify.com/api/token");
const redirectUrl = "rois://spotifymanager";

void main() => runApp(SpotifyManager());

class SpotifyManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Spotify Manager",
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.grey[900],
        unselectedWidgetColor: Colors.white54,
        canvasColor: Color.fromARGB(255, 20, 20, 20),
        bottomAppBarColor: Colors.grey[900],
        primaryColor: Colors.green,
        buttonColor: Colors.green[600],
        accentColor: Colors.white,
        secondaryHeaderColor: Colors.green[300],
        textTheme: TextTheme(button: TextStyle(fontSize: 16))

      ),
      home: WelcomeScreen(),);
  }

}

class SpotifyContainer extends InheritedWidget {
  final SpotifyApi client;
  final User myDetails;

  SpotifyContainer({this.client, this.myDetails, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static SpotifyContainer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SpotifyContainer>();

}

class WelcomeScreen extends StatefulWidget {
  final grant = SpotifyApi.authorizationCodeGrant(SpotifyApiCredentials(clientId, clientSecret));

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool shouldShowWebView = false;
  String authUrl;
  Key webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    authUrl = widget.grant
        .getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes)
        .toString();
    tryLoginWithRefreshToken().then((value) => setState(
            ()=>shouldShowWebView = !value));
  }

  Future<bool> tryLoginWithRefreshToken() async {
    // TODO: impl loginWithRefreshToken
    return false;
  }

  handleRedirect(String uri) async {
    if (uri == null || !uri.startsWith(redirectUrl))
      throw "invalid redirect uri";
    final client = SpotifyApi.fromAuthCodeGrant(widget.grant, uri);
    // TODO: save refresh token

    final myDetails = await client.users.me();
    navigateToApp(client, myDetails);
  }

  navigateToApp(SpotifyApi client, User myDetails){
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => SpotifyContainer(
            client: client,
            myDetails: myDetails,
            child: HomeNav())));
  }

  @override
  Widget build(BuildContext context) {
    final widget = shouldShowWebView ? WebView(
      key: webViewKey,
//      onWebViewCreated: (ctr){
//        ctr.clearCache();
//      },
      initialUrl: authUrl,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (navReq) {
        if (!navReq.url.startsWith(redirectUrl))
          return NavigationDecision.navigate;
        setState(() {
          shouldShowWebView = false;
        });
        handleRedirect(navReq.url);
        return NavigationDecision.navigate;
      },
    ) :Container(
      color: Theme.of(context).backgroundColor,
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Welcome to Spotify Manager!\r\nWe'll start right away!", textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1,),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: SizedBox(width: 70, height: 70,child: CircularProgressIndicator()),
                ),
              ])),
    );
    return Scaffold(
      body: widget
    );
  }

  @override
  void dispose() {
//    _sub.cancel();
    super.dispose();
  }
}
