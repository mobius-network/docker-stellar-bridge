#!/bin/sh

set -eux

cd /tmp

curl -fsSLO https://github.com/Masterminds/glide/releases/download/v${GLIDE_VERSION}/glide-v${GLIDE_VERSION}-linux-amd64.tar.gz

echo "${GLIDE_SHA256SUM}  glide-v${GLIDE_VERSION}-linux-amd64.tar.gz" | sha256sum -c -

tar -xzf glide-v${GLIDE_VERSION}-linux-amd64.tar.gz

mv linux-amd64/glide /usr/local/bin/glide

chown root.root /usr/local/bin/glide

cd -
