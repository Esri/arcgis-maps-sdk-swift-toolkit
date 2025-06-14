import PackagePlugin

@main
struct MasqueradePlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {
        let outputDir = context.pluginWorkDirectoryURL
        let outputFile = outputDir.appending(path: "Sources/GeneratedSecrets/AppSecrets.swift")
        let scriptPath = context.package.directoryURL.appending(path: "Scripts/masquerade")
        let secretsPath = context.package.directoryURL.appending(path: ".secrets")
        let inputFile = context.package.directoryURL.appending(path: "Shared/AppSecrets.swift.masque")
        return [
            .buildCommand(
                displayName: "Generating Secrets",
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
