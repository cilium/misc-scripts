FROM alpine:latest
MAINTAINER cilium@cilium.io

ADD super_netperf   /sbin/
ADD percpu_netperf  /sbin/
ADD latency_netperf /sbin/

# The CFLAGS=-fcommon - https://gcc.gnu.org/gcc-10/porting_to.html
# Fixes: multiple definition of `loc_nodelay'; nettest_bsd.o:./src/nettest_bsd.c:206: first defined here
RUN	apk add --update \
	curl \
	wrk \
	git \
	build-base \
	texinfo \
	bash \
	iproute2 \
	automake \
	libtool \
	intltool \
	autoconf \
	lksctp-tools-dev \
	linux-headers \
	&& git clone https://github.com/HewlettPackard/netperf.git \
	&& cd netperf/ \
	&& git checkout 3bc455b \
	&& ./autogen.sh	\
	&& chmod a+x configure \
	&& ./configure --prefix=/usr CFLAGS=-fcommon \
	&& make \
	&& make install \
	&& cd .. \
	&& git clone --depth 1 --branch 3.9 https://github.com/esnet/iperf.git \
	&& cd iperf \
	&& ./configure --prefix=/usr \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -rf netperf \
	&& rm -rf iperf \
	&& rm -f /usr/share/info/netperf.info \
	&& strip -s /usr/bin/netperf /usr/bin/netserver \
	&& apk del build-base texinfo git automake libtool intltool autoconf linux-headers \
	&& rm -rf /var/cache/apk/*

EXPOSE 12865

CMD ["/usr/bin/netserver", "-D"]
