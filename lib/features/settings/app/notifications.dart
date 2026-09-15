import 'package:flutter/material.dart';
import 'package:wasteful/core/widgets/app_bar.dart';

class NotificationsScree  extends StatefulWidget {
  const NotificationsScree({super.key});

  @override
  State<NotificationsScree> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsScree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        title: "Notifications",
      ),
      body: SingleChildScrollView(),
    );
  }
}  
