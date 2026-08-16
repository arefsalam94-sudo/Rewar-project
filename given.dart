import 'dart:developer' as developer;

class Fruit {
  final String name;

  Fruit(this.name);

  bool sweet(String name, {int? index, double? rating}) {
    developer.log('Hello from sweet');
    return true;
  }

  void origin() {
    developer.log('Hello from origin');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fruit && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Fruit {name: $name}';
  }
}
