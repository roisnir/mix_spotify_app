import 'package:oauth2/oauth2.dart' as oauth2;

//const client_id = "1f18caf5f1be400dbea59fc8e61f4502";
//const client_secret = "";
//const authorization_url = "";
//const token_url = "";
//const redirect_url = "rois://spotifymanager";


Uri getAuthorizationCode(String clientId, String authorizationUrl, String redirectUri, String tokenUrl, String clientSecret)
{
  var grant = new oauth2.AuthorizationCodeGrant(
      clientId, Uri.parse(authorizationUrl), Uri.parse(tokenUrl), secret: clientSecret);
  return grant.getAuthorizationUrl(Uri.parse(redirectUri));
}


//SpotifyClient authorize(String clientId, String authorizationUrl, String redirectUri)
//{
//  final accessToken = '';
//  return SpotifyClient(accessToken);
//}
