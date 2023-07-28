class Note {
  Note({this.id, required this.title, required this.desc, required this.date});
  int? id;

  String title;
  String desc;
  DateTime date;

  //convert note object to map object
  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        desc = json['desc'],
        date = json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now();
}
