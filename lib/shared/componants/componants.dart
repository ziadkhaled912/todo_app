import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  @required Function onPressed,
  @required String text,
  bool isUpperCase = true,
}) =>
    Container(
      width: double.infinity,
      height: 50,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Colors.blueAccent,
        onPressed: onPressed,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );

Widget defaultFormField({
  @required String labelText,
  @required TextEditingController controller,
  @required Function validation,
  TextInputType type,
  IconData prefix,
  IconData suffix,
  String hintText,
  Function onSubmit,
  Function onTape,
  bool secure = false,
  Function onPressed,
  bool isClickable = true,
}) =>
    TextFormField(
      validator: validation,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: IconButton(
          onPressed: onPressed,
          icon: Icon(suffix),
        ),
        border: OutlineInputBorder(),
      ),
      keyboardType: type,
      textInputAction: TextInputAction.next,
      onTap: onTape,
      enabled: isClickable,
      onFieldSubmitted: onSubmit,
      obscureText: secure,
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        color: Colors.green,
        child: Icon(
          Icons.archive_sharp,
          color: Colors.white,
          size: 32,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        color: Colors.red,
        child: Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text('${model['time']}'),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 20.0),
            IconButton(
              icon: Icon(
                Icons.check_box,
                color: Colors.green,
              ),
              onPressed: () {
                AppCubit.get(context).updateDatabase(
                  status: 'done',
                  id: model['id'],
                );
              },
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        switch (direction){
          case DismissDirection.endToStart:
            AppCubit.get(context).deleteData(id: model['id']);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Task has been deleted'),
            ));
            break;
          case DismissDirection.startToEnd:
              AppCubit.get(context).updateDatabase(
                status: 'archived',
                id: model['id'],
              );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Task has been archived'),
              ));
              break;
          default:
            break;
        }
      },
    );

Widget tasksBuilder({
  @required List<Map> tasks,
  // @required String text,
}) =>
    ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) => ListView.separated(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => Container(
          width: double.infinity,
          height: 1.0,
          color: Colors.grey[300],
        ),
        itemCount: tasks.length,
      ),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              'No Tasks Yet, Please Add Some Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
