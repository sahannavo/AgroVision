import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/outbreak_alert.dart';
import 'alert_card.dart';
import 'zone_bottom_sheet.dart';

/// Map view showing outbreak zones as circles plus the user's plot.
///
/// Uses flutter_map with OpenStreetMap tiles. When offline, shows
/// circles on a pale background with an offline banner.
class OutbreakMapView extends StatefulWidget {
  const OutbreakMapView({
    super.key,
    required this.alerts,
    required this.userPlot,
    required this.isOffline,
  });

  final List<OutbreakAlert> alerts;
  final UserPlotLocation userPlot;
  final bool isOffline;

  @override
  State<OutbreakMapView> createState() => _OutbreakMapViewState();
}

class _OutbreakMapViewState extends State<OutbreakMapView> {
  late final MapController _mapController;
  OutbreakAlert? _selectedAlert;

  LatLng get _center =>
      LatLng(widget.userPlot.latitude, widget.userPlot.longitude);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onZoneTapped(OutbreakAlert alert) =>
      setState(() => _selectedAlert = alert);

  void _dismiss() => setState(() => _selectedAlert = null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMap(),
        _buildLocationChip(),
        _buildZoomControls(),
        if (widget.isOffline) _buildOfflineBanner(),
        if (_selectedAlert != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ZoneBottomSheet(
              alert: _selectedAlert!,
              onViewPreventiveSteps: () {},
            ),
          ),
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 10.5,
        onTap: (_, __) => _dismiss(),
      ),
      children: [
        if (!widget.isOffline)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agrovision.app',
          ),
        if (widget.isOffline)
          const ColoredBox(
            color: Color(0xFFF5F5F0),
            child: SizedBox.expand(),
          ),
        // Zone circles
        CircleLayer(
          circles: widget.alerts
              .map((a) => CircleMarker(
                    point: LatLng(a.latitude, a.longitude),
                    radius: a.radiusKm * 1000,
                    useRadiusInMeter: true,
                    color: a.severity.color.withOpacity(0.15),
                    borderColor: a.severity.color.withOpacity(0.5),
                    borderStrokeWidth: 1.5,
                  ))
              .toList(),
        ),
        // User plot circle
        CircleLayer(circles: [
          CircleMarker(
            point: _center,
            radius: 2000,
            useRadiusInMeter: true,
            color: AppColors.mapUserMarker.withOpacity(0.12),
            borderColor: AppColors.mapUserMarker.withOpacity(0.4),
            borderStrokeWidth: 1.5,
          ),
        ]),
        // Markers
        MarkerLayer(markers: [
          _userMarker(),
          ...widget.alerts.map(_zoneLabel),
        ]),
      ],
    );
  }

  Marker _userMarker() {
    return Marker(
      point: _center,
      width: 180,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.mapUserMarker,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mapUserMarker.withOpacity(0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: AppRadius.fullAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'You (${widget.userPlot.plotName})',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _zoneLabel(OutbreakAlert alert) {
    return Marker(
      point: LatLng(alert.latitude, alert.longitude),
      width: 200,
      height: 40,
      child: GestureDetector(
        onTap: () => _onZoneTapped(alert),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.smAll,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: alert.severity.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${alert.diseaseName} (~${alert.distanceKm.toInt()}km)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overlays ────────────────────────────────────────────────────

  Widget _buildLocationChip() {
    final active = widget.alerts
        .where((a) => a.severity != AlertSeverity.peripheral)
        .length;
    return Positioned(
      top: AppSpacing.md,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.fullAll,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const _Dot(color: AppColors.highRisk, size: 10),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('Kurunegala · $active Active Risk Zones',
                  style: AppTextStyles.titleSmall),
            ),
            Semantics(
              label: 'Re-centre map',
              child: InkWell(
                onTap: () => _mapController.move(_center, 10.5),
                borderRadius: AppRadius.fullAll,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(Icons.my_location,
                      size: 18, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      right: AppSpacing.lg,
      bottom: _selectedAlert != null ? 320 : AppSpacing.xl,
      child: Column(
        children: [
          _ZoomBtn(
            icon: Icons.add,
            label: 'Zoom in',
            onTap: () => _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1),
          ),
          const SizedBox(height: 2),
          _ZoomBtn(
            icon: Icons.remove,
            label: 'Zoom out',
            onTap: () => _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        color: AppColors.offlineBanner.withOpacity(0.9),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Map tiles unavailable offline. '
                'Zones shown on plain background.',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: AppColors.surface,
        elevation: 2,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
