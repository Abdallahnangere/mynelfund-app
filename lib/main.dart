import 'package:flutter/cupertino.dart';
import 'core/theme/nelfund_theme.dart';
import 'views/main_tab_scaffold.dart';
import 'views/splash/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyNelfundApp());
}

class MyNelfundApp extends StatelessWidget {
  final bool skipSplash;

  const MyNelfundApp({
    super.key,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'My NELFund',
      debugShowCheckedModeBanner: false,
      theme: NelfundTheme.lightTheme,
      home: skipSplash ? const MainTabScaffold() : const SplashView(),
    );
  }
}
