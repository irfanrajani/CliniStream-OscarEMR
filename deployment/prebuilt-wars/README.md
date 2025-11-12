# Pre-built WAR files

This directory holds pre-built OSCAR WAR files from GitHub Actions builds.

The WAR files are downloaded during the Docker image build process from GitHub Actions artifacts.

## GitHub Actions Workflow

The build-and-deploy.yml workflow:
1. Builds OSCAR WAR from open-o-source using Maven
2. Uploads WAR as artifact
3. Downloads artifact here during Docker image build
4. Dockerfile copies WAR to Tomcat webapps

## Manual Build

If you need to build manually:
```bash
cd open-o-source
mvn clean package -DskipTests -Dcheckstyle.skip=true
cp target/oscar-*.war ../deployment/prebuilt-wars/
```

