import 'package:flutter/material.dart';
import 'tab_home.dart';
import 'tab_timetable.dart';
import 'tab_chats.dart';
import 'tab_tasks.dart';
import 'tab_notes.dart';

// Main "AppShell" widget that holds the bottom navigation and tabs
class AppShell extends StatefulWidget {
    const AppShell({super.key});

    @override
    State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
    // Keeps track of which tab is currently selected in the bottom navigation bar
    int _currentIndex = 0;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            // Top app bar with the title "TaskHub"
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

            // The main content switches between different tabs
            body: IndexedStack(
                index: _currentIndex, // which child to show
                children: const [
                    TabHome(), // Home screen
                    TabTimetable(), // Timetable
                    TabChats(), // Group chats
                    TabTasks(), // Tasks/To-do list
                    TabNotes(), // Notes
                ],
            ),

            // Bottom navigation bar for switching between the 5 main tabs
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex, // highlights current tab
                onTap: (index) {
                    // Update the selected tab when user taps a button
                    setState(() {
                        _currentIndex = index;
                    });
                },
                type: BottomNavigationBarType.fixed, // shows all icons at once
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