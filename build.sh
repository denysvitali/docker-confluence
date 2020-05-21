#!/bin/bash
set -e
IMAGE_NAME="confluence"
SOFTWARE="confluence"

DOCKER_HUB_USERNAME="$DOCKER_HUB_USERNAME"

BUILD_EAP=0
SKIP_PUBLISH=0

function usage(){
  echo "Usage $0 [-e] [-s]"
  echo ""
  echo -e "-e\tBuild EAP container images"
  echo -e "-s\tSkip publish to Docker Hub"
  exit 0
}

while getopts "esh" o; do
    case "${o}" in
        e)
            BUILD_EAP=1
            ;;
        s)
            SKIP_PUBLISH=1
            ;;
        *)
            usage
            ;;
    esac
done

if [ $BUILD_EAP -eq 1 ]; then
  echo "Building EAP"
fi

# Get latest Confluence Version
echo "Getting latest version feed..."
if [ $BUILD_EAP -eq 1 ]; then
  RSS_URL="https://my.atlassian.com/download/feeds/eap/${SOFTWARE/-core/}.rss"
  echo "Building EAP"
	RSS_FILE=$(curl $RSS_URL)
  VERSIONS=$(echo -en "$RSS_FILE" | xmlstarlet sel -t -v '/rss/channel/item/link/text()' -n -)
else
  RSS_URL="https://my.atlassian.com/download/feeds/${SOFTWARE}.rss"
	RSS_FILE=$(curl $RSS_URL)
	VERSIONS=$(echo "$RSS_FILE" | xmlstarlet sel -t -v '/rss/channel/item/guid/text()' -)
fi

LINUX_BIN=$(echo -n "$VERSIONS" | grep '\.bin$')
LINUX_BIN=$(echo -e "$LINUX_BIN" | grep $SOFTWARE)

CURRENT_VERSION=$(echo "$LINUX_BIN" | sed -e "s@https://www.atlassian.com/software/${SOFTWARE/-core/}/downloads/binary/atlassian-$SOFTWARE-@@" -e 's/-x64.bin//' | head -n 1)
CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f 1)
CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d '.' -f 2)
CURRENT_PATCH=$(echo "$CURRENT_VERSION" | cut -d '.' -f 3)


echo "Current version: ${CURRENT_VERSION}"
echo "Current Major: ${CURRENT_MAJOR}"
echo "Current Minor: ${CURRENT_MINOR}"
echo "Current Minor: ${CURRENT_PATCH}"

if [ $BUILD_EAP -eq 1 ]; then
	docker build \
	--build-arg "VERSION=${CURRENT_VERSION}" \
	--build-arg "EAP=1" -t "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" .
else
	docker build --build-arg VERSION="${CURRENT_VERSION}" -t "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" .
fi

if [ $SKIP_PUBLISH -eq 0 ]; then
  echo "Publishing to Docker Hub..."

  if [ $BUILD_EAP -eq 1 ]; then
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:eap"
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}-eap"
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}-eap"
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH}-eap"
  
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}"
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:eap"
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}-eap"
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}-eap"
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH}-eap"
  else
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}"
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}"
  	docker tag "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_VERSION}" "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:latest"
  
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}"
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:${CURRENT_MAJOR}.${CURRENT_MINOR}"
  	docker push "$DOCKER_HUB_USERNAME/${IMAGE_NAME}:latest"
  fi
fi
