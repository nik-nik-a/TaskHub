import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Buckets used to group tasks by due date in the UI
enum TaskBucket { noDue, thisWeek, nextWeek, later }

// -------------------- Tasks Tab (entry) --------------------
class TabTasks extends StatefulWidget {
    const TabTasks({super.key});

    @override
    State<TabTasks> createState() => _TabTasksState();
}


// -------------------- Add/Edit Task Dialog --------------------
class _TaskEditorDialog extends StatefulWidget {
    const _TaskEditorDialog({
        super.key,
        this.initialTitle,
        this.initialDescription,
        this.initialDueDate,
        this.submitLabel = 'Add',
    });

    // Prefilled values for "Edit" flow
    final String? initialTitle;
    final String? initialDescription;
    final DateTime? initialDueDate;

    // Button label: 'Add' or 'Save'
    final String submitLabel;

    @override
    State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class TaskDraft {
    final String title;
    final String? description;
    final DateTime? dueDate;
    const TaskDraft(this.title, this.description, this.dueDate);
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
    // Controllers for the two text inputs
    final _titleCtrl = TextEditingController();
    final _descCtrl = TextEditingController();

    // Selected due date
    DateTime? _dueDate;

    // Prevents double-submit
    bool _submitted = false;

    // Helper to format "YYYY-MM-DD" inside dialog
    String _two(int n) => n.toString().padLeft(2, '0');
    String _formatDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

    // Fill fields for edit flow
    @override
    void initState() {
        super.initState();
        _titleCtrl.text = widget.initialTitle ?? '';
        _descCtrl.text = widget.initialDescription ?? '';
        _dueDate = widget.initialDueDate;
    }

    // Always dispose controllers
    @override
    void dispose() {
        _titleCtrl.dispose();
        _descCtrl.dispose();
        super.dispose();
    }

    // Confirm and return a TaskDraft to the caller
    void _submit() {
        if (_submitted) return;
        _submitted = true;
        Navigator.of(context).pop(
            TaskDraft(
                _titleCtrl.text.trim(),
                (_descCtrl.text.trim().isEmpty) ? null : _descCtrl.text.trim(),
                _dueDate,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            // Title changes for Add vs Edit
            title: Text(
                (widget.submitLabel.toLowerCase() == 'add') ? 'New task' : 'Edit task',
            ),

            // -------- Dialog body --------
            content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        // Title field
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

                        // Description field
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
                        const SizedBox(height: 12),

                        // Due date row: label + pick/clear buttons
                        Row(
                            children: [
                                Expanded(
                                    child: Text(
                                        _dueDate == null
                                            ? 'No due date'
                                            : 'Due: ${_formatDate(_dueDate!)}',
                                    ),
                                ),

                                // Pick date
                                TextButton.icon(
                                    icon: const Icon(Icons.event),
                                    label: const Text('Pick date'),
                                    onPressed: () async {
                                        final now = DateTime.now();
                                        final picked = await showDatePicker(
                                            context: context,
                                            initialDate: _dueDate ?? now,
                                            firstDate: DateTime(now.year - 1),
                                            lastDate: DateTime(now.year + 5),
                                        );
                                        if (picked != null) setState(() => _dueDate = DateTime(picked.year, picked.month, picked.day));
                                    },
                                ),

                                // Clear date
                                if (_dueDate != null) ...[
                                    IconButton(
                                        tooltip: 'Clear date',
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => setState(() => _dueDate = null),
                                    ),
                                ],
                            ],
                        ),
                    ],
                ),
            ),

            // -------- Dialog actions --------
            actions: [
                // Cancel button
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                ),
                // Add/Save button
                ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.submitLabel),
                ),
            ],
        );
    }
}

// -------------------- Task Model (local storage) --------------------
class Task {
    final String id; // Unique ID for each task
    String title;
    String? description;
    DateTime? dueDate;
    bool done;

    Task({
        required this.title, 
        this.description,
        this.dueDate,
        this.done = false,
        String? id,
    }) : id =  id ?? DateTime.now().microsecondsSinceEpoch.toString();

    // Convert to Map for JSON storage
    Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'done': done,
    };

    // Create Task object from JSON
    factory Task.fromMap(Map<String, dynamic> m) {
        final rawDue = m['dueDate'];
        DateTime? parsedDue;
        if (rawDue is String && rawDue.isNotEmpty) {
            parsedDue = DateTime.tryParse(rawDue);
        }
        return Task(
            id: m['id'] as String?,
            title: m['title'] as String,
            description: m['description'] as String?,
            done: m['done'] as bool? ?? false,
            dueDate: parsedDue,
        );
    }
}

