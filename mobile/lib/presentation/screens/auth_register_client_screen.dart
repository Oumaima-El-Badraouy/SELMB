import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/l10n/strings.dart';
import '../../core/network/dio_error_message.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/form_spacing.dart';
import '../widgets/cinematic_moroccan_background.dart';
import '../widgets/gradient_primary_button.dart';
import '../widgets/moroccan_card.dart';
import '../widgets/moroccan_ui_kit.dart';

class AuthRegisterClientScreen extends ConsumerStatefulWidget {
  const AuthRegisterClientScreen({super.key});

  @override
  ConsumerState<AuthRegisterClientScreen> createState() => _AuthRegisterClientScreenState();
}

class _AuthRegisterClientScreenState extends ConsumerState<AuthRegisterClientScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  bool mediouna = false;
  bool loading = false;
  String? _photoDataUrl;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 720,
      imageQuality: 82,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoDataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _submit() async {
    if (loading) return;
    if (!mediouna) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(S.errMediounaRequired)),
      );
      return;
    }
    final fn = _first.text.trim();
    final ln = _last.text.trim();
    final tel = _phone.text.trim();
    if (fn.isEmpty || ln.isEmpty || tel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(S.errClientRequiredFields)),
      );
      return;
    }
    final loc = _location.text.trim();
    if (loc.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(S.errLocationRequired)),
      );
      return;
    }
    setState(() => loading = true);
    try {
      await ref.read(authNotifierProvider.notifier).registerClient(
            firstName: fn,
            lastName: ln,
            phone: tel,
            email: _email.text.trim(),
            password: _password.text,
            location: loc,
            isMediounaVerified: true,
            photoUrl: _photoDataUrl,
          );
      if (mounted) context.go('/client');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyDioError(e))));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => AppGradients.titleArabic.createShader(Offset.zero & b.size),
          child: Text(
            S.registerClientTitle,
            style: GoogleFonts.elMessiri(fontWeight: FontWeight.w800, fontSize: 21, color: Colors.white),
          ),
        ),
      ),
      body: CinematicMoroccanBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.white.withValues(alpha: 0.9),
                    backgroundImage: _photoDataUrl != null ? MemoryImage(base64Decode(_photoDataUrl!.split(',').last)) : null,
                    child: _photoDataUrl == null
                        ? const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.deepBlue)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: MoroccanGoldBand(width: 100)),
              const SizedBox(height: 8),
              Text(
                S.profilePhotoOptional,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.white.withValues(alpha: 0.88)),
              ),
              const SizedBox(height: 16),
              MoroccanCard(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _first,
                      decoration: InputDecoration(
                        labelText: '${S.fieldFirstName} *',
                      ),
                    ),
                    FormSpacing.betweenInputs,
                    TextField(
                      controller: _last,
                      decoration: InputDecoration(
                        labelText: '${S.fieldLastName} *',
                      ),
                    ),
                    FormSpacing.betweenInputs,
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: S.emailLabel),
                    ),
                    FormSpacing.betweenInputs,
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: S.fieldPasswordMin),
                    ),
                    FormSpacing.betweenInputs,
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '${S.fieldPhoneRequired} *',
                        hintText: '+212600000000',
                      ),
                    ),
                    FormSpacing.betweenInputs,
                    TextField(
                      controller: _location,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: S.fieldLocationRequired,
                        hintText: S.fieldLocationHint,
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: mediouna,
                      onChanged: (v) => setState(() => mediouna = v ?? false),
                      title: Text(S.mediounaConfirmLabel, style: GoogleFonts.cairo(fontSize: 14)),
                      activeColor: AppColors.deepBlue,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),
                    GradientPrimaryButton(
                      onPressed: _submit,
                      loading: loading,
                      label: S.registerSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
