class Session {
  final String accessToken;
  final String tokenType;
  final String refreshToken;
  final int expiresIn;
  final String scope;
  final String sessionId;

  Session(
      {required this.accessToken,
        required this.tokenType,
        required this.refreshToken,
        required this.expiresIn,
        required this.scope,
        required this.sessionId});

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      accessToken: map['access_token'],
      tokenType: map['token_type'],
      refreshToken: map['refresh_token'],
      expiresIn: map['expires_in'],
      scope: map['scope'],
      sessionId: map['OAuth2.SESSION_ID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'scope': scope,
      'sessionId': sessionId
    };
  }
}
