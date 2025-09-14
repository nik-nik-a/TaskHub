import 'package:flutter/material.dart';
import 'tab_home.dart';
import 'tab_timetable.dart';
import 'tab_chats.dart';
import 'tab_tasks.dart';
import 'tab_notes.dart';

class AppShell extends StatefulWidget {
    const AppShell({super.key});

    @override
    State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
    int _currentIndex = 0;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "TaskHub",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                    ),
                ),
            centerTitle: true,
            ),
            body: IndexedStack(
                index: _currentIndex,
                children: const [
                    TabHome(),
                    TabTimetable(),
                    TabChats(),
                    TabTasks(),
                    TabNotes(),
                ],
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                    setState(() {
                        _currentIndex = index;
                    });
                },
                type: BottomNavigationBarType.fixed,
                items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Timetable"),
                    BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Chats"),
                    BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Tasks"),
                    BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: "Notes"),
                ],
            ),
        );
    }
}