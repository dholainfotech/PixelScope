// PixelscopePlugin.kt

package com.dhola.pixelscope

import android.content.Context
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.joyhonest.wifination.wifination
import com.joyhonest.wifination.wifination.OnReceiveFrame
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import java.io.ByteArrayOutputStream
import kotlin.concurrent.thread
import android.util.Log;

//import org.simple.eventbus.EventBus;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode





class PixelscopePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private var eventSink: EventChannel.EventSink? = null
  private lateinit var batteryLevelEventChannel: EventChannel
  private var batteryLevelEventSink: EventChannel.EventSink? = null

  private lateinit var firmwareVersionEventChannel: EventChannel
  private var firmwareVersionEventSink: EventChannel.EventSink? = null
  private lateinit var wifiSSIDEventChannel: EventChannel
  private var wifiSSIDEventSink: EventChannel.EventSink? = null



  // Frame rate control
  private var lastFrameTime: Long = 0
  private val frameInterval: Long = 63 // Approximately 30 FPS

  // Frame buffer to hold the latest frame
  @Volatile
  private var latestFrame: Bitmap? = null
  private var isFrameBeingSent: Boolean = false

  // Implement the required methods for EventChannel.StreamHandler
  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    // Handle the main event channel's onListen
    eventSink = events
    wifination.onReceiveFrame = object : wifination.OnReceiveFrame {
      override fun onReceiveFrame(bmp: Bitmap) {
        sendFrameData(eventSink, bmp)
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    // Handle the main event channel's onCancel
    eventSink = null
    wifination.onReceiveFrame = null
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    val messenger = binding.binaryMessenger
    methodChannel = MethodChannel(messenger, "pixelscope")
    eventChannel = EventChannel(messenger, "pixelscope/frames")
    methodChannel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)

    // Additional EventChannels
    batteryLevelEventChannel = EventChannel(messenger, "pixelscope/battery_level")
    batteryLevelEventChannel.setStreamHandler(batteryLevelStreamHandler)

    firmwareVersionEventChannel = EventChannel(messenger, "pixelscope/firmware_version")
    firmwareVersionEventChannel.setStreamHandler(firmwareVersionStreamHandler)
    wifiSSIDEventChannel = EventChannel(messenger, "pixelscope/wifi_ssid")
    wifiSSIDEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        wifiSSIDEventSink = events
      }
      override fun onCancel(arguments: Any?) {
        wifiSSIDEventSink = null
      }
    })

    EventBus.getDefault().register(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "initSDK" -> {
        val response = wifination.naInit()
        Log.d("PixelscopePlugin", "SDK Initialized with response: $response")
        result.success("SDK Initialized with response: $response")
      }
      "startVideoFeed" -> {
        wifination.naSetRevBmp(true)
//        startVideoFeed()
        result.success("Video Feed Started")
      }
      "stopVideoFeed" -> {
        stopVideoFeed()
        result.success("Video Feed Stopped")
      }
      "snapPhoto" -> {
        val pFileName: String? = call.argument("fileName")
        val phoneOrSD: Int? = call.argument("phoneOrSD")
        if (pFileName != null && phoneOrSD != null) {
          val response = wifination.naSnapPhoto(pFileName, phoneOrSD)
          result.success("Snapshot captured with response: $response")
        } else {
          result.error("INVALID_ARGUMENT", "fileName or phoneOrSD is null", null)
        }
      }
      "startRecord" -> {
        val pFileName: String? = call.argument("fileName")
        val phoneOrSD: Int? = call.argument("phoneOrSD")
        if (pFileName != null && phoneOrSD != null) {
          val response = wifination.naStartRecord(pFileName, phoneOrSD)
          result.success("Recording started with response: $response")
        } else {
          result.error("INVALID_ARGUMENT", "fileName or phoneOrSD is null", null)
        }
      }
      "stopRecord" -> {
        val phoneOrSD: Int? = call.argument("phoneOrSD")
        if (phoneOrSD != null) {
          wifination.naStopRecord(phoneOrSD)
          result.success("Recording stopped")
        } else {
          result.error("INVALID_ARGUMENT", "phoneOrSD is null", null)
        }
      }
      "setBrightness" -> {
        val brightness: Double? = call.argument("brightness")
        if (brightness != null) {
          wifination.naSetBrightness(brightness.toFloat())
          result.success("Brightness set to $brightness")
        } else {
          result.error("INVALID_ARGUMENT", "Brightness is null", null)
        }
      }
      "setContrast" -> {
        val contrast: Double? = call.argument("contrast")
        if (contrast != null) {
          wifination.naSetContrast(contrast.toFloat())
          result.success("Contrast set to $contrast")
        } else {
          result.error("INVALID_ARGUMENT", "Contrast is null", null)
        }
      }
      "setSaturation" -> {
        val saturation: Double? = call.argument("saturation")
        if (saturation != null) {
          wifination.naSetSaturation(saturation.toFloat())
          result.success("Saturation set to $saturation")
        } else {
          result.error("INVALID_ARGUMENT", "Saturation is null", null)
        }
      }
      "setZoom" -> {
        val zoom: Int? = call.argument("zoom")
        if (zoom != null) {
          wifination.naSetUVCA_Zoom(zoom)
          result.success("Zoom set to $zoom")
        } else {
          result.error("INVALID_ARGUMENT", "Zoom is null", null)
        }
      }
      "setMirror" -> {
        val mirror: Boolean? = call.argument("mirror")
        if (mirror != null) {
          wifination.naSetMirror(mirror)
          result.success("Mirror set to $mirror")
        } else {
          result.error("INVALID_ARGUMENT", "Mirror is null", null)
        }
      }
      "setRotation" -> {
        val rotation: Int? = call.argument("rotation")
        if (rotation != null) {
          val response = wifination.naSetRotate(rotation)
          result.success("Rotation set to $rotation degrees with response: $response")
        } else {
          result.error("INVALID_ARGUMENT", "Rotation is null", null)
        }
      }
// Implement other settings as needed...
      "getWifiSSID" -> {
        wifination.naGetWifiSSID()
        result.success("Wi-Fi SSID requested")
      }
      "setWifiSSID" -> {
        val ssid: String? = call.argument("ssid")
        if (ssid != null) {
          wifination.naSetWifiSSID(ssid)
          result.success("Wi-Fi SSID set to $ssid")
        } else {
          result.error("INVALID_ARGUMENT", "SSID is null", null)
        }
      }
      "setWifiPassword" -> {
        val password: String? = call.argument("password")
        if (password != null) {
          val response = wifination.naSetWifiPassword(password)
          result.success("Wi-Fi Password set with response: $response")
        } else {
          result.error("INVALID_ARGUMENT", "Password is null", null)
        }
      }
      "getBatteryLevel" -> {
        wifination.naGetBattery()
        result.success(null) // Indicate that the request was sent
      }
      "getFirmwareVersion" -> {
        wifination.naGetFirmwareVersion()
        result.success(null) // Indicate that the request was sent
      }
      "getDeviceCategory" -> {
        wifination.naGetDeviceCategory()
        result.success("Device category requested")
      }
      "getStatus" -> {
        val status = wifination.naStatus()
        result.success("Current Status: $status")
      }
      "isJoyCamera" -> {
        val isJoyCamera = wifination.naIsJoyCamera()
        result.success(isJoyCamera)
      }
      "checkDevice" -> {
        val isDeviceVerified = wifination.naCheckDevice()
        result.success(isDeviceVerified)
      }
      "setMicOnOff" -> {
        val isOn: Boolean? = call.argument("isOn")
        if (isOn != null) {
          wifination.naSetMicOnOff(isOn)
          result.success("Microphone turned ${if (isOn) "on" else "off"}")
        } else {
          result.error("INVALID_ARGUMENT", "isOn is null", null)
        }
      }
      "getFileList" -> {
        val nType: Int? = call.argument("type")
        val nStartIndex: Int? = call.argument("startIndex")
        val nEndIndex: Int? = call.argument("endIndex")
        if (nType != null && nStartIndex != null && nEndIndex != null) {
          wifination.na4225_GetFileList(nType, nStartIndex, nEndIndex)
          result.success("File list requested")
        } else {
          result.error("INVALID_ARGUMENT", "type, startIndex, or endIndex is null", null)
        }
      }
      "deleteFile" -> {
        val path: String? = call.argument("path")
        val fileName: String? = call.argument("fileName")
        if (path != null && fileName != null) {
          wifination.na4225_DeleteFile(path, fileName)
          result.success("File deletion requested for $fileName")
        } else {
          result.error("INVALID_ARGUMENT", "path or fileName is null", null)
        }
      }
      "deleteAllFiles" -> {
        val nType: Int? = call.argument("type")
        if (nType != null) {
          wifination.na4225_DeleteAll(nType)
          result.success("All files of type $nType deletion requested")
        } else {
          result.error("INVALID_ARGUMENT", "type is null", null)
        }
      }


      // Additional methods will be added here...
      else -> result.notImplemented()
    }
  }


  private fun startVideoFeed() {
    // Set to receive bitmap frames
    wifination.naSetRevBmp(true)
    // Start video feed and set the frame callback
    wifination.onReceiveFrame = object : OnReceiveFrame {
      override fun onReceiveFrame(bmp: Bitmap) {
        sendFrameData(eventSink, bmp)
      }
    }
  }

  private fun stopVideoFeed() {
    // Stop the video feed
    wifination.naStop()
    // Clear the frame callback
    wifination.onReceiveFrame = null
  }

  private fun sendFrameData(sink: EventChannel.EventSink?, bitmap: Bitmap) {
    val currentTime = System.currentTimeMillis()
    if (currentTime - lastFrameTime < frameInterval) {
      // Update the latest frame and skip sending to control frame rate
      latestFrame = bitmap
      return
    }
    lastFrameTime = currentTime

    synchronized(this) {
      if (isFrameBeingSent) {
        // Buffer the latest frame
        latestFrame = bitmap
        return
      }
      isFrameBeingSent = true
    }

    thread {
      try {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream)
        val frameData = byteArrayOutputStream.toByteArray()

        Handler(Looper.getMainLooper()).post {
          sink?.success(frameData)
          isFrameBeingSent = false

          synchronized(this) {
            latestFrame?.let {
              sendFrameData(sink, it)
              latestFrame = null
            }
          }
        }
      } catch (e: Exception) {
        Handler(Looper.getMainLooper()).post {
          sink?.error("FRAME_COMPRESSION_ERROR", "Failed to compress frame: ${e.message}", null)
          isFrameBeingSent = false
        }
      }
    }
  }

  private val batteryLevelStreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      batteryLevelEventSink = events
    }

    override fun onCancel(arguments: Any?) {
      batteryLevelEventSink = null
    }
  }

  private val firmwareVersionStreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      firmwareVersionEventSink = events
    }

    override fun onCancel(arguments: Any?) {
      firmwareVersionEventSink = null
    }
  }

//  // Register EventBus callback
//  EventBus.getDefault().register(this)

  // Implement the callback method
  @Subscribe(threadMode = ThreadMode.MAIN)
  fun onGetBattery(nBattery: Int) {
    batteryLevelEventSink?.success(nBattery)
  }


  @Subscribe(threadMode = ThreadMode.MAIN)
  fun onFirmwareVersion(firmwareVersion: String) {
    firmwareVersionEventSink?.success(firmwareVersion)
  }

  @Subscribe(threadMode = ThreadMode.MAIN)
  fun onGetWifiSSID(ssid: String) {
    wifiSSIDEventSink?.success(ssid)
  }





  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    batteryLevelEventChannel.setStreamHandler(null)
    firmwareVersionEventChannel.setStreamHandler(null)
    eventSink = null
    batteryLevelEventSink = null
    firmwareVersionEventSink = null
    EventBus.getDefault().unregister(this)
  }




}
