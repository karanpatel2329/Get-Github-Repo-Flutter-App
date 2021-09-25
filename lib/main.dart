import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jakes_git/model/repository.dart';
import 'package:jakes_git/screen/biometric.dart';
import 'package:jakes_git/screen/login.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(

        title: 'Jakes Git',
        theme: ThemeData(
          primarySwatch: MaterialColor(
            0xFF000000,
            const <int, Color>{
              50: const Color(0xFF000000),
              100: const Color(0xFF000000),
              200: const Color(0xFF000000),
              300: const Color(0xFF000000),
              400: const Color(0xFF000000),
              500: const Color(0xFF000000),
              600: const Color(0xFF000000),
              700: const Color(0xFF000000),
              800: const Color(0xFF000000),
              900: const Color(0xFF000000),
            },
          ),

        ),
        debugShowCheckedModeBanner: false,
        home: SignIn());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 1;

  late int totalPages=10;

  List<Repo> repoList = [];
  bool fullyLoad = false;
  late User _firebaseUser;
  final RefreshController refreshController =
  RefreshController(initialRefresh: true);

  Future<bool> getRepoData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
    } else {
      if (fullyLoad) {
        refreshController.loadNoData();
        return false;
      }
    }
    print("78");
    final Uri uri = Uri.parse(
        "https://api.github.com/users/karanpatel2329/repos?page="+currentPage.toString()+"&per_page=10");

    final response = await http.get(uri);
    //print();
    print(response.body.length);
    if(response.body.toString()=="[]"){
      print("EMPTY");
      fullyLoad=true;

    }
    if (response.statusCode == 200) {
      //final result = RepoDataFromJson(response.body);
      print("hell");
      print(currentPage);
        final result = getList(response.body);
      if (isRefresh) {
        repoList=result;
      }else{
        repoList.addAll(result);
      }

      currentPage++;

      totalPages = 1500;

      //print(response.body);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  Future<void> _logout() async {
    try {
      // signout code
      await FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignIn()));
      print("here");
    } catch (e) {
      print(e);
    }
  }
@override
  void initState() {
    print(repoList.length);
    getRepoData();
    Firebase.initializeApp();
    //Firebase.initializeApp();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Jake's Git"),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          GestureDetector(child: Icon(Icons.logout), onTap: (){
            _logout();
            },),
        ],
      ),
      body: Scrollbar(
        thickness: 8.0,
        child: SmartRefresher(
          controller: refreshController,
          enablePullUp: true,
          onRefresh: () async {
            if (fullyLoad) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          },
          onLoading: () async {
            final result = await getRepoData();
            if (result) {
              refreshController.loadComplete();
            }
          },  
          child: ListView.separated(
            itemBuilder: (context, index) {
              final repo = repoList[index];

              return Container(
                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 1),
                child:Row(
                  children: [
                    Container(
                      child: Icon(Icons.book,size: 40,),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(repo.name,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.005,
                        ),
                         SizedBox(width:MediaQuery.of(context).size.width*0.8 ,child: Text(repo.description,style:TextStyle(fontSize: 15),maxLines: 10,)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.008,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("< > "),
                                Text(repo.language),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.01,
                            ),
                            Row(
                              children: [
                                Icon(Icons.star_border_outlined),
                                Text(repo.star.toString()),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.01,
                            ),
                            Row(
                              children: [
                                Icon(FontAwesomeIcons.codeBranch, size: 15,),
                                Text(repo.star.toString()),
                              ],
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(

              thickness: 5,
            ),
            itemCount: repoList.length,
          ),
        ),
      ),
    );
  }

  getList(String body) {
    int? prev;
    List<Repo> list=[];
    list.clear();
    var data = json.decode(body);
    for (int i=0;i<data.length;i++){
      print(data[i]["name"]);
     Repo repo = Repo(name: data[i]["name"],language: data[i]["language"]??"null", description:data[i]["description"]??"null" ,star:data[i]["stargazers_count"] ,fork:data[i]["forks_count"] );
      //print(repoList.contains(repo));
     repoList.add(repo);
    }
    print(fullyLoad);
    return list;
  }
}

