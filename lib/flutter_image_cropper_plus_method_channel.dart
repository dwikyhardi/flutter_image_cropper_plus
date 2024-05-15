import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_image_cropper_plus/flutter_image_cropper_plus_library.dart';
import 'package:flutter_image_cropper_plus/flutter_image_cropper_plus_platform_interface.dart';

/// An implementation of [FlutterImageCropperPlusPlatform] that uses method channels.
class MethodChannelFlutterImageCropperPlus
    extends FlutterImageCropperPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('id.my.dwiky/flutter_image_cropper_plus');

  @override
  Future<CroppedFile?> cropImage({
    required String sourcePath,
    int? maxWidth,
    int? maxHeight,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset> aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ],
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    List<PlatformUiSettings>? uiSettings,
  }) async {
    assert(await File(sourcePath).exists());
    assert(maxWidth == null || maxWidth > 0);
    assert(maxHeight == null || maxHeight > 0);
    assert(compressQuality >= 0 && compressQuality <= 100);

    final arguments = <String, dynamic>{
      'source_path': sourcePath,
      'max_width': maxWidth,
      'max_height': maxHeight,
      'ratio_x': aspectRatio?.ratioX,
      'ratio_y': aspectRatio?.ratioY,
      'aspect_ratio_presets':
          aspectRatioPresets.map<String>(aspectRatioPresetName).toList(),
      'crop_style': cropStyleName(cropStyle),
      'compress_format': compressFormatName(compressFormat),
      'compress_quality': compressQuality,
    };

    if (uiSettings != null) {
      for (final settings in uiSettings) {
        arguments.addAll(settings.toMap());
      }
    }

    final String? resultPath =
        await methodChannel.invokeMethod('cropImage', arguments);
    return resultPath == null ? null : CroppedFile(resultPath);
  }

  ///
  /// Retrieve cropped image lost due to activity termination (Android only).
  /// This method works similarly to [retrieveLostData] method from [image_picker]
  /// library. Unlike [retrieveLostData], does not throw an error on other platforms,
  /// but returns null result.
  ///
  /// [recoverImage] as (well as [retrieveLostData]) will return value on any
  /// call after a successful [cropImage], so you can potentially get unexpected
  /// result when using [ImageCropper] in different layout. Recommended usage comes down to
  /// this:
  ///
  /// ```dart
  /// void crop() async {
  ///   final cropper = ImageCropper();
  ///   final croppedFile = await cropper.cropImage(/* your parameters */);
  ///   // At this point we know that the main activity did survive and we can
  ///   // discard the cached value
  ///   await cropper.recoverImage();
  ///   // process croppedFile value
  /// }
  ///
  /// @override
  /// void initState() {
  ///   _getLostData();
  ///   super.initState();
  /// }
  ///
  /// void _getLostData() async {
  ///   final recoveredCroppedImage = await ImageCropper().recoverImage();
  ///   if (recoveredCroppedImage != null) {
  ///      // process recoveredCroppedImage value
  ///   }
  /// }
  /// ```
  ///
  /// **return:**
  ///
  /// A result file of the cropped image.
  ///
  /// See also:
  /// * [Android Activity Lifecycle](https://developer.android.com/reference/android/app/Activity.html)
  ///
  ///
  @override
  Future<CroppedFile?> recoverImage() async {
    if (!Platform.isAndroid) {
      return null;
    }
    final String? resultPath = await methodChannel.invokeMethod('recoverImage');
    return resultPath == null ? null : CroppedFile(resultPath);
  }
}
