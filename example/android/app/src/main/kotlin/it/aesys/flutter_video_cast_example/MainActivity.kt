package it.aesys.flutter_video_cast_example

import com.google.android.gms.cast.framework.CastContext
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    //la app principal debe ser FlutterFragmentActivity
    //en AndroidManifet.xml agregar: android:theme="@style/Theme.AppCompat.NoActionBar"
    //se debe sobre escribir esto tal como esta:
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    //ok actualizado para 'com.google.android.gms:play-services-cast-framework:21.2.0'
        CastContext.getSharedInstance(applicationContext,  Ejecutor())
    }

}
//ok funca!!!
class Ejecutor: java.util.concurrent.Executor{
    override fun execute(p0: Runnable?) {
        p0?.run()

    }

}
