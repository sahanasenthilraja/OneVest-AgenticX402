import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/app_lock_service.dart';
import 'services/security_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const OneVestApp());
}

class OneVestApp extends StatefulWidget {
  const OneVestApp({super.key});

  @override
  State<OneVestApp> createState() => _OneVestAppState();
}

class _OneVestAppState extends State<OneVestApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _lockShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLockTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppLockService.stop();

    super.dispose();
  }

  // ============================================================
  // START / RESET AUTO LOCK TIMER
  // ============================================================

  void _startLockTimer() {
    AppLockService.reset(
      onLocked: _showLockScreen,
    );
  }

  // ============================================================
  // APP BACKGROUND / FOREGROUND
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLockTimer();
    }
  }

  // ============================================================
  // SHOW LOCK SCREEN
  // ============================================================

  Future<void> _showLockScreen() async {
    if (_lockShowing) return;

    final hasPin = await SecurityService.hasPin();

    if (!hasPin) {
      _startLockTimer();
      return;
    }

    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      return;
    }

    _lockShowing = true;

    final pinController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: const Color(0xFF0E1830),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color(0xFF1E2C48),
                  ),
                ),

                title: const Column(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF14C8B0),
                      size: 40,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'ONEVEST LOCKED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                content: SizedBox(
                  width: 330,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Your session was locked after 5 minutes '
                        'of inactivity.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: pinController,
                        autofocus: true,
                        obscureText: true,
                        maxLength: 4,
                        keyboardType: TextInputType.number,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),

                        decoration: InputDecoration(
                          labelText: 'Transaction PIN',

                          labelStyle: const TextStyle(
                            color: Colors.white54,
                          ),

                          counterStyle: const TextStyle(
                            color: Colors.white38,
                          ),

                          errorText: errorText,

                          prefixIcon: const Icon(
                            Icons.pin_rounded,
                            color: Color(0xFF14C8B0),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),

                            borderSide: const BorderSide(
                              color: Color(0xFF1E2C48),
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),

                            borderSide: const BorderSide(
                              color: Color(0xFF14C8B0),
                            ),
                          ),

                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),

                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),

                          focusedErrorBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),

                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                actionsAlignment:
                    MainAxisAlignment.center,

                actions: [
                  SizedBox(
                    width: 180,

                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final pin =
                            pinController.text.trim();

                        final valid =
                            await SecurityService.verifyPin(
                          pin,
                        );

                        if (!dialogContext.mounted) {
                          return;
                        }

                        if (!valid) {
                          setDialogState(() {
                            errorText =
                                'Incorrect Transaction PIN';
                          });

                          pinController.clear();
                          return;
                        }

                        Navigator.of(dialogContext).pop();
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF14C8B0),

                        foregroundColor:
                            const Color(0xFF04140F),

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),

                      icon: const Icon(
                        Icons.lock_open_rounded,
                      ),

                      label: const Text(
                        'UNLOCK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    pinController.dispose();

    _lockShowing = false;

    _startLockTimer();
  }

  // ============================================================
  // APP
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,

      // Any click/tap resets the inactivity timer.
      onPointerDown: (_) {
        if (!_lockShowing) {
          _startLockTimer();
        }
      },

      child: MaterialApp(
        navigatorKey: navigatorKey,

        debugShowCheckedModeBanner: false,

        title: 'OneVest',

        theme: AppTheme.darkTheme,

        home: const SplashScreen(),
      ),
    );
  }
}