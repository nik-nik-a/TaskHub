import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TabTasks extends StatefulWidget {
    const TabTasks({super.key});

    @override
    State<TabTasks> createState() => _TabTasksState();
}

class _TaskEditorDialog extends StatefulWidget {
    const _TaskEditorDialog({
        super.key,
        this.initialTitle,
        this.initialDescription,
        this.submitLabel = 'Add',
    });

    final String? initialTitle;
    final String? initialDescription;
    final String submitLabel;

    @override
    State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class TaskDraft {
    final String title;
    final String? description;
    const TaskDraft(this.title, this.description);
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
    final _titleCtrl = TextEditingController();
    final _descCtrl = TextEditingController();
    bool _submitted = false;

    void _submit() {
        if (_submitted) return;
        _submitted = true;
        Navigator.of(context).pop(
            TaskDraft(
                _titleCtrl.text.trim(),
                (_descCtrl.text.trim().isEmpty) ? null : _descCtrl.text.trim(),
            ),
        );
    }

    @override
    void dispose() {
        _titleCtrl.dispose();
        _descCtrl.dispose();
        super.dispose();
    }

    @override
    void initState() {
        super.initState();
        _titleCtrl.text = widget.initialTitle ?? '';
        _descCtrl.text = widget.initialDescription ?? '';
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: Text(
                (widget.submitLabel.toLowerCase() == 'add') ? 'New task' : 'Edit task',
            ),
            content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        TextField(
                            controller: _titleCtrl,
                            autofocus: true,
                            decoration: const InputDecoration(
                                labelText: "Task title",
                                border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            maxLength: 120,
                        ),
                        const SizedBox(height: 12),

                        TextField(
                            controller: _descCtrl,
                            decoration: const InputDecoration(
                                labelText: "Description (optional)",
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                            ),
                            minLines: 3,
                            maxLines: 8,
                            maxLength: 1500,
                            onSubmitted: (_) => _submit(),
                        ),
                    ],
                ),
            ),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                ),
                ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.submitLabel),
                ),
            ],
        );
    }
}

class Task {
    final String id;
    String title;
    String? description;
    bool done;

    Task({
        required this.title, 
        this.description,
        this.done = false,
        String? id,
    }) : id =  id ?? DateTime.now().microsecondsSinceEpoch.toString();

    Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'done': done,
    };

    factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'] as String?,
        title: m['title'] as String,
        description: m['description'] as String?,
        done: m['done'] as bool? ?? false,
    );
}

class _TabTasksState extends State<TabTasks> {
    final List<Task> _tasks = [];
    static const _kTasksKey = 'tasks_v1';

    Future<void> _showAddTaskDialog() async {
        final draft = await showDialog<TaskDraft>(
            context: context,
            builder: (_) => const _TaskEditorDialog(),
        );
        
        if (!mounted || draft == null) return;

        final title = draft.title.trim();
        final description = draft.description;

        if (title.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a task title")),
            );
            return;
        }

        setState(() {
            _tasks.insert(0, Task(title: title, description: description));
        });
        _saveTasks();
    }

    void _showTaskDetails(Task task) {
        showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
                title: const Text('Task details'),
                content: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text(
                                'Title:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),

                            SelectableText(task.title),
                            const SizedBox(height: 12),

                            const Text(
                                'Description:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),

                            SelectableText(
                                task.description?.isNotEmpty == true ? task.description! : '-'
                            ),
                            const SizedBox(height: 4),
                        ],
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                    ),
                ],
            ),
        );
    }

    Future<void> _editTask(Task task) async {
        final draft = await showDialog<TaskDraft>(
            context: context,
            builder: (_) => _TaskEditorDialog(
                initialTitle: task.title,
                initialDescription: task.description,
                submitLabel: 'Save',
            ),
        );

        if (!mounted || draft == null) return;

        final newTitle = draft.title.trim();
        final newDesc = (draft.description?.trim().isEmpty ?? true) ? null : draft.description!.trim();

        if (newTitle.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a task title")),
            );
            return;
        }

        setState(() {
            task.title = newTitle;
            task.description = newDesc;
        });
        await _saveTasks();
    }

    void _deleteTaskById(String id) {
        final removedIndex = _tasks.indexWhere((t) => t.id == id);
        if (removedIndex == -1) return;
        final removedTask = _tasks[removedIndex];

        setState(() => _tasks.removeAt(removedIndex));
        _saveTasks();

        ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
            SnackBar(
                content: Text(
                    "Deleted '${removedTask.title}'",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
                action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                        final insertAt = removedIndex.clamp(0, _tasks.length);
                        setState(() => _tasks.insert(insertAt, removedTask));
                        _saveTasks();
                    },
                ),
                duration: const Duration(seconds: 3),
            ),
            );    
    }

    Future<void> _loadTasks() async {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_kTasksKey);
        if (raw == null) return;

        try {
            final decoded = jsonDecode(raw);
            if (decoded is! List) return;

            final loaded = decoded.map<Task>((e) {
                final map = Map<String, dynamic>.from(e as Map);
                return Task.fromMap(map);
            }).toList();

            setState(() {
                _tasks
                    ..clear()
                    ..addAll(loaded);
            });
        } catch (e) {
            debugPrint('Failed to load tasks: $e');
        }
    }

    Future<void> _saveTasks() async {
        final prefs = await SharedPreferences.getInstance();
        final raw = jsonEncode(_tasks.map((t) => t.toMap()).toList());
        await prefs.setString(_kTasksKey, raw);
    }

    @override
    void initState() {
        super.initState();
        _loadTasks();
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                 mainAxisSize: MainAxisSize.max,
                 children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add task"),
                            onPressed: _showAddTaskDialog,
                        ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                        child: _tasks.isEmpty
                            ? const Center(
                                child: Text(
                                    "No tasks yet.\nTap 'Add task' to create your first one.",
                                    textAlign: TextAlign.center,
                                ),
                            )
                            : ListView.builder(
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) {
                                    final task = _tasks[index];
                                    return Dismissible(
                                        key: ValueKey(task.id),
                                        direction: DismissDirection.horizontal,
                                        background: Container(
                                            color: Colors.red.withOpacity(0.15),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(left: 16),
                                            child: const Icon(Icons.delete, color: Colors.red),
                                        ),
                                        secondaryBackground: Container(
                                            color: Colors.red.withOpacity(0.15),
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(right: 16),
                                            child: const Icon(Icons.delete, color: Colors.red),
                                        ),
                                        onDismissed: (_) => _deleteTaskById(task.id),
                                        child: ListTile(
                                            onTap: () => _showTaskDetails(task),
                                            leading: Checkbox(
                                                value: task.done,
                                                onChanged: (checked) {
                                                    setState(() {
                                                        task.done = checked ?? false;
                                                    });
                                                    _saveTasks();
                                                },
                                            ),    
                                            title: Text(
                                                task.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    decoration:
                                                    task.done ? TextDecoration.lineThrough : null,
                                                ),
                                            ),
                                            subtitle: (task.description == null || task.description!.isEmpty)
                                                ? null
                                                : Text(
                                                    task.description!,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    IconButton(
                                                        tooltip: 'Edit',
                                                        icon: const Icon(Icons.edit_outlined),
                                                        onPressed: () => _editTask(task),
                                                    ),
                                                    IconButton(
                                                        tooltip: 'Delete',
                                                        icon: const Icon(Icons.delete_outline),
                                                        onPressed: () => _deleteTaskById(task.id),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    );
                                },
                            ),
                    )
                 ],
            ),
        );
    }
}