class AnimationNotFoundException implements Exception {
  AnimationNotFoundException(this.msg);

  final String msg;
  @override
  String toString() => "AnimationNotFoundException: + $msg";
}