// -------------------- Tasks Tab State --------------------
class _TabTasksState extends State<TabTasks> {
    // In-memory task list
    final List<Task> _tasks = [];

    // SharedPreferences key
    static const _kTasksKey = 'tasks_v1';

    // Which group sections are expanded
    final Map<TaskBucket, bool> _expanded = {
        TaskBucket.noDue: false,
        TaskBucket.thisWeek: false,
        TaskBucket.nextWeek: false,
        TaskBucket.later: false,
    };

    // Date helpers for list display
    String _two(int n) => n.toString().padLeft(2, '0');
    String _formatListDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';


    // -------- Add New Task --------
    Future<void> _showAddTaskDialog() async {
        final draft = await showDialog<TaskDraft>(
            context: context,
            builder: (_) => const _TaskEditorDialog(),
        );
        
        if (!mounted || draft == null) return;

        final title = draft.title.trim();
        final description = draft.description;
        final due = draft.dueDate;

        if (title.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a task title")),
            );
            return;
        }

        setState(() {
            _tasks.insert(0, Task(title: title, description: description, dueDate: due));
        });
        _saveTasks();
    }

    // -------- View Task Details --------
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

    // -------- Edit Task --------
    Future<void> _editTask(Task task) async {
        final draft = await showDialog<TaskDraft>(
            context: context,
            builder: (_) => _TaskEditorDialog(
                initialTitle: task.title,
                initialDescription: task.description,
                initialDueDate: task.dueDate,
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
            task.dueDate = draft.dueDate;

            // Collapse sections that became empty after edits
            _autoCloseEmptySections();
        });
        await _saveTasks();
    }

    // -------- Delete Task with Undo --------
    void _deleteTaskById(String id) {
        final removedIndex = _tasks.indexWhere((t) => t.id == id);
        if (removedIndex == -1) return;
        final removedTask = _tasks[removedIndex];

        setState(() {
            _tasks.removeAt(removedIndex);
            _autoCloseEmptySections();
        });
        _saveTasks();

        // Undo delete flow
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

    // -------- Load Tasks from Local Storage --------
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

    // -------- Save Tasks to Local Storage --------
    Future<void> _saveTasks() async {
        final prefs = await SharedPreferences.getInstance();
        final raw = jsonEncode(_tasks.map((t) => t.toMap()).toList());
        await prefs.setString(_kTasksKey, raw);
    }

    // Initial load
    @override
    void initState() {
        super.initState();
        _loadTasks();
    }

    // -------------------- Grouping helpers --------------------

    // Keep only the date
    DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    // Start/end of current week
    DateTime _startOfWeek(DateTime anchor) {
        final dow = anchor.weekday;
        return _dateOnly(anchor).subtract(Duration(days: dow - 1));
    }
    DateTime _endOfWeek(DateTime anchor) => _startOfWeek(anchor).add(const Duration(days: 6));

    // Decide which bucket a given due date belongs to
    TaskBucket _bucketFor(DateTime? due) {
        if (due == null) return TaskBucket.noDue;

        final today = DateTime.now();
        final d = _dateOnly(due);

        final thisStart = _startOfWeek(today);
        final thisEnd = _endOfWeek(today);
        final nextStart = thisStart.add(const Duration(days: 7));
        final nextEnd = thisEnd.add(const Duration(days: 7));

        if (d.isBefore(thisStart)) return TaskBucket.thisWeek;

        if (!d.isBefore(thisStart) && !d.isAfter(thisEnd)) return TaskBucket.thisWeek;
        if (!d.isBefore(nextStart) && !d.isAfter(nextEnd)) return TaskBucket.nextWeek;
        return TaskBucket.later;
    }

    // -------------------- Row builder (single task) --------------------
    Widget _buildTaskTile(Task task) {
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
                onTap: () => _showTaskDetails(task), // Tap to view details
                leading: Checkbox(
                    value: task.done,
                    onChanged: (checked) {
                        setState(() {
                            task.done = checked ?? false;
                        });
                        _saveTasks(); // Save after checking/unchecking
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

                // Shows optional description + optional due date
                subtitle: () {
                    final children = <Widget>[];

                    if (task.description != null && task.description!.isNotEmpty) {
                        children.add(
                            Text(
                                task.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                            ),
                        );
                    }

                    if (task.dueDate != null) {
                        children.add(
                            Text(
                                'Due: ${_formatListDate(task.dueDate!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                            ),
                        );
                    }
                    if (children.isEmpty) return null;

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                    );
                }(),

                // Actions: Edit + Delete
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
    }

    // -------------------- Section (bucket) builder --------------------
    Widget _buildSection(
        String title,
        TaskBucket key,
        List<Task> items,
    ) {
        final count = items.length;
        final enabled = count > 0; // greyed-out & non-expandable if false
        final isOpen = _expanded[key] ?? false;
        
        return Theme(
            data: Theme.of(context).copyWith(
                textTheme: enabled
                    ? null
                    : Theme.of(context).textTheme.apply(
                        bodyColor: Colors.grey,
                        displayColor: Colors.grey,
                    ),
            ),
            child: ExpansionTile(
                initiallyExpanded: isOpen!,
                onExpansionChanged: enabled
                    ? (v) => setState(() => _expanded[key] = v)
                    : null,

                // Left: bucket title
                title: Text(title),

                // Right: custom trailing (count + chevron) to avoid double arrows
                trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text(
                            '$count',
                            style: TextStyle(
                                color: enabled
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                            ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                            isOpen ? Icons.expand_less : Icons.expand_more,
                            color: enabled ? null : Colors.grey,
                        ),
                    ],
                ),

                // Map each task to a row (nothing if empty)
                children: enabled ? items.map(_buildTaskTile).toList() : const <Widget>[],
            ),
        );
    }

    // -------- Auto-close buckets that become empty --------
    void _autoCloseEmptySections() {
        final grouped = _groupTasks();
        final total =  grouped.values.fold<int>(0, (sum, list) => sum + list.length);

        // If there are no tasks at all, collapse everything
        if (total == 0) {
            for (final b in TaskBucket.values) {
                _expanded[b] = false;
            }
            return;
        }

        // For each bucket: if it's open and now empty -> close it
        for (final b in TaskBucket.values) {
            final isEmpty = (grouped[b]?.isEmpty ?? true);
            if (isEmpty && (_expanded[b] ?? false)) {
                _expanded[b] = false;
            }
        }
    }

    // -------- Group tasks into buckets and sort within each --------
    Map<TaskBucket, List<Task>> _groupTasks() {
        final Map<TaskBucket, List<Task>> g = {
            TaskBucket.noDue: [],
            TaskBucket.thisWeek: [],
            TaskBucket.nextWeek: [],
            TaskBucket.later: [],
        };

        // Place each task into its bucket
        for (final t in _tasks) {
            final b = _bucketFor(t.dueDate);
            g[b]!.add(t);
        }

        // Sort tasks inside each bucket
        for (final list in g.values) {
            list.sort(_compareTasks);
        }
        return g;
    }

    // Sort order inside a bucket:
    // 1) Incomplete first, 2) earlier due date first (nulls last), 3) title A→Z
    int _compareTasks(Task a, Task b) {
        if (a.done != b.done) return a.done ? 1 : -1;

        final ad = a.dueDate;
        final bd = b.dueDate;

        if (ad != null && bd != null) {
            final c = ad.compareTo(bd);
            if (c != 0) return c; 
        }
        if (ad != null && bd == null) return -1;
        if (ad == null && bd != null) return 1;

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }

    // -------------------- Build main UI --------------------
    @override
    Widget build(BuildContext context) {
        // Compute grouped view for the current frame
        final grouped = _groupTasks();

        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                 mainAxisSize: MainAxisSize.max,
                 children: [
                    // Add task button
                    Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add task"),
                            onPressed: _showAddTaskDialog,
                        ),
                    ),
                    const SizedBox(height: 16),

                    // Either show empty state or grouped sections
                    Expanded(
                        child: _tasks.isEmpty
                            ? const Center(
                                child: Text(
                                    "No tasks yet.\nTap 'Add task' to create your first one.",
                                    textAlign: TextAlign.center,
                                ),
                            )
                            : ListView(
                                children: [
                                    _buildSection(
                                        'No due date',
                                        TaskBucket.noDue,
                                        grouped[TaskBucket.noDue]!,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSection(
                                        'This week',
                                        TaskBucket.thisWeek,
                                        grouped[TaskBucket.thisWeek]!,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSection(
                                        'Next week',
                                        TaskBucket.nextWeek,
                                        grouped[TaskBucket.nextWeek]!,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSection(
                                        'Later',
                                        TaskBucket.later,
                                        grouped[TaskBucket.later]!,
                                    ),
                                ]
                            )
                    )
                ],
            ),
        );
    }
}