import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/componants/componants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {

  // Form key
  var scaffoldKey = GlobalKey<ScaffoldState>();

  // Form field controllers
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // Form validation
  var validation = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if(state is InsertToDatabaseState)
          {
            Navigator.pop(context);
            titleController.clear();
            timeController.clear();
            dateController.clear();
          }
        },
        builder: (context, state) {
          // Cubit Object
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 5,
              title: Text(
                cubit.titles[cubit.currentIndex],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (validation.currentState.validate()) {
                    cubit.insertToDatabase
                      (
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                    );
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          child: Form(
                            key: validation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  labelText: 'Task Title',
                                  controller: titleController,
                                  type: TextInputType.text,
                                  prefix: Icons.title,
                                  validation: (String value) {
                                    if (value.isEmpty) {
                                      return 'Title must not be empty';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20.0),
                                defaultFormField(
                                  labelText: 'Task Time',
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  prefix: Icons.watch_later_outlined,
                                  validation: (String value) {
                                    if (value.isEmpty) {
                                      return 'Time must not be empty';
                                    }
                                    return null;
                                  },
                                  onTape: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text =
                                          value.format(context);
                                    });
                                  },
                                ),
                                SizedBox(height: 20.0),
                                defaultFormField(
                                  labelText: 'Task Date',
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  prefix: Icons.calendar_today,
                                  validation: (String value) {
                                    if (value.isEmpty) {
                                      return 'Date must not be empty';
                                    }
                                    return null;
                                  },
                                  onTape: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2021-06-07'),
                                    ).then((value) {
                                      dateController.text =
                                          DateFormat.yMMMd().format(value);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20,
                      ).closed.then((value) {
                        cubit.changeBottomSheetState(
                            isShow: false,
                            icon: Icons.edit
                        );
                      });
                  cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
                size: 30,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                // showUnselectedLabels: false,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                      size: 30,
                    ),
                    label: 'Tasks',
                    tooltip: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.check_circle_outline,
                        size: 30,
                      ),
                    label: 'Done',
                    tooltip: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                      size: 30,
                    ),
                    label: 'Archived',
                    tooltip: 'Archived',
                  ),
                ],
              ),
            );
        },
      ),
    );
  }
}
