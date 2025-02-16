```dart import 'package:flutter/material.dart' hide View;
import 'ui_apis.dart';
import 'view_builder.dart';

class TodoItem {
  String text;
  bool isCompleted;
  String? viewId;
  TodoItem({required this.text, this.isCompleted = false});
}

class AppState {
  List<TodoItem> todos = [];
  String? contentStack;
}

void main() {
  runApp(const SizedBox());
  mainApp();
}

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  final bridge = NativeUIBridge();

  final rootId = (await bridge.getRootView())!['viewId'] as String;

  // Build the entire UI tree using nested syntax
  final app = View.vStack()
      .add(View.create('View')
          .backgroundColor(Colors.deepPurple)
          .layout(height: 120)
          .fillWidth()
          .add(View.vStack(
            spacing: 16,
            alignment: FlexAlignment.start,
            padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
          )
              .add(View.label('Todo App',
                      props: ViewProps(textColor: Colors.white))
                  .fillWidth())
              .add(View.button('Add New Todo',
                  props: ViewProps(
                    backgroundColor: Colors.amber,
                    width: 150,
                    alignment: FlexAlignment.center,
                  )).onClick(() async {
                final todo = TodoItem(text: 'Todo ${state.todos.length + 1}');
                state.todos.add(todo);
                final todoView = createTodoItemView(todo);
                todo.viewId = await todoView.viewId;
                await bridge.attachView(state.contentStack!, todo.viewId!);
              }))))
      .add(View.scroll(
        axis: ScrollAxis.vertical,
        padding: EdgeInsets.all(16),
      )
          .fillWidth()
          .layout(flex: 1)
          .setContent(View.vStack(spacing: 8).chain((id) async {
            state.contentStack = id;
            return id;
          })));

  // Attach to root
  final appId = await app.viewId;
  await bridge.attachView(rootId, appId);
}

View createTodoItemView(TodoItem todo) {
  return View.create('View')
      .backgroundColor(Colors.grey[200] ?? Colors.grey)
      .layout(height: 60)
      .fillWidth()
      .add(View.hStack(
        spacing: 16,
        alignment: FlexAlignment.spaceBetween,
        padding: EdgeInsets.symmetric(horizontal: 16),
      )
          .add(View.button(todo.isCompleted ? '✓' : '○',
              props: ViewProps(
                width: 40,
                height: 40,
                backgroundColor: todo.isCompleted ? Colors.green : Colors.grey,
              )).onClick(() async {
            todo.isCompleted = !todo.isCompleted;
            if (todo.viewId != null) {
              await NativeUIBridge().updateView(todo.viewId!, {
                'title': todo.isCompleted ? '✓' : '○',
              });
            }
          }))
          .add(View.label(todo.text,
              props: ViewProps(
                textColor: todo.isCompleted ? Colors.grey : Colors.black,
                flex: 1,
              )))
          .add(View.button('×',
              props: ViewProps(
                width: 40,
                height: 40,
                backgroundColor: Colors.red,
              )).onClick(() async {
            if (todo.viewId != null) {
              await NativeUIBridge().deleteView(todo.viewId!);
            }
          })));
}
```