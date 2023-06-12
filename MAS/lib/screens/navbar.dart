import 'package:doctor/common/doctorCard.dart';
import 'package:doctor/model/Doctors.dart';
import 'package:doctor/screens/Dcard.dart';
import 'package:doctor/screens/appointment_page.dart';
import 'package:doctor/screens/homePage.dart';
import 'package:doctor/screens/invstigation_report.dart';
import 'package:doctor/screens/report_page.dart';
import 'package:flutter/material.dart';

import '../constant/colors.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final PageStorageBucket bucket = PageStorageBucket();
  TabController? tabController;
  List<Widget> pages = [
    const HomePage(),
    DoctorCardSecond(
      query: "",
    ),
    const ReportPage(),
  ];
  int currentIndex = 0;
  bool _canPop = false;

// On Tap Navigation Items
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Are you sure you want to exit?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: Text("Yes"),
              ),
            ],
          ),
        );
        return false;
      },
      child: Scaffold(
          body: pages[currentIndex],
          bottomNavigationBar: SafeArea(
            child: BottomNavigationBar(
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).primaryColor,
              currentIndex: currentIndex,
              selectedItemColor: white,
              unselectedItemColor: secondary,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                BottomNavigationBarItem(
                    label: "Home",
                    icon: Icon(
                      Icons.home,
                      color: white.withOpacity(0.4),
                    )),
                BottomNavigationBarItem(
                    label: "Schedule",
                    icon: Icon(
                      Icons.calendar_month,
                      color: white.withOpacity(0.4),
                    )),
                BottomNavigationBarItem(
                    label: "Report",
                    icon: Icon(
                      Icons.medical_information,
                      color: white.withOpacity(0.4),
                    )),
              ],
            ),
          )),
    );
  }
}

class NavBarIndicator extends Decoration {
  final Color color;
  double radius;
  NavBarIndicator({required this.color, required this.radius});
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final Color color;
  double radius;
  _CirclePainter({required this.color, required this.radius});
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Paint _paint = Paint();
    _paint.color = color;
    _paint.isAntiAlias = true;
    final Offset circleOffset = Offset(
        configuration.size!.width / 2 - radius / 2,
        configuration.size!.height - radius);
    canvas.drawCircle(offset + circleOffset, radius, _paint);
  }
}
