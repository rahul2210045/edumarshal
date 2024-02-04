import 'package:flutter/material.dart';

class Subject_Assignment_Card extends StatelessWidget {
  final String subjectName;
  final String status;
  final VoidCallback? onUploadPressed;
  final VoidCallback? onViewPressed;

  Subject_Assignment_Card({
    required this.subjectName,
    required this.status,
    this.onUploadPressed,
    this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(15.0),
          height: 100,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 75, 184, 1),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Image.asset("assets/assets/Frame 52.png")),
              // Icon(Icons.three_g_mobiledata),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
              Spacer(),
              TextButton(
                onPressed: onViewPressed,
                child: Text(
                  'View',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          // bottom: 1000,
          top: 90,
          right: 20,
          child: InkWell(
            onTap: onViewPressed,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              // height: 30,
              // width: 100,
              // color: const Color.fromARGB(255, 255, 255, 255),
              child: Center(
                child: Text(
                  'Upload solution',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 75, 184, 1),
                    fontWeight: FontWeight.w700,
                    fontSize: MediaQuery.of(context).size.width * 0.03,

                    // fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
