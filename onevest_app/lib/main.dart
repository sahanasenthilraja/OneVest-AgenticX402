import 'package:firebase_auth/firebase_auth.dart';
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
      if (mounted) {
        _startLockTimer();
      }
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
    if (!mounted || _lockShowing) {
      return;
    }

    AppLockService.reset(
      onLocked: _showLockScreen,
    );
  }

  // ============================================================
  // APP BACKGROUND / FOREGROUND
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      if (!_lockShowing) {
        _startLockTimer();
      }
    }
  }

  // ============================================================
  // SHOW LOCK SCREEN
  // ============================================================

  Future<void> _showLockScreen() async {
    if (_lockShowing) {
      return;
    }

    // ----------------------------------------------------------
    // Get current Firebase user
    // ----------------------------------------------------------

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _startLockTimer();
      return;
    }

    final uid = user.uid;

    // ----------------------------------------------------------
    // Check whether this user has a PIN
    // ----------------------------------------------------------

    final hasPin = await SecurityService.hasPin(uid);

    if (!hasPin) {
      _startLockTimer();
      return;
    }

    // ----------------------------------------------------------
    // Get navigator context
    // ----------------------------------------------------------

    final context = navigatorKey.currentContext;

    if (context == null || !context.mounted) {
      return;
    }

    // ----------------------------------------------------------
    // Stop auto-lock while dialog is open
    // ----------------------------------------------------------

    _lockShowing = true;
    AppLockService.stop();

    final pinController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (dialogContext) {
          String? errorText;

          return StatefulBuilder(
            builder: (
              dialogContext,
              setDialogState,
            ) {
              // ==================================================
              // UNLOCK
              // ==================================================

              Future<void> unlock() async {
                final pin = pinController.text.trim();

                // ------------------------------------------------
                // Validate PIN
                // ------------------------------------------------

                if (pin.length != 4) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  setDialogState(() {
                    errorText = 'Enter your 4-digit PIN';
                  });

                  return;
                }

                // ------------------------------------------------
                // Verify PIN
                // ------------------------------------------------

                final valid =
                    await SecurityService.verifyPin(
                  uid,
                  pin,
                );

                if (!dialogContext.mounted) {
                  return;
                }

                // ------------------------------------------------
                // Incorrect PIN
                // ------------------------------------------------

                if (!valid) {
                  setDialogState(() {
                    errorText =
                        'Incorrect Transaction PIN';
                  });

                  pinController.clear();

                  return;
                }

                // ------------------------------------------------
                // Correct PIN
                //
                // First remove keyboard focus.
                // Then wait one frame before closing dialog.
                // ------------------------------------------------

                FocusScope.of(dialogContext).unfocus();

                await Future<void>.delayed(
                  const Duration(milliseconds: 100),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop();
              }

              return PopScope(
                canPop: false,
                child: AlertDialog(
                  backgroundColor:
                      const Color(0xFF0E1830),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF1E2C48),
                    ),
                  ),

                  // =================================================
                  // TITLE
                  // =================================================

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

                  // =================================================
                  // CONTENT
                  // =================================================

                  content: SizedBox(
                    width: 330,

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

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

                          keyboardType:
                              TextInputType.number,

                          textInputAction:
                              TextInputAction.done,

                          // IMPORTANT:
                          // No onSubmitted here.
                          //
                          // This prevents the keyboard submit event
                          // from closing the dialog while Flutter is
                          // still processing the text field/focus tree.

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),

                          decoration:
                              InputDecoration(
                            labelText:
                                'Transaction PIN',

                            labelStyle:
                                const TextStyle(
                              color: Colors.white54,
                            ),

                            counterStyle:
                                const TextStyle(
                              color: Colors.white38,
                            ),

                            errorText: errorText,

                            prefixIcon:
                                const Icon(
                              Icons.pin_rounded,
                              color:
                                  Color(0xFF14C8B0),
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Color(0xFF1E2C48),
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Color(0xFF14C8B0),
                              ),
                            ),

                            errorBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Colors.redAccent,
                              ),
                            ),

                            focusedErrorBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // BUTTON
                  // =================================================

                  actionsAlignment:
                      MainAxisAlignment.center,

                  actions: [
                    SizedBox(
                      width: 180,

                      child:
                          ElevatedButton.icon(
                        onPressed: unlock,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF14C8B0,
                          ),

                          foregroundColor:
                              const Color(
                            0xFF04140F,
                          ),

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 14,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),

                        icon: const Icon(
                          Icons.lock_open_rounded,
                        ),

                        label: const Text(
                          'UNLOCK',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
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
    } finally {
      // ----------------------------------------------------------
      // Dispose controller
      // ----------------------------------------------------------

      pinController.dispose();

      _lockShowing = false;

      // ----------------------------------------------------------
      // IMPORTANT:
      //
      // Wait until Flutter has completely removed the dialog
      // before restarting AppLockService.
      // ----------------------------------------------------------

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        if (_lockShowing) {
          return;
        }

        Future<void>.delayed(
          const Duration(milliseconds: 300),
          () {
            if (mounted && !_lockShowing) {
              _startLockTimer();
            }
          },
        );
      });
    }
  }

  // ============================================================
  // APP
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,

      // Reset inactivity timer on user interaction.
      //
      // Never restart timer while PIN dialog is visible.
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
