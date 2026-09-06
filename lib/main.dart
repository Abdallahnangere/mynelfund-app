import 'package:flutter/cupertino.dart';
import 'core/theme/nelfund_theme.dart';
import 'views/main_tab_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyNelfundApp());
}

class MyNelfundApp extends StatelessWidget {
  const MyNelfundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'My NELFund',
      debugShowCheckedModeBanner: false,
      theme: NelfundTheme.lightTheme,
      home: const MainTabScaffold(),
    );
  }
}
