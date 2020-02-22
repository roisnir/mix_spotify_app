import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'screens/home_nav.dart';

const clientId = "1f18caf5f1be400dbea59fc8e61f4502";
const clientSecret = "bf7619c5e1c84cc89adc149f286b8d9f";
final authorizationUrl = Uri.parse("https://accounts.spotify.com/authorize");
const scopes = [
  'user-read-email',
  'user-read-private',
  'playlist-modify-public',
  'user-library-modify',
  'playlist-read-private',
  'playlist-modify-private',
  'user-library-read',
  'user-top-read'
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
  static final grant = SpotifyApi.authorizationCodeGrant(SpotifyApiCredentials(clientId, clientSecret));
  static final authUrl = grant
      .getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes)
      .toString();

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  bool shouldShowWebView = false;
  Key webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
    try {
      final client = SpotifyApi.fromAuthCodeGrant(WelcomeScreen.grant, uri);
      final myDetails = await client.users.me();
      navigateToApp(client, myDetails);
    }
    on StateError{
    }
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
    final widgets = <Widget>[
      Container(
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
      ),
      WebView(
        key: webViewKey,
        initialUrl: WelcomeScreen.authUrl,
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
      )
    ];
    if (!shouldShowWebView)
      widgets.insert(0, widgets.removeLast());
    return Scaffold(
      body: Stack(children: widgets,)
    );
  }

  @override
  void dispose() {
//    _sub.cancel();
    super.dispose();
  }
}
