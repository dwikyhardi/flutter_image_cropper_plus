package id.my.dwiky.flutter_image_cropper_plus

import android.app.Activity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** FlutterImageCropperPlusPlugin */
class FlutterImageCropperPlusPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private val channelName = "id.my.dwiky/flutter_image_cropper_plus"
  private lateinit var channel : MethodChannel
  private var delegate: FlutterImageCropperPlusDelegate? = null
  private var activityPluginBinding: ActivityPluginBinding? = null

  private fun setupActivity(activity: Activity): FlutterImageCropperPlusDelegate {
    delegate = FlutterImageCropperPlusDelegate(activity)
    return delegate!!
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "cropImage") {
      delegate!!.startCrop(call, result)
    } else if (call.method == "recoverImage") {
      delegate!!.recoverImage(result)
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
    channel.setMethodCallHandler(this)
  }

  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    setupActivity(activityPluginBinding.activity)
    this.activityPluginBinding = activityPluginBinding
    activityPluginBinding.addActivityResultListener(delegate!!)
  }

  //////////////////////////////////////////////////////////////////////////////////////
  override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // no need to clear channel
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onDetachedFromActivity() {
    activityPluginBinding!!.removeActivityResultListener(delegate!!)
    activityPluginBinding = null
    delegate = null
  }

  override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
    onAttachedToActivity(activityPluginBinding)
  }
}
