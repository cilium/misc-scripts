FROM alpine:latest
MAINTAINER cilium@cilium.io

ADD super_netperf   /sbin/
ADD percpu_netperf  /sbin/
ADD latency_netperf /sbin/

RUN											   \
	apk add --update curl wrk iperf3 git build-base texinfo bash iproute2 automake     \
			 libtool intltool autoconf					&& \
	git clone https://github.com/HewlettPackard/netperf.git				&& \
	cd netperf/									&& \
	./autogen.sh									&& \
	chmod a+x configure								&& \
	./configure --prefix=/usr							&& \
	make										&& \
	make install									&& \
	cd ..										&& \
	rm -rf netperf									&& \
	rm -f /usr/share/info/netperf.info						&& \
	strip -s /usr/bin/netperf /usr/bin/netserver					&& \
	apk del build-base texinfo git automake libtool intltool autoconf		&& \
	rm -rf /var/cache/apk/*

EXPOSE 12865

CMD ["/usr/bin/netserver", "-D"]
