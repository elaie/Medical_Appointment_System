import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor/common/alert_info.dart';
import 'package:doctor/constant/colors.dart';
import 'package:doctor/widget/appointment_time.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../common/time_range.dart';
import '../common/user_info_card.dart';
import '../provider/TimeProvider.dart';
import 'selectDoctor.dart';
import '../screens/appointment_page.dart';
import 'docDetail.dart';

class selectDoctor extends StatefulWidget {
  final userId;
  final date;
  final time;
  final doctorName;
  final doctorId;
  final symptoms;
  final userName;
  final cValue;

  selectDoctor({
    Key? key,
    required this.userId,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.doctorId,
    required this.symptoms,
    required this.userName,
    required this.cValue,
  }) : super(key: key);

  @override
  State<selectDoctor> createState() => _selectDoctorState();
}

class _selectDoctorState extends State<selectDoctor> {
  DateTime _focusedDay = DateTime.now();
  bool isChecked = false;
  int cValue = 0;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 15);
  TextEditingController dateTimeController = TextEditingController();
  TextEditingController _symptomsController = TextEditingController();
  String? date;
  String? selectedTime;

  @override
  void initState() {
    print("date: ");
    _selectedDay = _focusedDay;
    dateTimeController.text = "";
    super.initState();
  }

  final db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Object?>>? stremQuery;

  @override
  Widget build(BuildContext context) {
    void _selectTime() async {
      final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: _time,
      );
      if (newTime != null) {
        setState(() {
          _time = newTime;
          dateTimeController.text = newTime.format(context);
        });
      }
    }

    Future<void> compareStringWithKey() async {
      // Access the Firestore collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('appointmentDetails');

      // Query the collection with the condition
      QuerySnapshot querySnapshot = await collectionRef
          .where('doctor', isEqualTo: widget.doctorName)
          .get();

      // Iterate over the documents that match the condition
      querySnapshot.docs.forEach((doc) {
        // Access the document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Access specific fields
        String field = data['doctor'];

        // Do something with the field value
        print('Field value: $field');
        print('Field value 2nd' + widget.doctorName.toString());
      });
    }

    Future<bool> getAppointmentDate() async {
      print("GET APPOINTEMENT DATE INMIT");
      try {
        String? date = "";
        String? field = "";
        final db = FirebaseFirestore.instance;
        final user = FirebaseAuth.instance.currentUser;
        await db
            .collection("appointmentDetails")
            .where('userId', isEqualTo: widget.userId)
            .get()
            .then((value) {
          date = value.docs.first.data()['date'];
        });

        // compareStringWithKey();
        CollectionReference collectionRef =
            FirebaseFirestore.instance.collection('appointmentDetails');

        // Query the collection with the condition
        QuerySnapshot querySnapshot = await collectionRef
            .where('doctor', isEqualTo: widget.doctorName)
            .get();

        // Iterate over the documents that match the condition
        querySnapshot.docs.forEach((doc) {
          // Access the document data
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          field = data['doctor'];
        });
        log("getAppointmentDate, $date");
        DateTime appointmentDate = DateTime.parse(date!);

        if ((appointmentDate.compareTo(DateTime.now()) <= 1) &&
            (field.toString() == widget.doctorName.toString())) {
          return true;
        }
      } catch (ex) {
        log(ex.toString());
      }
      return false;
    }

    void saveAppointmentDetails() async {
      final db = FirebaseFirestore.instance;
      if (widget.time.isEmpty) {
        AlertInfo(
                message: "Missed To Select Time.",
                backgroundColor: shrineErrorRed)
            .showInfo(context);
        return;
      }
      if (widget.date!.isEmpty) {
        AlertInfo(
                message: "Missed To Select Date.",
                backgroundColor: shrineErrorRed)
            .showInfo(context);
        return;
      }
      if (await getAppointmentDate()) {
        AlertInfo(
                message: "You have already a Booking.",
                backgroundColor: shrineErrorRed)
            .showInfo(context);
        Future.delayed(const Duration(seconds: 2))
            .then((value) => Navigator.pop(context));
        return;
      }
      try {
        print("TRYINGGGGG");
        await db
            .collection('appointmentDetails')
            .add({
              "userId": widget.userId,
              "date": widget.date,
              "time": widget.time,
              "doctor": widget.doctorName,
              "doctorId": widget.doctorId,
              "symptoms": widget.symptoms,
              "userName": widget.userName,
              "Urgent": widget.cValue
            })
            .then((value) => AlertInfo(
                    message: "Appointment Booked",
                    isSuccess: true,
                    backgroundColor: successAlert)
                .showInfo(context))
            .then((value) => Navigator.pop(context));
      } on FirebaseException catch (ex) {
        log(ex.toString());
        AlertInfo(
                message: "Some Error Occured", backgroundColor: shrineErrorRed)
            .showInfo(context);
      } catch (ex) {
        AlertInfo(
                message: "Some Error Occured", backgroundColor: shrineErrorRed)
            .showInfo(context);
      }
    }

    return Scaffold(
      appBar: AppBar (title: Text("Our Recommended Doctors Are "),),
      // appBar: widget.doctorName!
      //     ? AppBar(
      //   title: Text("${widget.doctorName}"),
      // )
      //     : widget.query!.isEmpty && !widget.search!
      //     ? AppBar(
      //   title: const Text("Available Doctors"),
      // )
      //     : null,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('doctor').snapshots(),
          builder: (context, snapshots) {
            return (snapshots.connectionState == ConnectionState.waiting)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshots.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshots.data!.docs[index].data()
                          as Map<String, dynamic>;
                      print("data printing");
                      print(data);
                      if(data['symptom'].contains(widget.symptoms.toString())){
                        return GestureDetector(
                            onTap: () {
                              //saveAppointmentDetails();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DoctorDetails(
                                          data['uid'].toString(),
                                          widget.userId,
                                          widget.date,
                                          widget.time,
                                          widget.doctorName,
                                          widget.doctorId,
                                          widget.symptoms,
                                          widget.userName,
                                          cValue,
                                        )),
                              );
                              print("TAPPED HERE " + data['name']);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 10),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    SizedBox(
                                      height: 200,
                                      width: 320,
                                      child: Card(
                                        child: ListTile(
                                          leading: Image.network(
                                            "https://royalphnompenhhospital.com/royalpp/storage/app/uploads/2/2022-06-30/dr_sarisak_01.jpg",
                                            fit: BoxFit.fitHeight,
                                          ),
                                          title: Text("Dr. ${data['name']}"),
                                          subtitle: Text(
                                              "${data['specialization']} / ${data['qualification']}"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      }
                      else {
                        return Container();
                      }
                    });
          },
        ),
      ),
    );
  }
}
