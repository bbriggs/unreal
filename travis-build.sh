#! /bin/bash

set -xe

export DOCKER_REPO="bbriggs/unrealircd"

build_latest () {
	docker build -t $DOCKER_REPO:latest .
}

build_tag () {
	# Build
	if [[ -z "$DOCKERFILE" ]]; then
		docker build --build-arg VERSION=$TAG -t $DOCKER_REPO:$TAG .
	else
		docker build -f $DOCKERFILE --build-arg VERSION=$TAG -t $DOCKER_REPO:$TAG .
	fi
}

push () {
	if [[ "$TRAVIS_BRANCH" = "master" ]]; then
		docker push $DOCKER_REPO:$TAG
	else
		exit 0
	fi
}

if [ $TAG = "latest" ]; then
	build_latest
else
	build_tag
fi

push
