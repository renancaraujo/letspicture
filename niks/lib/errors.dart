class LayerHydrationError extends Error {
  final Object message;
  LayerHydrationError(this.message);
  String toString() => message;
}

class LayerInstallationError extends Error {
  final Object message;
  LayerInstallationError(this.message);
  String toString() => message;
}

class BitmapFilterHydrationError extends Error {
  final Object message;
  BitmapFilterHydrationError(this.message);
  String toString() => message;
}
