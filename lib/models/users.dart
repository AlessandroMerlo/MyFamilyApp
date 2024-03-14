List<String> iconsList = [
  'avocado',
  'butterfly',
  'cat',
  'dog',
  'cincillà',
  'panda',
  'poo',
  'unicorn',
];
// : const ImageIcon(AssetImage('icons/unicord.png'))

class MyUser {
  MyUser({required this.id, required this.name, iconName})
      : iconName = iconName ?? '';

  final String id;
  final String name;
  final String iconName;

  MyUser.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'],
        iconName = json['iconName'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
      };
}
