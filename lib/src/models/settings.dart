import 'package:flutter/material.dart';

import 'package:flutter_image_cropper_plus/src/utils.dart';

///
/// A set of preset values can be used to setup the menu of crop aspect ratio
/// options in the cropper view.
///
enum CropAspectRatioPreset {
  original,
  square,
  ratio3x2,
  ratio5x3,
  ratio4x3,
  ratio5x4,
  ratio7x5,
  ratio16x9
}

///
/// Crop style options. There're two supported styles, rectangle and circle.
/// These style will changes the shape of crop bounds, rectangle or circle bounds.
///
enum CropStyle { rectangle, circle }

///
/// Supported image compression formats
///
enum ImageCompressFormat { jpg, png }

class CropAspectRatio {
  const CropAspectRatio({required this.ratioX, required this.ratioY})
      : assert(ratioX > 0.0 && ratioY > 0.0);
  final double ratioX;
  final double ratioY;

  @override
  int get hashCode => ratioX.hashCode ^ ratioY.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is CropAspectRatio &&
          ratioX == other.ratioX &&
          ratioY == other.ratioY;
}

///
/// An abstract class encapsulates UI attributes for customization
///
abstract class PlatformUiSettings {
  Map<String, dynamic> toMap();
}

String aspectRatioPresetName(CropAspectRatioPreset? preset) {
  switch (preset) {
    case CropAspectRatioPreset.original:
      return 'original';
    case CropAspectRatioPreset.square:
      return 'square';
    case CropAspectRatioPreset.ratio3x2:
      return '3x2';
    case CropAspectRatioPreset.ratio4x3:
      return '4x3';
    case CropAspectRatioPreset.ratio5x3:
      return '5x3';
    case CropAspectRatioPreset.ratio5x4:
      return '5x4';
    case CropAspectRatioPreset.ratio7x5:
      return '7x5';
    case CropAspectRatioPreset.ratio16x9:
      return '16x9';
    default:
      return 'original';
  }
}

String cropStyleName(CropStyle style) {
  switch (style) {
    case CropStyle.rectangle:
      return 'rectangle';
    case CropStyle.circle:
      return 'circle';
    default:
      return 'rectangle';
  }
}

String compressFormatName(ImageCompressFormat format) {
  switch (format) {
    case ImageCompressFormat.jpg:
      return 'jpg';
    case ImageCompressFormat.png:
      return 'png';
    default:
      return 'jpg';
  }
}

///
/// A helper class provides properties that can be used to customize the cropper
/// view on Android.
///
/// The properties is mapped to fields of `Ucrop.Options` class in Ucrop library.
///
/// See: <https://github.com/Yalantis/uCrop/blob/master/ucrop/src/main/java/com/yalantis/ucrop/UCrop.java#L260>
///
class AndroidUiSettings extends PlatformUiSettings {
  AndroidUiSettings({
    this.toolbarTitle,
    this.toolbarColor,
    this.statusBarColor,
    this.toolbarWidgetColor,
    this.backgroundColor,
    this.activeControlsWidgetColor,
    this.dimmedLayerColor,
    this.cropFrameColor,
    this.cropGridColor,
    this.cropFrameStrokeWidth,
    this.cropGridRowCount,
    this.cropGridColumnCount,
    this.cropGridStrokeWidth,
    this.showCropGrid,
    this.lockAspectRatio,
    this.hideBottomControls,
    this.initAspectRatio,
  });

  /// desired text for Toolbar title
  final String? toolbarTitle;

  /// desired color of the Toolbar
  final Color? toolbarColor;

  /// desired color of status
  final Color? statusBarColor;

  /// desired color of Toolbar text and buttons (default is black)
  final Color? toolbarWidgetColor;

  /// desired background color that should be applied to the root view
  final Color? backgroundColor;

  /// desired resolved color of the active and selected widget and progress wheel middle line (default is darker orange)
  final Color? activeControlsWidgetColor;

  /// desired color of dimmed area around the crop bounds
  final Color? dimmedLayerColor;

