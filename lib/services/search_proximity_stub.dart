/// No proximity bias on non-web platforms unless set explicitly.
Future<({double longitude, double latitude})?> readBrowserProximity() async =>
    null;
