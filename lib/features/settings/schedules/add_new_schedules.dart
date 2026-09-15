import 'package:flutter/material.dart';
import 'package:wasteful/core/widgets/app_bar.dart';

class AddNewSchedulesScreen extends StatefulWidget{

  const AddNewSchedulesScreen({super.key});

  @override
  State<AddNewSchedulesScreen> createState() => _AddNewSchedulesState();
}

class _AddNewSchedulesState extends State<AddNewSchedulesScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        title: "Add New Schedule"
      ),
      body: SingleChildScrollView(

      ),
    );
  }

}  
