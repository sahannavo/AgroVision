import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/providers.dart';
import '../domain/diagnosis.dart';
import 'widgets/analysing_sheet.dart';
import 'widgets/capture_controls.dart';
import 'widgets/leaf_frame_overlay.dart';

// ---------------------------------------------------------------------------
// Internal state machine enum
// ---------------------------------------------------------------------------

/// The three mutually exclusive UI states of [CaptureScreen].
enum _CaptureState {
  /// Live camera preview is active.
  liveCam,

  /// A photo has been captured / picked and the classifier is running.
  analysing,

  /// Camera permission was denied or no camera hardware is available.
  permissionDenied,
}

// ---------------------------------------------------------------------------
// Screen widget
// ---------------------------------------------------------------------------

/// Full-screen camera capture and AI analysis entry point.
///
/// Responsibilities:
/// - Initialise and manage the [CameraController] lifecycle.
/// - Toggle flash modes via [CameraTopBar].
/// - Let the user pick a crop type via [CaptureControls].
/// - Take a photo (shutter) or pick from gallery.
/// - Run on-device AI classification ([diagnosisClassifierProvider]).
/// - Navigate to the result screen on success.
class CaptureScreen extends ConsumerStatefulWidget {
  final bool initialPermissionDeniedForTesting;

  const CaptureScreen({
    super.key,
    this.initialPermissionDeniedForTesting = false,
  });

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with WidgetsBindingObserver {
  // ── Camera state ──────────────────────────────────────────────────────────
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialising = false;

  // ── Screen state ──────────────────────────────────────────────────────────
  _CaptureState _screenState = _CaptureState.liveCam;

  // ── User selections ───────────────────────────────────────────────────────
  String _selectedCrop = 'Tomato';
  CameraFlashMode _flashMode = CameraFlashMode.off;

  // ── Analysing state ───────────────────────────────────────────────────────
  String? _capturePath;

  /// Guards against calling [setState] after the widget has been disposed
  /// while the async classifier is still in flight.
  bool _classifierRunning = false;

  // ── Image picker ──────────────────────────────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialPermissionDeniedForTesting) {
      _screenState = _CaptureState.permissionDenied;
    } else {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ── Camera initialisation ─────────────────────────────────────────────────

  Future<void> _initCamera() async {
    if (_isCameraInitialising) return;
    _isCameraInitialising = true;

    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _screenState = _CaptureState.permissionDenied;
            _isCameraInitialising = false;
          });
        }
        return;
      }

      final controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // Apply the current flash setting now that the camera is ready.
      await _applyFlash(controller, _flashMode);

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _screenState = _CaptureState.liveCam;
        _isCameraInitialising = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      final isDenied = e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted';

      setState(() {
        _screenState =
            isDenied ? _CaptureState.permissionDenied : _CaptureState.liveCam;
        _isCameraInitialising = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _screenState = _CaptureState.permissionDenied;
        _isCameraInitialising = false;
      });
    }
  }

  // ── Flash ─────────────────────────────────────────────────────────────────

  /// Maps our local [CameraFlashMode] enum to the camera package's [FlashMode].
  FlashMode _toPackageFlashMode(CameraFlashMode mode) {
    switch (mode) {
      case CameraFlashMode.off:
        return FlashMode.off;
      case CameraFlashMode.auto:
        return FlashMode.auto;
      case CameraFlashMode.always:
        return FlashMode.always;
      case CameraFlashMode.torch:
        return FlashMode.torch;
    }
  }

  Future<void> _applyFlash(
      CameraController controller, CameraFlashMode mode) async {
    try {
      await controller.setFlashMode(_toPackageFlashMode(mode));
    } on CameraException {
      // Flash may not be supported on this device — silently ignore.
    }
  }

  void _cycleFlash() {
    const cycle = [
      CameraFlashMode.off,
      CameraFlashMode.auto,
      CameraFlashMode.torch,
    ];
    final nextIndex = (cycle.indexOf(_flashMode) + 1) % cycle.length;
    final next = cycle[nextIndex];

    setState(() => _flashMode = next);

    if (_controller != null && _controller!.value.isInitialized) {
      _applyFlash(_controller!, next);
    }
  }

  // ── Capture & gallery ─────────────────────────────────────────────────────

  Future<void> _onShutter() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      final file = await controller.takePicture();
      _startAnalysis(file.path);
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not take photo: ${e.description}')),
      );
    }
  }

  Future<void> _onGallery() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;
      _startAnalysis(picked.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open gallery.')),
      );
    }
  }

  // ── Analysis ──────────────────────────────────────────────────────────────

  void _startAnalysis(String imagePath) {
    if (!mounted) return;
    setState(() {
      _capturePath = imagePath;
      _screenState = _CaptureState.analysing;
      _classifierRunning = true;
    });
    _runClassifier(imagePath);
  }

  Future<void> _runClassifier(String imagePath) async {
    Diagnosis? result;
    Object? error;

    try {
      result = await ref
          .read(diagnosisClassifierProvider)
          .classify(imagePath, cropType: _selectedCrop);
    } catch (e) {
      error = e;
    }

    // Guard: widget may have been disposed or the user cancelled.
    if (!mounted || !_classifierRunning) return;

    setState(() => _classifierRunning = false);

    if (error != null) {
      _returnToCamera();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnosis failed: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (result != null) {
      context.go('/diagnose/result', extra: result);
    }
  }

  void _cancelAnalysis() {
    if (!mounted) return;
    // Discard any in-flight result by flipping the guard flag.
    _classifierRunning = false;
    _returnToCamera();
  }

  void _returnToCamera() {
    setState(() {
      _screenState = _CaptureState.liveCam;
      _capturePath = null;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (_screenState) {
        _CaptureState.liveCam => _buildLiveCamView(),
        _CaptureState.analysing => _buildAnalysingView(),
        _CaptureState.permissionDenied => _buildPermissionDeniedView(),
      },
    );
  }

  // ── Live Camera View ──────────────────────────────────────────────────────

  Widget _buildLiveCamView() {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview or loading placeholder
        if (isReady)
          _buildCameraPreview(controller)
        else
          const _LoadingPlaceholder(),

        // Viewfinder overlay (brackets + hint)
        if (isReady) const LeafFrameOverlay(),

        // Top HUD (back + offline badge + flash)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CameraTopBar(
            flashMode: _flashMode,
            onBackPressed: () => context.pop(),
            onFlashPressed: _cycleFlash,
          ),
        ),

        // Bottom controls (crop chips + shutter + gallery + tips)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CaptureControls(
            selectedCrop: _selectedCrop,
            isCapturing: !isReady,
            onCropSelected: (crop) => setState(() => _selectedCrop = crop),
            onShutterPressed: isReady ? _onShutter : null,
            onGalleryPressed: _onGallery,
            onTipsPressed: () => showCaptureTipsModalSheet(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  // ── Analysing View ────────────────────────────────────────────────────────

  Widget _buildAnalysingView() {
    final path = _capturePath ?? '';
    return AnalysingView(
      imagePath: path,
      cropType: _selectedCrop,
      onCancel: _cancelAnalysis,
    );
  }

  // ── Permission Denied View ────────────────────────────────────────────────

  Widget _buildPermissionDeniedView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                size: 48,
                color: AppColors.lime,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Heading
            const Text(
              'Allow camera access to scan leaves',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Subtext
            Text(
              'Camera permission is needed for live leaf scanning. '
              'You can also pick a photo from your gallery instead.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Gallery fallback
            PrimaryButton(
              label: 'Choose from gallery',
              onPressed: _onGallery,
            ),

            const SizedBox(height: AppSpacing.md),

            // Try again (re-request permission)
            TextButton(
              onPressed: _initCamera,
              child: const Text(
                'Try again',
                style: TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widget
// ---------------------------------------------------------------------------

/// Shown while the [CameraController] is still initialising.
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.lime),
      ),
    );
  }
}

