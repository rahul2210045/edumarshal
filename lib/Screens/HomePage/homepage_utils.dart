import 'package:edumarshals/Utils/Utilities/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:edumarshals/Model/assignment_Model.dart';
import 'package:edumarshals/Model/classnotes_Model.dart';
import 'package:edumarshals/Screens/Notes_Assignment/ClassNotesPage.dart';
import 'package:edumarshals/Screens/Notes_Assignment/Subject_Assignment.dart';

// Handle Class Notes Snapshot
Widget handleClassNotesSnapshot(
    AsyncSnapshot<List<ClassNotes>?> snapshot, BuildContext context) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  } else if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return const SizedBox.shrink();
  } else {
    final List<ClassNotes> recentClassNotes = snapshot.data!.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Class Notes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassNotesPage()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(fontSize: 14, color: Color(0xff004BB8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var classNote in recentClassNotes)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClassNotesPage()),
              );
            },
            child: notes(
              classNote.subject?.name ?? '',
              'Semester-3',
              classNote.teacher?.name ?? '',
            ),
          ),
      ],
    );
  }
}

// Handle Assignments Snapshot
Widget handleAssignmentsSnapshot(
    AsyncSnapshot<List<Assignment>> snapshot, BuildContext context) {
  if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return const SizedBox.shrink();
  } else {
    final Map<String, List<Assignment>> groupedAssignments =
        groupAssignmentsBySubject(snapshot.data!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assignments',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              child: Text(
                'View All',
                style: TextStyle(fontSize: 14, color: Color(0xff004BB8)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Subject_Assignment()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (String subject in groupedAssignments.keys)
          AssignmentCard(
            subjectName: subject,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Subject_Assignment()),
              );
            },
            assignments: groupedAssignments[subject]!,
            description: groupedAssignments[subject]!.first.description ?? '',
            deadline: groupedAssignments[subject]!.first.deadline ?? '',
            teacherName: groupedAssignments[subject]!.first.teacher?.name ?? '',
          ),
      ],
    );
  }
}

// Group Assignments by Subject
Map<String, List<Assignment>> groupAssignmentsBySubject(
    List<Assignment> assignments) {
  final Map<String, List<Assignment>> groupedAssignments = {};

  for (Assignment assignment in assignments) {
    final String subjectName = assignment.subject?.name ?? 'Unknown';

    if (!groupedAssignments.containsKey(subjectName)) {
      groupedAssignments[subjectName] = [];
    }

    groupedAssignments[subjectName]!.add(assignment);
  }

  return groupedAssignments;
}

// AssignmentCard Widget
class AssignmentCard extends StatelessWidget {
  final String subjectName;
  final String description;
  final String deadline;
  final String teacherName;
  final VoidCallback onTap;
  final List<Assignment> assignments;

  const AssignmentCard({
    required this.subjectName,
    required this.description,
    required this.deadline,
    required this.teacherName,
    required this.onTap,
    required this.assignments,
  });

  @override
  Widget build(BuildContext context) {
    final sheight = MediaQuery.of(context).size.height;
    final swidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xff004BB8),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subjectName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Image.asset(
                      'assets/arrow-up.png',
                      scale: 4,
                    ),
                  ],
                ),
                SizedBox(height: sheight * 0.01),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/Frame 50.png',
                      scale: 4,
                    ),
                    SizedBox(width: swidth * 0.03),
                    Text(
                      teacherName,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}