import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  // current index for navigation buttons
  int currentIndex = 0;

  // list of navigation screens
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  // list of navigation screens titles
  List<String> titles = [
    'Home',
    'Done Tasks',
    'Archived Tasks',
  ];
  // navigation index function
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  // database initialize
  Database database;

  // Tasks List Map
  List<Map> newTasks = [];

  // Done Tasks List Map
  List<Map> doneTasks = [];

  // Archived Tasks List Map
  List<Map> archivedTasks = [];

  // Create database
  void createDatabase(){
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version){
        print('database is created');
        database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value){
          print('table created');
        }).catchError((e){
          print(e.toString());
        });
      },
      onOpen: (database) {
        // get data from database
        getDataFromDatabase(database);
        print('database is opened');
      },
    ).then((value) {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  // Insert Data To database
  insertToDatabase(
      {
        @required String title,
        @required String time,
        @required String date,
      }
      ) async{
    database.transaction((txn)
    {
      txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title","$date","$time","new")'
      ).then((value)
      {
        print('$value inserted successfully');
        emit(InsertToDatabaseState());
        // get data from database
        getDataFromDatabase(database);
      }).catchError((e)
      {
        print('error in inserting ${e.toString()}');
      });
      return null;
    });
  }

  // Get Data from database
  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element){
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });
      emit (GetDataFromDatabaseState());
    });

  }

  // toggle bottom sheet button
  bool isBottomSheetShown = false;

  // Toggle icons
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  })
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit (AppChangeBottomSheetState());
  }

  // Update Database
  void updateDatabase({
    @required String status,
    @required int id,
  }) async
  {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', '$id']
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  // Delete from database function
  void deleteData({@required int id,}) async
  {
    database
        .rawDelete('DELETE FROM tasks WHERE id = ?', ['$id'])
        .then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }
}