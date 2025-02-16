import 'dart:math';
import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MainApp');
final NativeUIBridge bridge = NativeUIBridge();

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
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(
      (record) => debugPrint('${record.level.name}: ${record.message}'));
  runApp(const SizedBox());
  mainApp();
}

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();

  final rootInfo = await bridge.getRootView();
  if (rootInfo == null) return;
  final rootId = rootInfo['viewId'] as String;

  // Create main stack and ensure it fills the root view
  final mainStack = await bridge.createVStack(spacing: 0);
  if (mainStack == null) return;
  await bridge.attachView(rootId, mainStack);
  await bridge.setViewToFillParent(mainStack);

  // Create header
  final header = await bridge.createView('View');
  if (header == null) return;
  await bridge.attachView(mainStack, header);
  await bridge.setViewBackgroundColor(header, Colors.deepPurple);
  await bridge.setViewLayout(header, height: 120);
  await bridge.setViewToFillWidth(header);

  // Create header stack with proper padding
  final headerStack = await bridge.createVStack(
    spacing: 16,
    padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
  );
  if (headerStack == null) return;
  await bridge.attachView(header, headerStack);
  await bridge.setViewToFillParent(headerStack);

  // Add title label
  final titleLabel = await bridge.createView('Label');
  if (titleLabel == null) return;
  await bridge.attachView(headerStack, titleLabel);
  await bridge.updateView(titleLabel, {
    'text': 'Todo App',
    'textColor': Colors.white,
  });
  await bridge.setViewToFillWidth(titleLabel);

  // Add button
  final addButton = await bridge.createView('Button');
  if (addButton == null) return;
  await bridge.attachView(headerStack, addButton);
  await bridge.updateView(addButton, {'title': 'Add New Todo'});
  await bridge.setViewBackgroundColor(addButton, Colors.blue);
  await bridge.setViewToFillWidth(addButton);

  // Create scroll container for todos
  final scrollView = await bridge.createScrollView(
    axis: ScrollAxis.vertical,
    padding: EdgeInsets.all(16),
  );
  if (scrollView == null) return;
  await bridge.attachView(mainStack, scrollView);
  await bridge.setViewToFillWidth(scrollView);
  await bridge.setViewLayout(scrollView, flex: 1);

  // Create todo list stack
  final todoList = await bridge.createVStack(spacing: 8);
  if (todoList == null) return;
  await bridge.setScrollContent(scrollView, todoList);
  await bridge.setViewToFillWidth(todoList);
  state.contentStack = todoList;

  // Add button click handler
  await bridge.registerEvent(addButton, 'onClick', () async {
    final todo = TodoItem(text: 'Todo ${state.todos.length + 1}');
    state.todos.add(todo);
    
    final todoView = await createTodoItemView(state, todo);
    if (todoView == null) return;
    
    todo.viewId = todoView;
    await bridge.attachView(state.contentStack!, todoView);
  });
}

Future<String?> createTodoItemView(AppState state, TodoItem todo) async {
  final itemContainer = await bridge.createView('View');
  if (itemContainer == null) return null;

  await bridge.setViewBackgroundColor(itemContainer, Colors.grey[200]);
  await bridge.setViewToFillWidth(itemContainer);
  await bridge.setViewLayout(itemContainer, height: 60);

  final rowStack = await bridge.createHStack(
    spacing: 16,
    alignment: FlexAlignment.spaceBetween,
    padding: EdgeInsets.symmetric(horizontal: 16),
  );
  if (rowStack == null) return null;
  
  await bridge.attachView(itemContainer, rowStack);
  await bridge.setViewToFillParent(rowStack);

  // Create checkbox button
  final checkbox = await bridge.createView('Button');
  if (checkbox == null) return null;
  await bridge.attachView(rowStack, checkbox);
  await bridge.updateView(checkbox, {'title': todo.isCompleted ? '✓' : '○'});
  await bridge.setViewBackgroundColor(
    checkbox,
    todo.isCompleted ? Colors.green : Colors.grey,
  );
  await bridge.setViewLayout(checkbox, width: 40, height: 40);

  // Create label
  final label = await bridge.createView('Label');
  if (label == null) return null;
  await bridge.attachView(rowStack, label);
  await bridge.updateView(label, {
    'text': todo.text,
    'textColor': todo.isCompleted ? Colors.grey : Colors.black,
  });
  await bridge.setViewLayout(label, flex: 1);

  // Create delete button
  final deleteBtn = await bridge.createView('Button');
  if (deleteBtn == null) return null;
  await bridge.attachView(rowStack, deleteBtn);
  await bridge.updateView(deleteBtn, {'title': '×'});
  await bridge.setViewBackgroundColor(deleteBtn, Colors.red);
  await bridge.setViewLayout(deleteBtn, width: 40, height: 40);

  // Add checkbox handler
  await bridge.registerEvent(checkbox, 'onClick', () async {
    todo.isCompleted = !todo.isCompleted;
    await bridge.updateView(checkbox, {'title': todo.isCompleted ? '✓' : '○'});
    await bridge.setViewBackgroundColor(
      checkbox,
      todo.isCompleted ? Colors.green : Colors.grey,
    );
    await bridge.updateView(label, {
      'textColor': todo.isCompleted ? Colors.grey : Colors.black,
    });
  });

  // Add delete handler
  await bridge.registerEvent(deleteBtn, 'onClick', () async {
    if (todo.viewId != null) {
      await bridge.deleteView(todo.viewId!);
      state.todos.remove(todo);
    }
  });

  return itemContainer;
}
