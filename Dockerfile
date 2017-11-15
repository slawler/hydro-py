FROM python:2.7-alpine
MAINTAINER slawler 
#Modified from source: https://github.com/kosecki123/alpine-pygrib to include matplotlib & other libraries

RUN apk add --update --virtual=build_dependencies musl-dev gcc python-dev make cmake g++ gfortran openssl && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    pip install numpy && \
    pip install pandas==0.18.1 && \
    pip install pyproj && \
    pip install matplotlib && \
    pip install jupyter && \
    apk del build_dependencies && \
    apk add --no-cache libstdc++ && \
    apk add --no-cache tini

RUN apk add --virtual=build_dependencies build-base git openssl wget && \
    apk add --no-cache jasper jasper-dev && \
    wget "http://software.ecmwf.int/wiki/download/attachments/3473437/grib_api-1.18.0-Source.tar.gz" && \
    tar -xf grib_api-1.18.0-Source.tar.gz && \
    cd grib_api-1.18.0-Source && \
    ./configure && \
    make && make install && \
    cd .. && rm -rf grib_api-1.18.0-Source && \
    rm -f grib_api-1.18.0-Source.tar.gz && \
    apk del build_dependencies

RUN apk add --virtual=build_dependencies build-base git openssl wget && \
    CFLAGS=-I/usr/local/include pip install pygrib && \
    apk del build_dependencies && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /notebooks

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["jupyter", "notebook", "--no-browser", "--ip=\"*\""]
