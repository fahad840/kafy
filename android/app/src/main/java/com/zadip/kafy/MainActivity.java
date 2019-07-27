package com.zadip.kafy;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "zadip.flutter.io/map";
   static  Result flutterResult;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        flutterResult = result;
                        if (call.method.equals("getLocation")) {
//                           result.success("from native");
                            Intent intent = new Intent(MainActivity.this, MapActivity.class);
                            startActivityForResult(intent, 1);
                        } else {
                            result.notImplemented();
                        }
                    }
                });
    }


    public static void locCallback(String loc) {
        flutterResult.success(loc);

    }

}
