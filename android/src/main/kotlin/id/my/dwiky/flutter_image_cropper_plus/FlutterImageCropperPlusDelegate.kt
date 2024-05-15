package id.my.dwiky.flutter_image_cropper_plus

import android.app.Activity
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Color
import android.net.Uri
import android.preference.PreferenceManager
import com.yalantis.ucrop.UCrop
import com.yalantis.ucrop.model.AspectRatio
import com.yalantis.ucrop.view.CropImageView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.util.Date

class FlutterImageCropperPlusDelegate(private val activity: Activity) : PluginRegistry.ActivityResultListener {

    private val preferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(activity.applicationContext)
    private var pendingResult: MethodChannel.Result? = null
    private val fileUtils: FileUtils = FileUtils()

    fun startCrop(call: MethodCall, result: MethodChannel.Result?) {
        val sourcePath = call.argument<String>("source_path")
        val maxWidth = call.argument<Int>("max_width")
        val maxHeight = call.argument<Int>("max_height")
        val ratioX = call.argument<Double>("ratio_x")
        val ratioY = call.argument<Double>("ratio_y")
        val cropStyle = call.argument<String>("crop_style")
        val compressFormat = call.argument<String>("compress_format")
        val compressQuality = call.argument<Int>("compress_quality")
        val aspectRatioPresets = call.argument<ArrayList<String>>("aspect_ratio_presets")
        val initAspectRatio = call.argument<String>("android.init_aspect_ratio")
        pendingResult = result
        val outputDir = activity.cacheDir
        val outputFile: File = if ("png" == compressFormat) {
            File(outputDir, "image_cropper_${Date().time}.png")
        } else {
            File(outputDir, "image_cropper_${Date().time}.jpg")
        }
        val sourceUri = Uri.fromFile(File(sourcePath))
        val destinationUri = Uri.fromFile(outputFile)
        val options = UCrop.Options()
        // uCrop.withMaxResultSize(1000, 1000);
        options.setCompressionFormat(if ("png" == compressFormat) Bitmap.CompressFormat.PNG else Bitmap.CompressFormat.JPEG)
        options.setCompressionQuality(compressQuality ?: 90)
        options.setMaxBitmapSize(10000)

        // UI customization settings
        if ("circle" == cropStyle) {
            options.setCircleDimmedLayer(true)
        }
        setupUiCustomizedOptions(options, call)
        if (aspectRatioPresets != null) {
            val aspectRatioList = ArrayList<AspectRatio>()
            var defaultIndex = 0
            for (i in aspectRatioPresets.indices) {
                val preset = aspectRatioPresets[i]
                val aspectRatio = parseAspectRatioName(preset)
                aspectRatioList.add(aspectRatio)
                if (preset == initAspectRatio) {
                    defaultIndex = i
                }
            }
            options.setAspectRatioOptions(defaultIndex, *aspectRatioList.toArray(arrayOf<AspectRatio>()))
        }
        val cropper = UCrop.of(sourceUri, destinationUri).withOptions(options)
        if (maxWidth != null && maxHeight != null) {
            cropper.withMaxResultSize(maxWidth, maxHeight)
        }
        if (ratioX != null && ratioY != null) {
            cropper.withAspectRatio(ratioX.toFloat(), ratioY.toFloat())
        }
        activity.startActivityForResult(cropper.getIntent(activity), UCrop.REQUEST_CROP)
    }

    fun recoverImage(result: MethodChannel.Result) {
        result.success(andClearCachedImage)
    }

    private fun cacheImage(filePath: String) {
        val editor = preferences.edit()
        editor.putString(FILENAME_CACHE_KEY, filePath)
        editor.apply()
    }

