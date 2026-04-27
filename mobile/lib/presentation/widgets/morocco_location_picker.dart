import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';

/// Centre par défaut (الرباط) si pas de GPS.
const LatLng kDefaultMoroccoCenter = LatLng(33.9716, -6.8498);

/// Ouvre la carte + géocodage inverse, avec saisie manuelle.
Future<String?> showMoroccoLocationPicker(
  BuildContext context, {
  String? initialText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _LocationPickerSheet(initialText: initialText),
  );
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({this.initialText});

  final String? initialText;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final MapController _map = MapController();
  final TextEditingController _manual = TextEditingController();
  LatLng _center = kDefaultMoroccoCenter;
  bool _locatingSelf = false;
  bool _busyConfirm = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
      _manual.text = widget.initialText!.trim();
    }
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryMyLocation(silent: true));
    }
  }

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _tryMyLocation({bool silent = false}) async {
    if (!silent) setState(() => _locatingSelf = true);
    setState(() => _err = null);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        if (!silent && mounted) {
          setState(() => _err = S.mapPermissionDenied);
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _center = ll);
      _map.move(ll, 15);
    } catch (_) {
      if (!silent && mounted) setState(() => _err = S.mapGeoError);
    } finally {
      if (mounted) setState(() => _locatingSelf = false);
    }
  }

  Future<void> _confirmFromMap() async {
    setState(() {
      _busyConfirm = true;
      _err = null;
    });
    try {
      final list = await placemarkFromCoordinates(_center.latitude, _center.longitude);
      if (list.isEmpty) {
        if (mounted) Navigator.pop(context, _manual.text.trim());
        return;
      }
      final p = list.first;
      final parts = <String?>[
        p.subLocality,
        p.locality,
        p.administrativeArea,
        p.country,
      ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      var line = parts.join('، ');
      if (line.length < 3) {
        line = '${_center.latitude.toStringAsFixed(4)}, ${_center.longitude.toStringAsFixed(4)}';
      }
      if (mounted) {
        _manual.text = line;
        Navigator.pop(context, line);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _err = S.mapGeoError);
      }
    } finally {
      if (mounted) setState(() => _busyConfirm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.72;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: h,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      S.mapPickLocationTitle,
                      style: GoogleFonts.elMessiri(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.moroccoSlate,
                  ),
                ],
              ),
            ),
            if (_err != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_err!, style: GoogleFonts.cairo(color: AppColors.moroccoRed, fontSize: 13)),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? _webFallback()
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            FlutterMap(
                              mapController: _map,
                              options: MapOptions(
                                initialCenter: _center,
                                initialZoom: 13,
                                onPositionChanged: (camera, _) {
                                  setState(() => _center = camera.center);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'ma.alasel.mobile',
                                ),
                              ],
                            ),
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _CrosshairPainter(),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Text(
                S.mapManualBelow,
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.moroccoSlate),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _manual,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: S.fieldLocationHint,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.moroccoGreen, width: 2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _locatingSelf || _busyConfirm ? null : () => _tryMyLocation(silent: false),
                      icon: _locatingSelf
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, size: 20),
                      label: Text(S.mapUseMyPosition, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busyConfirm
                          ? null
                          : () async {
                              final t = _manual.text.trim();
                              if (t.length >= 2) {
                                Navigator.pop(context, t);
                              } else {
                                await _confirmFromMap();
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.moroccoGreen,
                        foregroundColor: AppColors.white,
                      ),
                      child: _busyConfirm
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(S.mapConfirmSelection, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webFallback() {
    return Container(
      color: AppColors.sandDeep,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        S.mapWebHint,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(color: AppColors.moroccoSlate, height: 1.45),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..color = AppColors.moroccoRed.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const arm = 14.0;
    canvas.drawLine(Offset(c.dx - arm, c.dy), Offset(c.dx + arm, c.dy), p);
    canvas.drawLine(Offset(c.dx, c.dy - arm), Offset(c.dx, c.dy + arm), p);
    canvas.drawCircle(c, 5, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Champ lieu : ouverture carte au tap / icône.
class MoroccoLocationTextField extends StatelessWidget {
  const MoroccoLocationTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;

  Future<void> _open(BuildContext context) async {
    final v = await showMoroccoLocationPicker(context, initialText: controller.text);
    if (v != null && v.trim().length >= 2) {
      controller.text = v.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _open(context),
      textCapitalization: TextCapitalization.sentences,
      style: GoogleFonts.cairo(color: AppColors.ink),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: GoogleFonts.cairo(color: AppColors.moroccoSlateLight),
        suffixIcon: IconButton(
          tooltip: S.mapOpenPickerHint,
          icon: const Icon(Icons.map_outlined, color: AppColors.moroccoGreen),
          onPressed: () => _open(context),
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.deepBlue.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.moroccoGreen, width: 2),
        ),
      ),
    );
  }
}
