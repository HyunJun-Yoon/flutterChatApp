import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_profile.dart';

class PostTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;
  final String message;
  final String userID;

  const PostTile({
    super.key,
    required this.userProfile,
    required this.onTap,
    required this.message,
    required this.userID,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          userProfile.pfpURL!,
        ),
      ),
      title: Text(
        userProfile.name!,
      ),
      subtitle: Text(
        message,
      ),
    );
  }
}
