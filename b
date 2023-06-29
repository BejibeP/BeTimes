Certainly! Here's an example of an Azure DevOps pipeline that builds an ASP.NET Core API from a commit and deploys it as an IIS app:

```yaml
trigger:
  branches:
    include:
      - main

pr:
  branches:
    include:
      - '*'

pool:
  vmImage: 'windows-latest'

variables:
  solution: '**/*.sln'
  buildConfiguration: 'Release'
  iisWebAppName: 'MyApi'

steps:
- task: UseDotNet@2
  displayName: 'Install .NET Core SDK'
  inputs:
    version: '3.x'
    includePreviewVersions: true

- task: NuGetToolInstaller@1
  displayName: 'Install NuGet'
  inputs:
    versionSpec: '>=5.0.0'

- task: NuGetCommand@2
  displayName: 'Restore NuGet packages'
  inputs:
    command: 'restore'
    restoreSolution: '$(solution)'

- task: DotNetCoreCLI@2
  displayName: 'Build the ASP.NET Core API'
  inputs:
    command: 'build'
    projects: '$(solution)'
    configuration: '$(buildConfiguration)'

- task: DotNetCoreCLI@2
  displayName: 'Publish the ASP.NET Core API'
  inputs:
    command: 'publish'
    projects: '$(solution)'
    publishWebProjects: true
    arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'

- task: IISWebAppDeploymentOnMachineGroup@0
  displayName: 'Deploy to IIS'
  inputs:
    WebSiteName: '$(iisWebAppName)'
    Package: '$(Build.ArtifactStagingDirectory)/**/*.zip'
    RemoveAdditionalFilesFlag: true
    AdditionalArguments: '-appPoolName "DefaultAppPool" -SetParametersFile "$(System.DefaultWorkingDirectory)/MyApp/SetParameters.xml"'
```

This pipeline does the following:

1. It triggers the pipeline on commits to the `main` branch and pull requests.
2. It specifies the virtual machine image to use for the build agents (Windows-based image in this case).
3. It defines variables for the solution file, build configuration, and the desired IIS web application name.
4. It installs the .NET Core SDK and NuGet on the build agent.
5. It restores the NuGet packages for the solution.
6. It builds the ASP.NET Core API project.
7. It publishes the API project, producing the necessary artifacts for deployment.
8. It deploys the published artifacts to an IIS web application using the `IISWebAppDeploymentOnMachineGroup` task. You need to replace `MyApi` with the actual name of your web application.
9. The deployment task uses a SetParameters.xml file to configure any additional deployment-specific settings. Make sure to provide the correct path to your SetParameters.xml file.

Note: Ensure that the build agent has the necessary permissions to deploy to the target IIS server.

You can customize this pipeline further based on your specific requirements, such as adding tests, additional build steps, or environment-specific settings.
