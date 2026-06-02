package com.odukle.cineverse

import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			CHANNEL_NAME,
		).setMethodCallHandler { call, result ->
			if (call.method != "getNetworkDiagnostics") {
				result.notImplemented()
				return@setMethodCallHandler
			}

			Thread {
				try {
					val diagnostics = collectNetworkDiagnostics()
					Handler(Looper.getMainLooper()).post {
						result.success(diagnostics)
					}
				} catch (exception: Exception) {
					Handler(Looper.getMainLooper()).post {
						result.error(
							"NETWORK_DIAGNOSTICS_FAILED",
							exception.message,
							exception.toString(),
						)
					}
				}
			}.start()
		}
	}

	private fun collectNetworkDiagnostics(): Map<String, Any?> {
		val connectivityManager =
			getSystemService(ConnectivityManager::class.java)
				?: error("ConnectivityManager unavailable")
		val activeNetwork = connectivityManager.activeNetwork
		val capabilities = activeNetwork?.let(connectivityManager::getNetworkCapabilities)
		val linkProperties = activeNetwork?.let(connectivityManager::getLinkProperties)
		val omdbLookup = runCatching {
			InetAddress.getAllByName("omdbapi.com")
				.mapNotNull { it.hostAddress }
				.distinct()
		}

		return mapOf(
			"activeNetworkPresent" to (activeNetwork != null),
			"transports" to buildTransportList(capabilities),
			"hasInternetCapability" to hasCapability(
				capabilities,
				NetworkCapabilities.NET_CAPABILITY_INTERNET,
			),
			"isValidated" to hasCapability(
				capabilities,
				NetworkCapabilities.NET_CAPABILITY_VALIDATED,
			),
			"isNotRestricted" to hasCapability(
				capabilities,
				NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED,
			),
			"isVpnTransport" to hasTransport(
				capabilities,
				NetworkCapabilities.TRANSPORT_VPN,
			),
			"isMetered" to connectivityManager.isActiveNetworkMetered,
			"interfaceName" to linkProperties?.interfaceName,
			"dnsServers" to linkProperties?.dnsServers
				?.mapNotNull { it.hostAddress }
				?.distinct()
				.orEmpty(),
			"privateDnsActive" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
				linkProperties?.isPrivateDnsActive
			} else {
				null
			},
			"privateDnsServerName" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
				linkProperties?.privateDnsServerName
			} else {
				null
			},
			"omdbLookupAddresses" to omdbLookup.getOrNull().orEmpty(),
			"omdbLookupError" to omdbLookup.exceptionOrNull()?.message,
		)
	}

	private fun buildTransportList(capabilities: NetworkCapabilities?): List<String> {
		if (capabilities == null) {
			return emptyList()
		}

		val transports = mutableListOf<String>()

		if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
			transports += "wifi"
		}
		if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
			transports += "cellular"
		}
		if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
			transports += "ethernet"
		}
		if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) {
			transports += "bluetooth"
		}
		if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
			transports += "vpn"
		}

		return transports
	}

	private fun hasCapability(
		capabilities: NetworkCapabilities?,
		capability: Int,
	): Boolean = capabilities?.hasCapability(capability) == true

	private fun hasTransport(
		capabilities: NetworkCapabilities?,
		transport: Int,
	): Boolean = capabilities?.hasTransport(transport) == true

	private companion object {
		const val CHANNEL_NAME = "com.odukle.cineverse/network_diagnostics"
	}
}
