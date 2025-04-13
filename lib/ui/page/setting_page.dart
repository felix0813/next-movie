import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/radio_dialog.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    super.key,
  });

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "Setting",
        showSetting: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TDButton(
              text: "Check movies",
              icon: TDIcons.scan,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CheckMovieRadioDialog(onConfirm: (_) {}, options: [
                        "Generate a report",
                        "Remove invalid movies"
                      ]);
                    });
              },
            )
          ],
        ),
      ),
    );
  }
}
