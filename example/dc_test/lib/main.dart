import 'package:dc_test/ui_apis.dart';
import 'package:flutter/material.dart';

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

  // Create main stack with full width
  final mainStack =
      await bridge.createSafeStack(StackType.vertical, spacing: 0);
  await bridge.attachView(rootId, mainStack);
  await bridge.setViewToFillParent(mainStack);

  // Create header with proper constraints
  final header = await bridge.createSafeView('View');
  await bridge.attachView(mainStack, header);
  await bridge.setViewBackgroundColor(header, Colors.deepPurple);
  await bridge.setViewLayout(header, height: 120);
  await bridge.setViewToFillWidth(header);

  // Create header stack with left alignment
  final headerStack = await bridge.createSafeStack(
    StackType.vertical,
    spacing: 16,
    alignment: FlexAlignment.start, // Add this
    padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
  );
  await bridge.attachView(header, headerStack);
  await bridge.setViewToFillParent(headerStack);

  // Add title with full width
  final titleLabel = await bridge.createSafeView('Label');
  await bridge.attachView(headerStack, titleLabel);
  await bridge.updateView(titleLabel, {
    'text': 'Todo App',
    'textColor': Colors.white,
    'alignment': 'left', // Add this
  });
  await bridge.setViewToFillWidth(titleLabel);

  // Add button with proper layout
  final addButton = await bridge.createSafeButton('Add New Todo');
  await bridge.attachView(headerStack, addButton);
  await bridge.setViewBackgroundColor(addButton, Colors.amber);
  await bridge.setViewLayout(
    addButton,
    width: 150,
    alignment: FlexAlignment.center, // This aligns within parent
  );

  // Create scroll view
  final scrollView = await bridge
      .createScrollView(
        axis: ScrollAxis.vertical,
        padding: EdgeInsets.all(16),
      )
      .safeView();
  await bridge.attachView(mainStack, scrollView);
  await bridge.setViewToFillWidth(scrollView);
  await bridge.setViewLayout(scrollView, flex: 1);

  // Create todo list container
  final todoList = await bridge.createSafeStack(StackType.vertical, spacing: 8);
  await bridge.setScrollContent(scrollView, todoList);
  state.contentStack = todoList;

  // Modified event handler with debug logging
  await bridge.registerEvent(addButton, 'onClick', () async {
    print('Add button clicked'); // Debug log
    final todo = TodoItem(text: 'Todo ${state.todos.length + 1}');
    state.todos.add(todo);

    final itemView = await createTodoItemView(bridge, state, todo);
    todo.viewId = itemView;

    print(
        'Attaching new todo item to stack: ${state.contentStack}'); // Debug log
    await bridge.attachView(state.contentStack!, itemView);
  });
}

// Fix todo items to fill width
Future<String> createTodoItemView(
    NativeUIBridge bridge, AppState state, TodoItem todo) async {
  final itemContainer = await bridge.createSafeView('View');
  await bridge.setViewBackgroundColor(itemContainer, Colors.grey[200]);
  await bridge.setViewLayout(itemContainer, height: 60);
  await bridge.setViewToFillWidth(itemContainer); // Make sure item fills width

  final rowStack = await bridge.createSafeStack(
    StackType.horizontal,
    spacing: 16,
    alignment: FlexAlignment.spaceBetween,
    padding: EdgeInsets.symmetric(horizontal: 16),
  );
  await bridge.attachView(itemContainer, rowStack);
  await bridge.setViewToFillParent(rowStack);

  // Create buttons with fixed sizes
  final checkbox = await bridge.createSafeButton(todo.isCompleted ? '✓' : '○');
  await bridge.attachView(rowStack, checkbox);
  await bridge.setViewLayout(checkbox, width: 65, height: 65);
  await bridge.setViewBackgroundColor(
      checkbox, todo.isCompleted ? Colors.green : Colors.grey);

  final label = await bridge.createSafeView('Label');
  await bridge.attachView(rowStack, label);
  await bridge.updateView(label, {
    'text': todo.text,
    'textColor': todo.isCompleted ? Colors.grey : Colors.black,
  });
  await bridge.setViewLayout(label, flex: 1);

  final deleteBtn = await bridge.createSafeButton('×');
  await bridge.attachView(rowStack, deleteBtn);
  await bridge.setViewLayout(deleteBtn, width: 40, height: 40);
  await bridge.setViewBackgroundColor(deleteBtn, Colors.red);

  // Add handlers
  await bridge.registerEvent(checkbox, 'onClick', () async {
    todo.isCompleted = !todo.isCompleted;
    await bridge.updateView(checkbox, {'title': todo.isCompleted ? '✓' : '○'});
    await bridge.setViewBackgroundColor(
        checkbox, todo.isCompleted ? Colors.green : Colors.grey);
    await bridge.updateView(
        label, {'textColor': todo.isCompleted ? Colors.grey : Colors.black});
  });

  await bridge.registerEvent(deleteBtn, 'onClick', () async {
    await bridge.deleteView(todo.viewId!);
    state.todos.remove(todo);
  });

  return itemContainer;
}
