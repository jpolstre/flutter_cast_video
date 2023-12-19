//package it.aesys.flutter_cast_video
//
//import android.annotation.SuppressLint
//import android.content.Context
//import com.google.android.gms.cast.framework.CastOptions
//import com.google.android.gms.cast.framework.OptionsProvider
//import com.google.android.gms.cast.framework.SessionProvider
//
//class CastOptionsProvider: OptionsProvider {
//    companion object {
//        const val CUSTOM_NAMESPACE = "urn:x-cast:playpelis_namespace"
//    }
//
//    @SuppressLint("VisibleForTests")
//    override fun getCastOptions(p0: Context): CastOptions {
//        val supportedNamespaces: MutableList<String> = ArrayList()
//        supportedNamespaces.add(CUSTOM_NAMESPACE)
//
//        return CastOptions.Builder()
//            .setReceiverApplicationId("myAppId")
//            .setSupportedNamespaces(supportedNamespaces)
//            .setStopReceiverApplicationWhenEndingSession(true)
//            .build()
//    }
//
//    override fun getAdditionalSessionProviders(p0: Context): MutableList<SessionProvider>? {
//        TODO("Not yet implemented")
//    }
//
//}