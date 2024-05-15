import 'package:flutter_image_cropper_plus/flutter_image_cropper_plus_library.dart';
import 'package:flutter_image_cropper_plus/flutter_image_cropper_plus_platform_interface.dart';

class ImageCropperPlus {
  /// The method channel used to interact with the native platform.
  final FlutterImageCropperPlusPlatform _platform =
      FlutterImageCropperPlusPlatform.instance;

  /// Crops the image located at [sourcePath] and returns the cropped image as a [CroppedFile].
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
  }) {
    return _platform.cropImage(
      sourcePath: sourcePath,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      aspectRatio: aspectRatio,
      aspectRatioPresets: aspectRatioPresets,
      cropStyle: cropStyle,
      compressFormat: compressFormat,
      compressQuality: compressQuality,
      uiSettings: uiSettings,
    );
  }
}