    private val andClearCachedImage: String?
        get() {
            if (preferences.contains(FILENAME_CACHE_KEY)) {
                val result = preferences.getString(FILENAME_CACHE_KEY, "")
                val editor = preferences.edit()
                editor.remove(FILENAME_CACHE_KEY)
                editor.apply()
                return result
            }
            return null
        }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == UCrop.REQUEST_CROP) {
            if (resultCode == Activity.RESULT_OK) {
                val resultUri = UCrop.getOutput(data!!)
                val imagePath = fileUtils.getPathFromUri(activity, resultUri!!)
                cacheImage(imagePath)
                finishWithSuccess(imagePath)
                return true
            } else if (resultCode == UCrop.RESULT_ERROR) {
                val cropError = UCrop.getError(data!!)
                finishWithError("crop_error", cropError!!.localizedMessage, cropError)
                return true
            } else if (pendingResult != null) {
                pendingResult!!.success(null)
                clearMethodCallAndResult()
                return true
            }
        }
        return false
    }

    private fun finishWithSuccess(imagePath: String) {
        if (pendingResult != null) {
            pendingResult!!.success(imagePath)
            clearMethodCallAndResult()
        }
    }

    private fun finishWithError(errorCode: String, errorMessage: String, throwable: Throwable?) {
        if (pendingResult != null) {
            pendingResult!!.error(errorCode, errorMessage, throwable)
            clearMethodCallAndResult()
        }
    }

    private fun setupUiCustomizedOptions(options: UCrop.Options, call: MethodCall): UCrop.Options {
        val title = call.argument<String>("android.toolbar_title")
        val toolbarColor = call.argument<Int>("android.toolbar_color")
        val statusBarColor = call.argument<Int>("android.statusbar_color")
        val toolbarWidgetColor = call.argument<Int>("android.toolbar_widget_color")
        val backgroundColor = call.argument<Int>("android.background_color")
        val activeControlsWidgetColor = call.argument<Int>("android.active_controls_widget_color")
        val dimmedLayerColor = call.argument<Int>("android.dimmed_layer_color")
        val cropFrameColor = call.argument<Int>("android.crop_frame_color")
        val cropGridColor = call.argument<Int>("android.crop_grid_color")
        val cropFrameStrokeWidth = call.argument<Int>("android.crop_frame_stroke_width")
        val cropGridRowCount = call.argument<Int>("android.crop_grid_row_count")
        val cropGridColumnCount = call.argument<Int>("android.crop_grid_column_count")
        val cropGridStrokeWidth = call.argument<Int>("android.crop_grid_stroke_width")
        val showCropGrid = call.argument<Boolean>("android.show_crop_grid")
        val lockAspectRatio = call.argument<Boolean>("android.lock_aspect_ratio")
        val hideBottomControls = call.argument<Boolean>("android.hide_bottom_controls")
        if (title != null) {
            options.setToolbarTitle(title)
        }
        if (toolbarColor != null) {
            options.setToolbarColor(toolbarColor)
        }
        if (statusBarColor != null) {
            options.setStatusBarColor(statusBarColor)
        } else if (toolbarColor != null) {
            options.setStatusBarColor(darkenColor(toolbarColor))
        }
        if (toolbarWidgetColor != null) {
            options.setToolbarWidgetColor(toolbarWidgetColor)
        }
        if (backgroundColor != null) {
            options.setRootViewBackgroundColor(backgroundColor)
        }
        if (activeControlsWidgetColor != null) {
            options.setActiveControlsWidgetColor(activeControlsWidgetColor)
        }
        if (dimmedLayerColor != null) {
            options.setDimmedLayerColor(dimmedLayerColor)
        }
        if (cropFrameColor != null) {
            options.setCropFrameColor(cropFrameColor)
        }
        if (cropGridColor != null) {
            options.setCropGridColor(cropGridColor)
        }
        if (cropFrameStrokeWidth != null) {
            options.setCropFrameStrokeWidth(cropFrameStrokeWidth)
        }
        if (cropGridRowCount != null) {
            options.setCropGridRowCount(cropGridRowCount)
        }
        if (cropGridColumnCount != null) {
            options.setCropGridColumnCount(cropGridColumnCount)
        }
        if (cropGridStrokeWidth != null) {
            options.setCropGridStrokeWidth(cropGridStrokeWidth)
        }
        if (showCropGrid != null) {
            options.setShowCropGrid(showCropGrid)
        }
        if (lockAspectRatio != null) {
            options.setFreeStyleCropEnabled(!lockAspectRatio)
        }
        if (hideBottomControls != null) {
            options.setHideBottomControls(hideBottomControls)
        }
        options.setContrastEnabled(false)
        options.setBrightnessEnabled(false)
        options.setSaturationEnabled(false)
        options.setSharpnessEnabled(false)
        return options
    }

    private fun clearMethodCallAndResult() {
        pendingResult = null
    }

    private fun darkenColor(color: Int): Int {
        val hsv = FloatArray(3)
        Color.colorToHSV(color, hsv)
        hsv[2] *= 0.8f
        return Color.HSVToColor(hsv)
    }

    private fun parseAspectRatioName(name: String): AspectRatio {
        return when (name) {
            "square" -> {
                AspectRatio(null, 1.0f, 1.0f)
            }

            "original" -> {
                AspectRatio("Original",
                        CropImageView.SOURCE_IMAGE_ASPECT_RATIO, 1.0f)
            }

            "3x2" -> {
                AspectRatio(null, 3.0f, 2.0f)
            }

            "4x3" -> {
                AspectRatio(null, 4.0f, 3.0f)
            }

            "5x3" -> {
                AspectRatio(null, 5.0f, 3.0f)
            }

            "5x4" -> {
                AspectRatio(null, 5.0f, 4.0f)
            }

            "7x5" -> {
                AspectRatio(null, 7.0f, 5.0f)
            }

            "16x9" -> {
                AspectRatio(null, 16.0f, 9.0f)
            }

            else -> {
                AspectRatio("Original",
                        CropImageView.SOURCE_IMAGE_ASPECT_RATIO, 1.0f)
            }
        }
    }

    companion object {
        const val FILENAME_CACHE_KEY = "imagecropper.FILENAME_CACHE_KEY"
    }

}