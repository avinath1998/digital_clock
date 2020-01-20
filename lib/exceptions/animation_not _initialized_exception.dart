class ArtboardNotInitializedException implements Exception {
  ArtboardNotInitializedException(this.msg);

  final String msg;
  String toString() => 'ArtboardNotInitializedException: $msg';
}
