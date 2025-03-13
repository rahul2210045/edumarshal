import 'package:edumarshals/Model/assignment_Model.dart';
import 'package:edumarshals/Model/student_attendance_data_model.dart';
import 'package:edumarshals/Screens/Attendance/OverAllAttendance.dart';
import 'package:edumarshals/Screens/Events/Events_Page.dart';
import 'package:edumarshals/Screens/Notes_Assignment/ClassNotesPage.dart';
import 'package:edumarshals/Screens/Notes_Assignment/Subject_Assignment.dart';
import 'package:edumarshals/Utils/Utilities/Utilities.dart';
import 'package:edumarshals/Widget/AttendanceCard.dart';
import 'package:edumarshals/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:edumarshals/repository/assignment_Repository.dart';
import 'package:edumarshals/repository/overall_attendance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../../Model/classnotes_Model.dart';
import '../../Utils/floating_action _button.dart';
import 'package:edumarshals/repository/classnotes_Repo.dart';
import '../../Widget/CommonDrawer.dart';
import '../../Widget/CustomAppBar.dart';
import 'homepage_utils.dart'; // Import the new file

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

final _key = GlobalKey<ExpandableFabState>();

class _HomepageState extends State<Homepage> {
  List<StudentAttendanceData>? _attendanceDataList;
  final GlobalKey<ScaffoldState> scaffoldKey_ = GlobalKey<ScaffoldState>();
  int selectedTileIndex = -1;
  final AssignmentRepository _assignmentRepository = AssignmentRepository();
  final ClassNotesRepository _classNotesRepository = ClassNotesRepository();
  final AttendanceRepository _repository = AttendanceRepository();

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  // Fetch attendance data from the repository
  Future<void> _fetchAttendanceData() async {
    List<StudentAttendanceData>? attendanceDataList =
        await _repository.fetchAttendance();
    int totalClasses = 0;
    int totalPresentClasses = 0;

    if (attendanceDataList != null) {
      for (var data in attendanceDataList) {
        totalClasses += data.totalClasses ?? 0;
        totalPresentClasses += data.totalPresent ?? 0;
      }
    }

    setState(() {
      _attendanceDataList = attendanceDataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheight = MediaQuery.of(context).size.height;
    final swidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: custom_floating_action_button(Gkey: _key),
      key: scaffoldKey_,
      backgroundColor: const Color(0xffEBF3FF),
      appBar: CustomAppBar(
        userName: PreferencesManager().name,
        userImage: PreferencesManager().studentPhoto,
        onTap: () {
          scaffoldKey_.currentState?.openDrawer();
        },
        scaffoldKey_: scaffoldKey_,
      ),
      drawer: CommonDrawer(
        scaffoldKey_: scaffoldKey_,
        currentIndex: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AttendanceCard(
                    title: "Overall Attendance",
                    description: "including all subjects\nand labs.",
                    attendedClasses: PreferencesManager().presentclasses,
                    totalClassess: PreferencesManager().totalclasses,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Subjects',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        child: Text(
                          'View All',
                          style: TextStyle(fontSize: 14, color: Color(0xff004BB8)),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventsPage()),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: sheight * 0.15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AttIndicator(0.809, '80.9%', 'COA'),
                          SizedBox(width: swidth * 0.04),
                          AttIndicator(0.705, '70.5%', 'DS'),
                          SizedBox(width: swidth * 0.04),
                          AttIndicator(0.75, '75%', 'PYTHON'),
                          SizedBox(width: swidth * 0.04),
                          AttIndicator(0.909, '90.9%', 'DSTL'),
                          SizedBox(width: swidth * 0.04),
                          AttIndicator(0.89, '89%', 'UHV'),
                          SizedBox(width: swidth * 0.04),
                          AttIndicator(0.65, '65%', 'COA LAB'),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<ClassNotes>?>(
                    future: _classNotesRepository.fetchClassNotes(),
                    builder: (context, snapshot) {
                      return handleClassNotesSnapshot(snapshot, context);
                    },
                  ),
                  FutureBuilder<List<Assignment>>(
                    future: _assignmentRepository.fetchAssignments(),
                    builder: (context, snapshot) {
                      return handleAssignmentsSnapshot(snapshot, context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}