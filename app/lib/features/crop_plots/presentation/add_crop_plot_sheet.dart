import 'package:flutter/material.dart';

/// Stub for showing the Add Crop Plot bottom sheet.
/// Built by another team member.
Future<void> showAddCropPlotSheet(BuildContext context, {dynamic plot}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      child: const Text('Add Crop Plot Sheet Stub'),
    ),
  );
}
