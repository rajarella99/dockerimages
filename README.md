# Introduction 
TODO: Give a short introduction of your project. Let this section explain the objectives or the motivation behind this project.

1. acrcreationscript will create Azure Container Registry on scpecific subscription
2. dockerlocalimagecreationscript will create docker images on local windows machine
3. main_serviceplan_appservice_v2 will create new service plan for windows or linux platform and creates new app service for windows or linux as per demand also makes use of windows and linux ARM container template to create specific App service
4. serviceplan including app service creation on azure for both windows and linux environments
5. terraform installation script for octopus pipeline deployments



# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)

# DockerFile Updates

1. Till 42 version the otelcontribcol debian executable installation paths are default and reference to 42VersionDockerfile
2. From 43 version the otelcontribcol debian executable installation paths have been changed and available in latest Dockerfile