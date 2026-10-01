class Todo {
  final String? id;
  final String title;
  final bool done;

  const Todo({this.id, required this.title, required this.done});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json['id'], title: json['title'], done: json['done']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'done': done};
  }
}
