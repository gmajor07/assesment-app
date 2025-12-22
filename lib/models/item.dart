class Item {
  final int id;
  final String name;
  final double price;

  Item({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      price: double.parse(json['price'].toString()),
    );
  }
}
