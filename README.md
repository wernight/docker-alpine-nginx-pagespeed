Supported tags and respective `Dockerfile` links
================================================

  * `v1`, `v1.11`, `v1.11.33.3` and similar are tagged versions of Nginx PageSpeed (with a compatible Nginx).
  * [`latest` (Dockerfile)](https://github.com/wernight/docker-alpine-nginx-pagespeed/blob/master/Dockerfile) [![](https://images.microbadger.com/badges/image/wernight/alpine-nginx-pagespeed.svg)](https://microbadger.com/images/wernight/alpine-nginx-pagespeed "Get your own image badge on microbadger.com")


What is Nginx with PageSpeed Module
-----------------------------------

This is a [Dockerized](https://www.docker.com/) image of [Nginx](https://www.nginx.com/) with [PageSpeed Module](https://developers.google.com/speed/pagespeed/module/) based on [Alpine Linux](https://hub.docker.com/_/alpine).

**PageSpeed Module (for Nginx)** (aka *ngx_pagespeed*) performs a lot of optimizations for websites by default (i.e. without doing anything outside of switching Nginx with this version) like:

  - Minify CSS/JS/HTML/images resources (e.g. recompressed images to *webp* if the client's browser supports it).
  - Cache and prioritize visible content or defer JavaScript.
  - Combine or inline CSS/JavaScript.
  - Flush resources early
  - Clean-up HTML by removing unnecessary tags.
  - ...

You can [see PageSpeed documentation](https://modpagespeed.com/doc/) for more details and settings.


Usage example
-------------

Configuration is very similar to the official [Nginx image](https://hub.docker.com/_/nginx).

    $ docker run -d -p 80:80 wernight/alpine-nginx-pagespeed

You probably want to create a `Dockerfile` based on this image or mount required resources. Most importantly you'd want to customize `/etc/nginx/nginx.conf` and mount static files to your web root (e.g. `/srv/`).


Notes
-----

There is already an official [Nginx based on Alpine Linux](https://hub.docker.com/_/nginx/) however there is no current simple way to add *mod PageSpeed* to it. We need to build it together with *Nginx*, and the smallest image for that, supporting automated builds on [Docker Hub](https://hub.docker.com/), is *Linux Alpine*.

There is also no official build documentation for Alpine Linux (see [ngx_pagespeed #1181](https://github.com/pagespeed/ngx_pagespeed/issues/1181)).


Feedbacks
---------

Suggestions are welcome on our [GitHub issue tracker](https://github.com/wernight/docker-alpine-nginx-pagespeed/issues).
