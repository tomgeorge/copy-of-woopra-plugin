[![Master Build Status](https://ci.centos.org/buildStatus/icon?subject=master&job=devtools-che-workspace-telemetry-woopra-backend-build-master/)](https://ci.centos.org/view/Devtools/job/devtools-che-workspace-telemetry-woopra-backend-build-master/)

# che-workspace-telemetry-woopra-backend

## Prerequisites

This repo depends on packages in the [GitHub maven package registry](https://github.com/features/packages).
A [personal access token](https://github.com/settings/tokens) with `read:packages` access is required to pull down
dependencies from GitHub.

To compile a native image, you also need [GraalVM 19.2.1](https://www.graalvm.org/) and `native-image`
installed.

Add a repository entry in `$HOME/.m2/settings.xml`:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">
   <servers>
      <server>
         <id>che-incubator</id>
         <username>YOUR GITHUB USERNAME</username>
         <password>YOUR PERSONAL ACCESS TOKEN</password>
      </server>
   </servers>

   <profiles>
      <profile>
         <id>github</id>
         <activation>
            <activeByDefault>true</activeByDefault>
         </activation>
         <repositories>
            <repository>
               <id>central</id>
               <url>https://repo1.maven.org/maven2</url>
               <releases><enabled>true</enabled></releases>
               <snapshots><enabled>false</enabled></snapshots>
            </repository>
            <repository>
               <id>che-incubator</id>
               <name>GitHub navikt Apache Maven Packages</name>
               <url>https://maven.pkg.github.com/che-incubator/che-workspace-telemetry-client</url>
            </repository>
         </repositories>
      </profile>
   </profiles>
</settings>
```

## Building

`mvn package -Pnative`

## Building the Docker Image

### If you have previously built the native binary with `mvn package -Pnative`:

`docker build -f src/main/docker/Dockerfile.native -t image-name:tag .`

### To use the multistage Dockerfile to build the GraalVM native image and docker image

The `Dockerfile` needs two build arguments:

+ `GITHUB_USERNAME` - the GitHub username you intend to use to build the native image.  This user should have an access token with `read:packages` permissions associated with it.
+ `GITHUB_TOKEN` - a GitHub Personal Access Token with `read:packages` permissions to pull down the necessary Maven dependencies.

Then pass in the build arguments:

`docker build --build-arg GITHUB_USERNAME=<github username> --build-arg GITHUB_TOKEN=<personal access token> -f src/main/docker/Dockerfile.multi -t image-name:tag .`

## Running Tests

`mvn verify`
