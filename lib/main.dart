import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:spotify_manager/flutter_spotify/model/user.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/home_nav.dart';
import 'package:spotify_manager/flutter_spotify/api/spotify_client.dart';

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

class WelcomeScreen extends StatefulWidget {
  static final grant = new oauth2.AuthorizationCodeGrant(
      clientId, authorizationUrl, tokenUrl,
      secret: clientSecret);
  static final authUrl = grant
      .getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes)
      .toString();

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class SpotifyContainer extends InheritedWidget {
  final SpotifyClient client;
  final PrivateUser myDetails;

  SpotifyContainer({this.client, this.myDetails, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static SpotifyContainer of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SpotifyContainer>();

}

class WelcomeScreenState extends State<WelcomeScreen> {
  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = getLinksStream().listen((String uri) async {
      if (uri == null || !uri.startsWith(redirectUrl))
        return;
      final authCode = uri.split("code=")[1];
      final client = SpotifyClient(await WelcomeScreen.grant.handleAuthorizationCode(authCode));
      final myDetails = await client.myDetails;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => SpotifyContainer(
              client: client,
              myDetails: myDetails,
              child: HomeNav())));
    });

    launch(WelcomeScreen.authUrl, forceSafariVC: false);

  }

  @override
  Widget build(BuildContext context) {
    return WelcomeBody();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class WelcomeBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spotify Manager'),
      ),
      body: Center(
          child: Column(children: <Widget>[
        Text("Welcome to Spotify Manager!\r\nPlease login to start"),
        MaterialButton(
          child: Text("LOGIN"),
          onPressed: () async {
            final authUrl = WelcomeScreen.authUrl;
            await launch(authUrl, forceSafariVC: false);
          },
          color: Colors.green,
        ),
      ])),
    );
  }
}