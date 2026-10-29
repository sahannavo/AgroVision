// ignore_for_file: avoid_print

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/diagnosis/data/fake_diagnosis_classifier.dart';
import 'package:app/features/diagnosis/data/providers.dart';
import 'package:app/features/diagnosis/domain/diagnosis_classifier.dart';
import 'package:app/features/diagnosis/presentation/capture_screen.dart';
import 'package:app/features/diagnosis/presentation/widgets/capture_controls.dart';
import 'package:app/features/diagnosis/presentation/widgets/leaf_frame_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [CaptureScreen] in a [ProviderScope] with a fake classifier and a
/// [MaterialApp] using the production theme.
///
/// In a CI / headless environment the camera plugin returns no cameras, so
/// [CaptureScreen] transitions to [_CaptureState.permissionDenied] automatically
/// — which is the state we can test reliably without hardware.
Widget _buildScreen({DiagnosisClassifier? classifier}) {
  return ProviderScope(
    overrides: [
      diagnosisClassifierProvider.overrideWithValue(
        classifier ?? FakeDiagnosisClassifier(delay: Duration.zero),
      ),
    ],
    child: const MaterialApp(
      home: CaptureScreen(initialPermissionDeniedForTesting: true),
    ),
  );
}

/// Same as [_buildScreen] but wraps in [AppTheme.light].
Widget _buildScreenWithTheme({DiagnosisClassifier? classifier}) {
  return ProviderScope(
    overrides: [
      diagnosisClassifierProvider.overrideWithValue(
        classifier ?? FakeDiagnosisClassifier(delay: Duration.zero),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const CaptureScreen(initialPermissionDeniedForTesting: true),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CaptureScreen — no-camera environment (permission denied state)', () {
    // In a test environment, availableCameras() returns [], so the screen
    // transitions to permissionDenied immediately after initState.

    testWidgets(
      'shows "Allow camera access" heading when no camera is available',
      (tester) async {
        await tester.pumpWidget(_buildScreen());
        await tester.pump();

        expect(
          find.text('Allow camera access to scan leaves'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows "Choose from gallery" primary action button',
      (tester) async {
        await tester.pumpWidget(_buildScreen());
        await tester.pump();

        expect(find.text('Choose from gallery'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "Try again" secondary action button',
      (tester) async {
        await tester.pumpWidget(_buildScreen());
        await tester.pump();

        expect(find.text('Try again'), findsOneWidget);
      },
    );

    testWidgets(
      'renders with production theme without visual overflow',
      (tester) async {
        await tester.pumpWidget(_buildScreenWithTheme());
        await tester.pump();

        // No overflow exceptions should be thrown.
        expect(tester.takeException(), isNull);
        expect(find.text('Allow camera access to scan leaves'), findsOneWidget);
      },
    );

    testWidgets(
      '"Try again" button is tappable (re-triggers camera init)',
      (tester) async {
        await tester.pumpWidget(_buildScreen());
        await tester.pump();

        // Tap "Try again" — it calls _initCamera() which again returns no
        // cameras, so we stay on permission denied. Verify no exception thrown.
        await tester.tap(find.text('Try again'));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Allow camera access to scan leaves'), findsOneWidget);
      },
    );
  });

  // ── Widget unit tests for CaptureControls ─────────────────────────────────
  // These do not depend on camera hardware at all.
  group('CaptureControls widget', () {
    Widget buildControls({
      String selectedCrop = 'Tomato',
      ValueChanged<String>? onCropSelected,
    }) {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: CaptureControls(
            selectedCrop: selectedCrop,
            onCropSelected: onCropSelected ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders all four crop chips', (tester) async {
      await tester.pumpWidget(buildControls());
      for (final crop in kSupportedCrops) {
        expect(find.text(crop), findsOneWidget);
      }
    });

    testWidgets('initially selects Tomato chip', (tester) async {
      await tester.pumpWidget(buildControls(selectedCrop: 'Tomato'));
      await tester.pump();

      // The selected chip has bold text (FontWeight.bold) vs w500 for unselected.
      // Find the Text widget inside the Tomato chip and verify font weight.
      final tomatoText = tester.widget<Text>(find.text('Tomato'));
      expect(tomatoText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('calls onCropSelected when a chip is tapped', (tester) async {
      String? tappedCrop;
      await tester.pumpWidget(buildControls(
        onCropSelected: (crop) => tappedCrop = crop,
      ));

      await tester.tap(find.text('Potato'));
      await tester.pump();

      expect(tappedCrop, 'Potato');
    });

    testWidgets('Chilli chip is tappable and fires callback', (tester) async {
      String? tappedCrop;
      await tester.pumpWidget(buildControls(
        onCropSelected: (crop) => tappedCrop = crop,
      ));

      await tester.tap(find.text('Chilli'));
      await tester.pump();

      expect(tappedCrop, 'Chilli');
    });

    testWidgets('shutter button renders and respects isCapturing=false',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CaptureControls(
            selectedCrop: 'Tomato',
            onCropSelected: (_) {},
            onShutterPressed: () => tapped = true,
          ),
        ),
      ));

      // The shutter InkWell semantic label is "Take photo of leaf".
      await tester.tap(find.bySemanticsLabel('Take photo of leaf'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shutter button disabled when isCapturing=true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CaptureControls(
            selectedCrop: 'Tomato',
            onCropSelected: (_) {},
            onShutterPressed: () => tapped = true,
            isCapturing: true,
          ),
        ),
      ));

      await tester.tap(find.bySemanticsLabel('Take photo of leaf'));
      await tester.pump();

      // onShutterPressed is guarded by isCapturing — should not fire.
      expect(tapped, isFalse);
    });

    testWidgets('shows circular progress in shutter when isCapturing=true',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CaptureControls(
            selectedCrop: 'Tomato',
            onCropSelected: (_) {},
            isCapturing: true,
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Widget unit tests for LeafFrameOverlay ────────────────────────────────
  group('LeafFrameOverlay widget', () {
    testWidgets('renders without overflow at 390×844 (iPhone 14)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: LeafFrameOverlay(),
        ),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 360×640 (small phone)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: LeafFrameOverlay(),
        ),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders hint chip text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: LeafFrameOverlay(),
        ),
      ));

      expect(
        find.text('Place one leaf in the frame, in good light'),
        findsOneWidget,
      );
    });
  });

  // ── CameraTopBar tests ────────────────────────────────────────────────────
  group('CameraTopBar widget', () {
    testWidgets('back button triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraTopBar(
            flashMode: CameraFlashMode.off,
            onBackPressed: () => tapped = true,
          ),
        ),
      ));

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('flash toggle triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraTopBar(
            flashMode: CameraFlashMode.off,
            onFlashPressed: () => tapped = true,
          ),
        ),
      ));

      await tester.tap(find.bySemanticsLabel('Flash off, tap to change'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows flash_on icon when torch mode active', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraTopBar(
            flashMode: CameraFlashMode.torch,
            onFlashPressed: () {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
    });

    testWidgets('shows flash_off icon when off mode active', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraTopBar(
            flashMode: CameraFlashMode.off,
            onFlashPressed: () {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    });

    testWidgets('shows flash_auto icon when auto mode active', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraTopBar(
            flashMode: CameraFlashMode.auto,
            onFlashPressed: () {},
          ),
        ),
      ));

      expect(find.byIcon(Icons.flash_auto_rounded), findsOneWidget);
    });

    testWidgets('renders offline AI pill text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CameraTopBar(
            flashMode: CameraFlashMode.off,
          ),
        ),
      ));

      expect(find.text('AI runs on your phone'), findsOneWidget);
    });
  });
}