  /// desired color of crop frame
  final Color? cropFrameColor;

  /// desired color of crop grid/guidelines
  final Color? cropGridColor;

  /// desired width of crop frame line in pixels
  final int? cropFrameStrokeWidth;

  /// crop grid rows count
  final int? cropGridRowCount;

  /// crop grid columns count
  final int? cropGridColumnCount;

  /// desired width of crop grid lines in pixels
  final int? cropGridStrokeWidth;

  /// set to true if you want to see a crop grid/guidelines on top of an image
  final bool? showCropGrid;

  /// set to true if you want to lock the aspect ratio of crop bounds with a fixed value
  /// (locked by default)
  final bool? lockAspectRatio;

  /// set to true to hide the bottom controls (shown by default)
  final bool? hideBottomControls;

  /// desired aspect ratio is applied (from the list of given aspect ratio presets)
  /// when starting the cropper
  final CropAspectRatioPreset? initAspectRatio;

  @override
  Map<String, dynamic> toMap() => {
        'android.toolbar_title': toolbarTitle,
        'android.toolbar_color': int32(toolbarColor?.value),
        'android.statusbar_color': int32(statusBarColor?.value),
        'android.toolbar_widget_color': int32(toolbarWidgetColor?.value),
        'android.background_color': int32(backgroundColor?.value),
        'android.active_controls_widget_color':
            int32(activeControlsWidgetColor?.value),
        'android.dimmed_layer_color': int32(dimmedLayerColor?.value),
        'android.crop_frame_color': int32(cropFrameColor?.value),
        'android.crop_grid_color': int32(cropGridColor?.value),
        'android.crop_frame_stroke_width': cropFrameStrokeWidth,
        'android.crop_grid_row_count': cropGridRowCount,
        'android.crop_grid_column_count': cropGridColumnCount,
        'android.crop_grid_stroke_width': cropGridStrokeWidth,
        'android.show_crop_grid': showCropGrid,
        'android.lock_aspect_ratio': lockAspectRatio,
        'android.hide_bottom_controls': hideBottomControls,
        'android.init_aspect_ratio': aspectRatioPresetName(initAspectRatio),
      };
}

///
/// A helper class provides properties that can be used to customize the cropper
/// view on iOS.
///
/// The properties is mapped to properties of `TOCropViewController` class in
/// TOCropViewController library.
///
/// See: <https://github.com/TimOliver/TOCropViewController/blob/master/Objective-C/TOCropViewController/TOCropViewController.h>
///
class IOSUiSettings extends PlatformUiSettings {
  IOSUiSettings({
    this.minimumAspectRatio,
    this.rectX,
    this.rectY,
    this.rectWidth,
    this.rectHeight,
    this.showActivitySheetOnDone,
    this.showCancelConfirmationDialog = false,
    this.rotateClockwiseButtonHidden = false,
    this.hidesNavigationBar,
    this.rotateButtonsHidden = false,
    this.resetButtonHidden = false,
    this.aspectRatioPickerButtonHidden = false,
    this.resetAspectRatioEnabled = true,
    this.aspectRatioLockDimensionSwapEnabled = false,
    this.aspectRatioLockEnabled = false,
    this.title,
    this.doneButtonTitle,
    this.cancelButtonTitle,
  });

  /// The minimum croping aspect ratio. If set, user is prevented from setting
  /// cropping rectangle to lower aspect ratio than defined by the parameter.
  final double? minimumAspectRatio;

  /// The initial rect of cropping.
  final double? rectX;
  final double? rectY;
  final double? rectWidth;
  final double? rectHeight;

  /// If true, when the user hits 'Done', a UIActivityController will appear
  /// before the view controller ends.
  final bool? showActivitySheetOnDone;

  /// Shows a confirmation dialog when the user hits 'Cancel' and there are pending changes.
  /// (default is false)
  final bool showCancelConfirmationDialog;

