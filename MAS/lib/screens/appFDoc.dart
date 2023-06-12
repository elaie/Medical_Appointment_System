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

class AppointmentDirect extends StatefulWidget {
  String? doctorName;
  String? specialization;
  String? doctorId;
  String? nmcNo;
  String? selectedTime;

  AppointmentDirect({Key? key,
    this.doctorName,
    this.specialization,
    this.doctorId,
    this.nmcNo,
    this.selectedTime})
      : super(key: key);

  @override
  State<AppointmentDirect> createState() => _AppointmentDirectState();
}

class _AppointmentDirectState extends State<AppointmentDirect> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    _selectedDay = _focusedDay;
    dateTimeController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              UserInfoCard(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 6,
                name: widget.doctorName,
                profileIcon: false,
                specialization: "Please select the date for the appointment",
                nmcNo: "",
              ),
              CheckboxListTile(
                  title: Text('Urgent Appointment'),
                  value: isChecked,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isChecked = newValue ?? false;
                      cValue = isChecked ? 1 : 0;
                    });
                  }),
              const SizedBox(
                height: 40,
                child: Text("Select Your Date"),
              ),
              TableCalendar(
                rowHeight: 30,
                focusedDay: DateTime.now(),
                firstDay: DateTime(2010),
                lastDay: DateTime(2070),
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    Provider.of<TimeProvider?>(context, listen: false)!
                        .selectedDate(
                        DateFormat("yyyy-MM-dd").format(_selectedDay!));
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
                weekendDays: const [
                  DateTime.saturday
                ], // Disable According To Doctor's Availiability
              ),
              Text("${DateFormat("yyyy-MM-dd").format(_selectedDay!)}"),
              Container(
                margin: const EdgeInsets.all(10.0),
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.2,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: AppointmentTime(
                  doctorId: widget.doctorId,
                  dateSelected: context
                      .read<TimeProvider>()
                      .dateSelected,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Symptoms can't be empty";
                      }
                      return null;
                    },
                    controller: _symptomsController,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.info), //icon of text field
                        labelText: "Mention any symptoms" //label text of field
                    ),
                  ),
                ),
              ),
              Text("${context
                  .read<TimeProvider>()
                  .timeSelected}"),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () {
                      print("DATEajklshdljkashd= "+ date.toString());
                      final user = FirebaseAuth.instance.currentUser;
                      saveAppointmentDetails();

                      // saveAppointmentDetails();
                    },
                    child: const Text("Book Appointment")),
              )
            ],
          ),
        ),
      ),
    );
  }

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
    QuerySnapshot querySnapshot =
    await collectionRef.where('doctor', isEqualTo: widget.doctorName).get();

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
    try {
      String? date = "";
      String? field = "";
      final db = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      await db
          .collection("appointmentDetails")
          .where('userId', isEqualTo: user!.uid)
          .get()
          .then((value) {
        date = value.docs.first.data()['date'];
      });

      // compareStringWithKey();
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('appointmentDetails');

      // Query the collection with the condition
      QuerySnapshot querySnapshot =
      await collectionRef.where('doctor', isEqualTo: widget.doctorName).get();

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
    final user = FirebaseAuth.instance.currentUser;
    date = DateFormat("yyyy-MM-dd").format(_selectedDay!);
    final todayDate = DateFormat("yyy-MM-dd").format(DateTime.now());
    final time = context.read<TimeProvider?>()!.timeSelected;

    if (time.isEmpty) {
      AlertInfo(
          message: "Missed To Select Time.",
          backgroundColor: shrineErrorRed)
          .showInfo(context);
      return;
    }
    if (date!.isEmpty) {
      AlertInfo(
          message: "Missed To Select Date.",
          backgroundColor: shrineErrorRed)
          .showInfo(context);
      return;
    }
    if (_formKey.currentState!.validate()) {
      print("VALIDATE VAYO");
    }
    else {
      print("VALIDATE VAYENA");
      AlertInfo(
          message: "Symptoms field must not be empty",
          backgroundColor: shrineErrorRed)
          .showInfo(context);
      return;
    }
    if (!_selectedDay!.isBefore(DateTime.now())) {
      if (!_selectedDay!.isBefore(DateTime.now())) {
        try {
          await db
              .collection('appointmentDetails')
              .add({
            "userId": user!.uid,
            "date": date,
            "time": context
                .read<TimeProvider>()
                .timeSelected,
            "doctor": widget.doctorName,
            "doctorId": widget.doctorId,
            "symptoms": _symptomsController.text.trim(),
            "userName": user.displayName,
            "Urgent": cValue,
          })
              .then((value) =>
              AlertInfo(
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
      } else {
        AlertInfo(
            message: "Date Can't Be In Past", backgroundColor: shrineErrorRed)
            .showInfo(context);
      }
    }
  }
}
