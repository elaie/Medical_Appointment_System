import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/appointment_page.dart';
import 'appFDoc.dart';
class DoctorCardSecond extends StatefulWidget {
  bool? doctorByCategory;
  String? specialization;
  bool? search;
  String? query = "";
  DoctorCardSecond(
      {Key? key,
        this.doctorByCategory = false,
        this.specialization,
        this.search = false,
        this.query})
      : super(key: key);

  @override
  State<DoctorCardSecond> createState() => _DoctorCardSecondState();
}

class _DoctorCardSecondState extends State<DoctorCardSecond> {
  final db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Object?>>? stremQuery;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.query = "";
    stremQuery = db.collection('doctor').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      log("Up Here, ${widget.query}");
      if (widget.doctorByCategory!) {
        stremQuery = db
            .collection('doctor')
            .where('specialization', isEqualTo: widget.specialization)
            .snapshots();
      } else if (widget.query!.isNotEmpty) {
        stremQuery = db
            .collection('doctor')
            .where('name', isGreaterThanOrEqualTo: widget.query)
            .where('name', isLessThanOrEqualTo: widget.query! + '\uf8ff')
            .snapshots();
        log("Search True");
      } else {
        stremQuery = db.collection('doctor').snapshots();
      }
    });
    return Scaffold(
      appBar: widget.doctorByCategory!
          ? AppBar(
        title: Text("${widget.specialization}"),
      )
          : widget.query!.isEmpty && !widget.search!
          ? AppBar(
        title: const Text("Available Doctors"),
      )
          : null,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: stremQuery,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: snapshot.data!.docs.map(
                        (doc) {
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDirect(
                                doctorId: doc.id,
                                doctorName: "Dr." + doc['name'],
                                specialization:
                                "${doc['specialization']} / ${doc['qualification']}",
                                nmcNo: doc['nmcNo']),
                          ),
                        ),
                        child: Card(
                          child: ListTile(
                            leading: Image.network(
                              "https://royalphnompenhhospital.com/royalpp/storage/app/uploads/2/2022-06-30/dr_sarisak_01.jpg",
                              fit: BoxFit.fitHeight,
                            ),
                            title: Text("Dr. ${doc['name']}"),
                            subtitle: Text(
                                "${doc['specialization']} / ${doc['qualification']}"),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}