  /// When disabled, an additional rotation button that rotates the canvas in
  /// 90-degree segments in a clockwise direction is shown in the toolbar.
  /// (default is false)
  final bool rotateClockwiseButtonHidden;

  /// If this controller is embedded in UINavigationController its navigation bar
  /// is hidden by default. Set this property to false to show the navigation bar.
  /// This must be set before this controller is presented.
  final bool? hidesNavigationBar;

  /// When enabled, hides the rotation button, as well as the alternative rotation
  /// button visible when `showClockwiseRotationButton` is set to YES.
  /// (default is false)
  final bool rotateButtonsHidden;

  /// When enabled, hides the 'Reset' button on the toolbar.
  /// (default is false)
  final bool resetButtonHidden;

  /// When enabled, hides the 'Aspect Ratio Picker' button on the toolbar.
  /// (default is false)
  final bool aspectRatioPickerButtonHidden;

  /// If true, tapping the reset button will also reset the aspect ratio back to the image
  /// default ratio. Otherwise, the reset will just zoom out to the current aspect ratio.
  ///
  /// If this is set to false, and `aspectRatioLockEnabled` is set to true, then the aspect ratio
  /// button will automatically be hidden from the toolbar.
  ///
  /// (default is true)
  final bool resetAspectRatioEnabled;

  /// If true, a custom aspect ratio is set, and the aspectRatioLockEnabled is set to true, the crop box
  /// will swap it's dimensions depending on portrait or landscape sized images.
  /// This value also controls whether the dimensions can swap when the image is rotated.
  ///
  /// (default is false)
  final bool aspectRatioLockDimensionSwapEnabled;

  /// If true, while it can still be resized, the crop box will be locked to its current aspect ratio.
  ///
  /// If this is set to true, and `resetAspectRatioEnabled` is set to false, then the aspect ratio
  /// button will automatically be hidden from the toolbar.
  ///
  /// (default is false)
  final bool aspectRatioLockEnabled;

  /// Title text that appears at the top of the view controller.
  final String? title;

  /// Title for the 'Done' button.
  /// Setting this will override the Default which is a localized string for "Done".
  final String? doneButtonTitle;

  /// Title for the 'Cancel' button.
  /// Setting this will override the Default which is a localized string for "Cancel".
  final String? cancelButtonTitle;

  @override
  Map<String, dynamic> toMap() => {
        'ios.minimum_aspect_ratio': minimumAspectRatio,
        'ios.rect_x': rectX,
        'ios.rect_y': rectY,
        'ios.rect_width': rectWidth,
        'ios.rect_height': rectHeight,
        'ios.show_activity_sheet_on_done': showActivitySheetOnDone,
        'ios.show_cancel_confirmation_dialog': showCancelConfirmationDialog,
        'ios.rotate_clockwise_button_hidden': rotateClockwiseButtonHidden,
        'ios.hides_navigation_bar': hidesNavigationBar,
        'ios.rotate_button_hidden': rotateButtonsHidden,
        'ios.reset_button_hidden': resetButtonHidden,
        'ios.aspect_ratio_picker_button_hidden': aspectRatioPickerButtonHidden,
        'ios.reset_aspect_ratio_enabled': resetAspectRatioEnabled,
        'ios.aspect_ratio_lock_dimension_swap_enabled':
            aspectRatioLockDimensionSwapEnabled,
        'ios.aspect_ratio_lock_enabled': aspectRatioLockEnabled,
        'ios.title': title,
        'ios.done_button_title': doneButtonTitle,
        'ios.cancel_button_title': cancelButtonTitle,
      };
}

typedef CropperDialogBuilder = Dialog Function(
  Widget cropper,
  Future<String?> Function() crop,
  void Function(RotationAngle) rotate,
);

typedef CropperRouteBuilder = PageRoute<String> Function(
  Widget cropper,
  Future<String?> Function() crop,
  void Function(RotationAngle) rotate,
);

enum CropperPresentStyle { dialog, page }

class CroppieBoundary {
  const CroppieBoundary({
    this.width,
    this.height,
  });

  final int? width;
  final int? height;
}

