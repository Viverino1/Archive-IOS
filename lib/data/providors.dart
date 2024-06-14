import 'package:fbla_nlc_2024/classes.dart';
import 'package:fbla_nlc_2024/services/firebase/firestore/db.dart';
import 'package:flutter/cupertino.dart';

class UserProvidor with ChangeNotifier {
  UserData _currentUser = UserData();
  bool _isAuthenticated = false;
  List<String> _followers = [];
  List<String> _following = [];
  List<UserData> _users = [];

  UserData get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  List<String> get followers => _followers;
  List<String> get following => _following;
  List<UserData> get users => _users;

  void setCurrentUser(UserData user) {
    _currentUser = user;
    notifyListeners();
  }

  void setIsAuthenticated(bool isAuth) {
    _isAuthenticated = isAuth;
    notifyListeners();
  }

  void addFollower(UserData user){
    if(!followers.contains(user.uid)){
      followers.add(user.uid);
    }
    if(users.indexWhere((e) => e.uid == user.uid) < 0){
      users.add(user);
    }
    notifyListeners();
  }

  void addFollowing(UserData user){
    if(!following.contains(user.uid)){
      following.add(user.uid);
    }
    if(users.indexWhere((e) => e.uid == user.uid) < 0){
      users.add(user);
    }
    notifyListeners();
  }

  void addUser(UserData user){
    if(users.indexWhere((e) => e.uid == user.uid) < 0){
      users.add(user);
    }
    notifyListeners();
  }

  Future<UserData?> getUser(String uid) async{
    int index = users.indexWhere((element) => element.uid == uid);
    if(index > -1){
      return users[index];
    }else{
      return await Firestore.getUser(uid);
    }
  }
}