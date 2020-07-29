FROM alpine:3.12

# WARNING
# WARNING
# CHECK ALL TODO

# TODO: Check which of those we sill need
RUN apk --no-cache add \
        ca-certificates \
        libuuid \
        apr \
        apr-util \
        libjpeg-turbo \
        libpng \
        icu \
        icu-libs \
        openssl \
        pcre \
        zlib

# Check https://github.com/apache/incubator-pagespeed-ngx/releases for the latest version
ARG PAGESPEED_VERSION=v1.13.35.2-stable

# TODO: SHOULD PROBABLY REMOVE
# This sadly requires an old version of http://www.libpng.org/pub/png/libpng.html
#ARG LIBPNG_VERSION=1.2.56

# http://nginx.org/en/download.html
ARG NGINX_VERSION=1.18.0

# TODO: WIP Trying to build PSOL from source instead of downloading premade binaries.
# See also https://github.com/apache/incubator-pagespeed-ngx/wiki/Building-PSOL-From-Source
RUN set -x \
 && apk add --no-cache -t .deps \
        bash \
        git \
 && cd /tmp \
    # TODO: Current latest-stable does NOT have submodules defined properly.
 && git clone --branch latest-stable --recurse-submodules --depth 1 --shallow-submodules https://github.com/apache/incubator-pagespeed-ngx.git \
 && cd incubator-pagespeed-ngx/testing-dependencies/mod_pagespeed \
    # Hack to have a dummy lsb_release (required by PSOL).
 && printf '#!/bin/sh\necho Debian' >/usr/local/bin/lsb_release \
 && chmod +x /usr/local/bin/lsb_release \
    # Build PSOL from source.
 && install/build_psol.sh --skip_tests --skip_packaging \
 && rm /usr/local/bin/lsb_release \


RUN set -x \
 && apk add --no-cache \
        pcre \
        zlib \
 && apk add ---no-cache -t .build-deps \
        g++ \
        # TODO: Currently ./configure cannot "find" PSOD because LIBC links are broken/missing, even with libc6-compat.
        libc6-compat \
        make \
        pcre-dev \
        util-linux-dev \
        zlib-dev \
    # Download PageSpeed (and PSOL).
 && wget -O- https://github.com/apache/incubator-pagespeed-ngx/archive/${PAGESPEED_VERSION}.tar.gz | tar -xzC /tmp \
 && mv /tmp/incubator-pagespeed-ngx-* /tmp/ngx_pagespeed \
 && cd $_ \
 && PSOL_BINARY_URL=$(sh scripts/format_binary_url.sh PSOL_BINARY_URL) \
 && wget -O- ${PSOL_BINARY_URL} | tar -xz \
    # Build Nginx with support for PageSpeed.
 && wget -O- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -xzC /tmp \
 && cd /tmp/nginx-* \
 && ./configure --add-module=/tmp/ngx_pagespeed \
 && make install --silent

# TODO: Old Dockerfile below:
#       apache2-dev \
#       apr-dev \
#       apr-util-dev \
#       build-base \
#       curl \
#       icu-dev \
#       libjpeg-turbo-dev \
#       linux-headers \
#       gperf \
#       openssl-dev \
#       pcre-dev \
#       python \
#       zlib-dev \
#   # Build libpng:
#&& cd /tmp \
#&& curl -L http://prdownloads.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.gz | tar -zx \
#&& cd /tmp/libpng-${LIBPNG_VERSION} \
#&& ./configure --build=$CBUILD --host=$CHOST --prefix=/usr --enable-shared --with-libpng-compat \
#&& make install V=0 \
#   # Build PageSpeed:
#&& cd /tmp \
#&& wget -O- https://github.com/apache/incubator-pagespeed-ngx/archive/${PAGESPEED_VERSION}.tar.gz | tar -zx \
# && curl -L https://github.com/pagespeed/ngx_pagespeed/archive/v${PAGESPEED_VERSION}-beta.tar.gz | tar -zx \
#&& curl -L https://dl.google.com/dl/linux/mod-pagespeed/tar/beta/mod-pagespeed-beta-${PAGESPEED_VERSION}-r0.tar.bz2 | tar -jx \
#&& cd /tmp/incubator-pagespeed-ngx-* \
#&& curl -L https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/automatic_makefile.patch | patch -p1 \
#&& curl -L https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/libpng_cflags.patch | patch -p1 \
#&& curl -L https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/pthread_nonrecursive_np.patch | patch -p1 \
#&& curl -L https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/rename_c_symbols.patch | patch -p1 \
#&& curl -L https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/stack_trace_posix.patch | patch -p1 \
#&& ./generate.sh -D use_system_libs=1 -D _GLIBCXX_USE_CXX11_ABI=0 -D use_system_icu=1 \
#&& cd /tmp/modpagespeed-${PAGESPEED_VERSION}/src \
#&& make BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I/tmp/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I/tmp/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" \
#&& cd /tmp/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed/automatic/ \
#&& make psol BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I/tmp/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I/tmp/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" \
#&& mkdir -p /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol \
#&& mkdir -p /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/lib/Release/linux/x64 \
#&& mkdir -p /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/out/Release \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/out/Release/obj /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/out/Release/ \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/net /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/testing /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/third_party /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/tools /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ \
#&& cp -r /tmp/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed/automatic/pagespeed_automatic.a /tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/lib/Release/linux/x64 \

#RUN set -x \
#    # Build Nginx with support for PageSpeed:
# && cd /tmp \
# && curl -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zx \
# && cd /tmp/nginx-${NGINX_VERSION} \
# && LD_LIBRARY_PATH=/tmp/modpagespeed-${PAGESPEED_VERSION}/usr/lib ./configure --with-ipv6 \
#        --prefix=/var/lib/nginx \
#        --sbin-path=/usr/sbin \
#        --modules-path=/usr/lib/nginx \
#        --with-http_ssl_module \
#        --with-http_gzip_static_module \
#        --with-file-aio \
#        --with-http_v2_module \
#        --without-http_autoindex_module \
#        --without-http_browser_module \
#        --without-http_geo_module \
#        --without-http_map_module \
#        --without-http_memcached_module \
#        --without-http_userid_module \
#        --without-mail_pop3_module \
#        --without-mail_imap_module \
#        --without-mail_smtp_module \
#        --without-http_split_clients_module \
#        --without-http_scgi_module \
#        --without-http_referer_module \
#        --without-http_upstream_ip_hash_module \
#        --prefix=/etc/nginx \
#        --conf-path=/etc/nginx/nginx.conf \
#        --http-log-path=/var/log/nginx/access.log \
#        --error-log-path=/var/log/nginx/error.log \
#        --pid-path=/var/run/nginx.pid \
#        --add-module=/tmp/ngx_pagespeed-${PAGESPEED_VERSION}-beta \
#        --with-cc-opt="-fPIC -I /usr/include/apr-1" \
#        --with-ld-opt="-luuid -lapr-1 -laprutil-1 -licudata -licuuc -L/tmp/modpagespeed-${PAGESPEED_VERSION}/usr/lib -lpng12 -lturbojpeg -ljpeg" \
# && make install --silent \

RUN set -x \
    # forward request and error logs to docker log collector
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
    # Make PageSpeed cache writable:
 && mkdir -p /var/cache/ngx_pagespeed \
 && chmod -R o+wr /var/cache/ngx_pagespeed

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
