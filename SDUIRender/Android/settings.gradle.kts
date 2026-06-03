// This gradle project is part of a conventional Skip app project.
pluginManagement {
    // Initialize the Skip plugin folder and perform a pre-build for non-Xcode builds
    val pluginPath = File.createTempFile("skip-plugin-path", ".tmp")

    // overriding outputs for an Android IDE can be done by un-commenting and setting the Xcode path:
    //System.setProperty("BUILT_PRODUCTS_DIR", "${System.getProperty("user.home")}/Library/Developer/Xcode/DerivedData/MySkipProject-HASH/Build/Products/Debug-iphonesimulator")

    val skipPluginResult = providers.exec {
        commandLine("/bin/sh", "-c", "skip plugin --prebuild --package-path '${settings.rootDir.parent}' --plugin-ref '${pluginPath.absolutePath}'")
        environment("PATH", "${System.getenv("PATH")}:/opt/homebrew/bin")
    }
    val skipPluginOutput = skipPluginResult.standardOutput.asText.get()
    print(skipPluginOutput)
    val skipPluginError = skipPluginResult.standardError.asText.get()
    print(skipPluginError)

    includeBuild(pluginPath.readText()) {
        name = "skip-plugins"
    }

    repositories {
        mavenLocal()
        gradlePluginPortal()
        google()
        mavenCentral()
        // Inditex Artifactory — define in ~/.gradle/gradle.properties (never commit credentials)
        if (providers.gradleProperty("artifactory_context_url").isPresent) {
            maven {
                val artifactory_context_url: String by settings
                val artifactory_resolve_repokey: String by settings
                val artifactory_username: String by settings
                val artifactory_password: String by settings // pragma: allowlist secret
                url = uri("$artifactory_context_url/$artifactory_resolve_repokey")
                credentials {
                    username = artifactory_username
                    password = artifactory_password // pragma: allowlist secret
                }
            }
        }
    }
}

plugins {
    id("skip-plugin") apply true
}

dependencyResolutionManagement {
    repositories {
        mavenLocal()
        google()
        mavenCentral()
        // Inditex Artifactory — define in ~/.gradle/gradle.properties (never commit credentials)
        if (providers.gradleProperty("artifactory_context_url").isPresent) {
            maven {
                val artifactory_context_url: String by settings
                val artifactory_resolve_repokey: String by settings
                val artifactory_username: String by settings
                val artifactory_password: String by settings // pragma: allowlist secret
                url = uri("$artifactory_context_url/$artifactory_resolve_repokey")
                credentials {
                    username = artifactory_username
                    password = artifactory_password // pragma: allowlist secret
                }
            }
        }
    }
}
