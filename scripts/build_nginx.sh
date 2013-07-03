#!/bin/bash
#
# Requires 'vulcan' to be installed and a build server created.
# https://devcenter.heroku.com/articles/buildpack-binaries

cd $(mktemp -d /tmp/vulcan_nginx.XXXXXXXXXX)
echo $PWD
curl http://nginx.org/download/nginx-1.4.1.tar.gz | tar zxf -
(cd nginx-1.4.1 && curl ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.21.tar.bz2 | tar jxf -)
vulcan build -s nginx-1.4.1 -v -p /tmp/nginx -c './configure --with-pcre=pcre-8.21 --prefix=/tmp/nginx && make install'
