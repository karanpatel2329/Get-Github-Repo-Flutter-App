import 'dart:convert';

Repo RepoDataFromJson(String str) => Repo.fromJson(json.decode(str));
class Repo{
  String name;
  String description;
  String language;
  int fork;
  int star;
  late List<Repo> data;
  Repo({required this.name, required this.description, required this.star, required this.fork, required this.language});
  factory Repo.fromJson(var json){
    print(json[0]);
   return Repo(name: json["name"],language: json["language"], description:json["description"] ,star:json["stargazers_count"] ,fork:json["forks_count"] );
  }
  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}