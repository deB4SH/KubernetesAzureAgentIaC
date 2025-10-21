#! /bin/bash
REGISTRY="ghcr.io/deb4sh"
#check for git
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi
#check for container runtimes
if [ -x "$(command -v podman)" ]; then
    cli_cmd="podman"
elif [ -x "$(command -v docker)" ]; then
    cli_cmd="docker"
else
    echo "No container cli tool found! Aborting."
    exit -1
fi
# parse options
while getopts :r: flag
do
    case "${flag}" in
        r) REGISTRY=${OPTARG};;
    esac
done

# get current tag information
IS_DEV_BUILD=$(git tag -l --contains HEAD)
GIT_TAG=$(git describe --abbrev=0 --tags HEAD)

if [ -z "$IS_DEV_BUILD" ]
then
    TIMESTAMP=$(date +%s)
    TAG=$(echo "$GIT_TAG"-"$TIMESTAMP")
else 
    TAG=$GIT_TAG
fi

echo "Building azure agent image with tag $TAG"

${cli_cmd}  \
    build . \
    -f src/docker/Dockerfile \
    -t $(echo "$REGISTRY/kubernetes-azure-agent:$TAG")
    