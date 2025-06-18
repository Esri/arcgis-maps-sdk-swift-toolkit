// Copyright 2025 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
        let inputFile = context.package.directoryURL.appending(path: "AppSecrets.swift.masque")
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
