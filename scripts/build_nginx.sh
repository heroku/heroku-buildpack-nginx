#!/bin/bash
#
# Requires 'vulcan' to be installed and a build server created.
# https://devcenter.heroku.com/articles/buildpack-binaries

NGINX_VERSION=1.4.1
PCRE_VERSION=8.21
NGINX_TARBALL_URL=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
PCRE_TARBALL_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.bz2

script_dir=$(cd $(dirname $0); pwd)
temp_dir=$(mktemp -d /tmp/vulcan_nginx.XXXXXXXXXX)

VULCAN_ARCHIVE_RESULT=$temp_dir/nginx-${NGINX_VERSION}-built-with-vulcan.tar.gz


cleanup() {
  echo "Cleaning up $temp_dir"
  cd /
  rm -rf "$temp_dir"
}
trap cleanup EXIT

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $NGINX_TARBALL_URL"
curl $NGINX_TARBALL_URL | tar xf -

echo "Downloading $PCRE_TARBALL_URL"
(cd nginx-${NGINX_VERSION} && curl $PCRE_TARBALL_URL | tar xf -)

vulcan build -o ${VULCAN_ARCHIVE_RESULT} -s nginx-${NGINX_VERSION} -v -p /tmp/nginx -c "./configure --with-pcre=pcre-${PCRE_VERSION} --prefix=/tmp/nginx && make install"

mkdir -p $temp_dir/untarring
cd $temp_dir/untarring
tar -xf $VULCAN_ARCHIVE_RESULT
cp sbin/nginx $script_dir/../bin
