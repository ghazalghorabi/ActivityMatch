import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'profile_page.dart';
import 'login_page.dart';
import 'todo.dart';
import 'model.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoModel(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActivityMatch',
      //home: const ProfilePage(),
      home: const LoginPage(),
      //home: const NotificationsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


class Todowidget extends StatelessWidget {
  final Todo item;


  const Todowidget({super.key, required this.item});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {
              context.read<TodoModel>().toggleTodo(item);
            },
            icon: Icon(
              item.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              size: 32,
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 25,
                decoration: item.done
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<TodoModel>().deleteTodo(item);
            },
            icon: const Icon(
              Icons.close,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}


class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});


  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}


class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController controller = TextEditingController();


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'CLS055 TODO',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 28,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 50,
        ),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'What are you going to do?',
                hintStyle: TextStyle(fontSize: 20),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
            const SizedBox(height: 50),
            TextButton.icon(
              onPressed: () async {
                final title = controller.text.trim();


                if (title.isEmpty) {
                  return;
                }


                await context.read<TodoModel>().addTodo(title);


                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ),
              label: const Text(
                'ADD',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();


    Future.microtask(() {
      context.read<TodoModel>().loadTodos();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: const Text(
          'CLS055 TODO',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onSelected: (value) {
              context.read<TodoModel>().setFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('all'),
              ),
              const PopupMenuItem(
                value: 'done',
                child: Text('done'),
              ),
              const PopupMenuItem(
                value: 'undone',
                child: Text('undone'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TodoModel>(
        builder: (context, model, child) {
          return ListView(
            children: model.todos
                .map((item) => Todowidget(item: item))
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTodoPage(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