class CroppieViewPort {
  const CroppieViewPort({
    this.width,
    this.height,
    this.type,
  });

  final int? width;
  final int? height;
  final String? type;
}

class WebUiSettings extends PlatformUiSettings {
  WebUiSettings({
    required this.context,
    this.presentStyle = CropperPresentStyle.dialog,
    this.customDialogBuilder,
    this.customRouteBuilder,
    this.boundary,
    this.viewPort,
    this.customClass,
    this.enableExif,
    this.enableOrientation,
    this.enableZoom,
    this.enableResize,
    this.enforceBoundary,
    this.mouseWheelZoom,
    this.showZoomer,
    this.barrierColor,
    this.translations,
  });

  /// The outer container of the cropper
  /// Default = { width: 500, height: 500 }
  final CroppieBoundary? boundary;

  /// The inner container of the coppie. The visible part of the image.
  /// Default = { width: 400, height: 400, type: 'square' }
  /// Valid type values:'square' 'circle'
  final CroppieViewPort? viewPort;

  /// A class of your choosing to add to the container to add custom styles to your croppie
  /// Default = ''
  final String? customClass;

  /// Enable exif orientation reading. Tells Croppie to read exif orientation from the image data and orient the image correctly before
  /// rendering to the page.
  /// Requires exif.js (packages/croppie_dart/lib/src/exif.js)
  final bool? enableExif;

  /// Enable or disable support for specifying a custom orientation when binding images
  /// Default = true
  final bool? enableOrientation;

  /// Enable zooming functionality. If set to false - scrolling and pinching would not zoom.
  /// Default = false
  final bool? enableZoom;

  /// Enable or disable support for resizing the viewport area.
  /// Default = false
  final bool? enableResize;

  /// Restricts zoom so image cannot be smaller than viewport.
  /// Experimental
  /// Default = true
  final bool? enforceBoundary;

  /// Enable or disable the ability to use the mouse wheel to zoom in and out on a croppie instance
  /// Default = true
  final bool? mouseWheelZoom;

  /// Hide or Show the zoom slider.
  /// Default = true
  final bool? showZoomer;

  /// Presentation style of cropper, either a dialog or a page (route)
  /// Default = dialog
  final CropperPresentStyle presentStyle;

  /// Current BuildContext
  /// The context is required to show cropper dialog or route
  final BuildContext context;

  /// Builder to customize the cropper [Dialog]
  final CropperDialogBuilder? customDialogBuilder;

  /// Builder to customize the cropper [PageRoute]
  final CropperRouteBuilder? customRouteBuilder;

  /// Barrier color for displayed [Dialog]
  final Color? barrierColor;

  /// Translations to display
  final WebTranslations? translations;

  @override
  Map<String, dynamic> toMap() => {};
}

enum RotationAngle {
  clockwise90,
  clockwise180,
  clockwise270,
  counterClockwise90,
  counterClockwise180,
  counterClockwise270,
}

int rotationAngleToNumber(RotationAngle angle) {
  switch (angle) {
    case RotationAngle.clockwise90:
      return -90;
    case RotationAngle.clockwise180:
      return -180;
    case RotationAngle.clockwise270:
      return -270;
    case RotationAngle.counterClockwise90:
      return 90;
    case RotationAngle.counterClockwise180:
      return 180;
    case RotationAngle.counterClockwise270:
      return 270;
  }
}

class WebTranslations {
  const WebTranslations({
    required this.title,
    required this.rotateLeftTooltip,
    required this.rotateRightTooltip,
    required this.cancelButton,
    required this.cropButton,
  });

  const WebTranslations.en()
      : title = 'Crop Image',
        rotateLeftTooltip = 'Rotate 90 degree counter-clockwise',
        rotateRightTooltip = 'Rotate 90 degree clockwise',
        cancelButton = 'Cancel',
        cropButton = 'Crop';
  final String title;
  final String rotateLeftTooltip;
  final String rotateRightTooltip;
  final String cancelButton;
  final String cropButton;
}
