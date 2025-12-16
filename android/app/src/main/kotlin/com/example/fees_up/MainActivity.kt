package com.greyway.fees_up

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle

/*
 * Switch to FlutterFragmentActivity to support plugins that require a FragmentActivity
 * context, such as local_auth (biometric authentication), Google Sign-In, etc.
 * No additional code is required here; plugins will hook into the activity lifecycle.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep default initialization. Plugins (e.g., local_auth) will initialize here as needed.
    }
}
