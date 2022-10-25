#!/usr/bin/env bash

docker run -d -p 8090:8080 -p 50000:50000 -v ~/Testenv/jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:2.277.1-lts-alpine