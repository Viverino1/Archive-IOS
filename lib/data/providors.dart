import 'package:fbla_nlc_2024/classes.dart';
import 'package:flutter/cupertino.dart';

class UserProvidor with ChangeNotifier {
  UserData _currentUser = UserData();
  bool _isAuthenticated = false;
  List<UserData> _followers = [];
  List<UserData> _following = [];
  List<UserData> _users = [];

  UserData get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  List<UserData> get followers => _followers;
  List<UserData> get following => _following;
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
    followers.add(user);
    users.add(user);
    notifyListeners();
  }

  void addFollowing(UserData user){
    following.add(user);
    users.add(user);
    notifyListeners();
  }

  void addUser(UserData user){
    users.add(user);
    notifyListeners();
  }

  UserData? getUser(String uid){
    int index = users.indexWhere((element) => element.uid == uid);
    if(index != -1){
      return users[index];
    }else{
      return null;
    }
  }
}

class PostDataProvidor with ChangeNotifier {
  List<PostData> _userPosts = [];
  List<PostData> _feedPosts = [];

  List<PostData> get userPosts => _userPosts;
  List<PostData> get feedPosts => _feedPosts;

  void setUserPosts(List<PostData> posts){
    _userPosts = posts;
    notifyListeners();
  }

  void setFeedPosts(List<PostData> posts){
    _feedPosts = posts;
    notifyListeners();
  }
}