import PackagePlugin

/// Runs Masquerade on the secrets file and exposes AppSecrets.swift to the plugin's working directory.
@main
struct MasqueradePlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {
        let outputFile = context.pluginWorkDirectoryURL.appending(path: "AppSecrets.swift")
        let scriptPath = context.package.directoryURL.appending(path: "Scripts/masquerade")
        let secretsPath = context.package.directoryURL.appending(path: ".secrets")
        let inputFile = context.package.directoryURL.appending(path: "Shared/AppSecrets.swift.masque")
        return [
            .buildCommand(
                displayName: "Running masquerade",
                executable: scriptPath,
                arguments: [
                    "-i", inputFile.path(),
                    "-o", outputFile.path(),
                    "-s", secretsPath.path(),
                    "-f"
                ],
                outputFiles: [outputFile]
            )
        ]
    }
}
