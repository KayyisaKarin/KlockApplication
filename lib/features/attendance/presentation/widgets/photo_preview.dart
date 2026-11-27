import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({super.key, this.photo});

  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : const Color(0xFFDCDCE0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(dark)),
        boxShadow: AppColors.softShadow(dark),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: photo != null
            ? Image.memory(photo!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 40,
                    color: (dark ? AppColors.excused : AppColors.mutedInk)
                        .withValues(alpha: 0.75),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'photo preview',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: dark ? AppColors.excused : AppColors.mutedInk,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
