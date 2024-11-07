#!/bin/bash
for mirror in $(aptly mirror list -raw); do
    aptly mirror drop "$mirror"
done