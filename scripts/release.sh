#!/bin/bash
VERSION=`git rev-parse --short HEAD`
TAG=v16.14.0-${VERSION}
git tag ${TAG}
git push origin ${TAG}
