#!/bin/bash
#
# Copyright (c) 2012-2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Output command before executing
set -x

# Exit on error
set -e

# Source environment variables of the jenkins slave
# that might interest this worker.
function load_jenkins_vars() {
  if [ -e "jenkins-env.json" ]; then
    eval "$(./env-toolkit load -f jenkins-env.json \
            DEVSHIFT_TAG_LEN \
            QUAY_USERNAME \
            QUAY_PASSWORD \
            QUAY_ECLIPSE_CHE_USERNAME \
            QUAY_ECLIPSE_CHE_PASSWORD \
            JENKINS_URL \
            GIT_BRANCH \
            GIT_COMMIT \
            BUILD_NUMBER \
            ghprbSourceBranch \
            ghprbActualCommit \
            BUILD_URL \
            ghprbPullId)"
  fi
}

function install_deps() {

  # Get all the deps in
  yum install -y yum-utils device-mapper-persistent-data lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce \
    git

  service docker start
  echo 'CICO: Dependencies installed'
}

function set_release_tag() {
  # Let's obtain the tag based on the
  # version defined in the 'VERSION' file
  TAG=$(head -n 1 VERSION)
  export TAG
}

function set_nightly_tag() {
  # Let's set the tag as nightly
  export TAG="nightly"
}

function tag_push() {
  local TARGET=$1
  docker tag "${IMAGE}" "$TARGET"
  docker push "$TARGET"
}

# Set appropriate environment variables and login to the docker registry
# as the required user.
function setup_environment() {
  export REGISTRY="quay.io"

  GIT_COMMIT_TAG=$(echo "$GIT_COMMIT" | cut -c1-"${DEVSHIFT_TAG_LEN}")
  export GIT_COMMIT_TAG
  export DOCKERFILE_PATH="./src/main/docker/Dockerfile.multi"
  export ORGANIZATION="openshiftio"
  export IMAGE="che-workspace-telemetry-woopra-backend"
  export QUAY_USERNAME=${QUAY_ECLIPSE_CHE_USERNAME}
  export QUAY_PASSWORD=${QUAY_ECLIPSE_CHE_PASSWORD}

  if [ -n "${QUAY_USERNAME}" ] && [ -n "${QUAY_PASSWORD}" ]; then
    docker login -u "${QUAY_USERNAME}" -p "${QUAY_PASSWORD}" "${REGISTRY}"
  else
    echo "Could not login, missing credentials for pushing to the '${ORGANIZATION}' organization"
  fi
}

# Build, tag, and push devfile registry, tagged with ${TAG} and ${GIT_COMMIT_TAG}
function build_and_push() {
  # Let's build and push image to 'quay.io' using git commit hash as tag first
  docker build --build-arg GITHUB_USERNAME=${GITHUB_USERNAME} --build-arg GITHUB_PASSWORD=${GITHUB_PASSWORD} -t ${IMAGE} -f ${DOCKERFILE_PATH} --target che-workspace-telemetry-woopra-backend .
  tag_push "${REGISTRY}/${ORGANIZATION}/${IMAGE}:${GIT_COMMIT_TAG}"
  echo "CICO: '${GIT_COMMIT_TAG}' version of images pushed to '${REGISTRY}/${ORGANIZATION}' organization"

  # If additional tag is set (e.g. "nightly"), let's tag the image accordingly and also push to 'quay.io'
  if [ -n "${TAG}" ]; then
    tag_push "${REGISTRY}/${ORGANIZATION}/${IMAGE}:${TAG}"
    echo "CICO: '${TAG}'  version of images pushed to '${REGISTRY}/${ORGANIZATION}' organization"
  fi
}
