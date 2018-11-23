FROM centos:7 as builder

ARG KEA_DHCP_VERSION=1.4.0-P1

# Refer https://kb.isc.org/docs/kea-build-on-centos

# install all pre-built/native dependencies
RUN yum -y install epel-release \
    && yum -y update \
    && yum repolist \
    && yum -y install deltarpm \
    && yum -y install cmake bison flex pcre-devel libev-devel protobuf-c-devel protobuf-c-compiler make rpm-build doxygen swig which \
    && yum -y install autoconf automake libtool gtest-devel \
    && yum -y install openssl-devel \lsyum 
    && yum -y install git wget \
    && yum -y install log4cplus-devel ccache libcmocka-devel \
    && yum -y install mariadb-devel

# This installs gcc 7. The standard gcc available in CentOS (4.8.5) is too old to compile
RUN yum install -y centos-release-scl \
    && yum -y install devtoolset-7-gcc*

# set PATH
# scl enable devtoolset-7 bash
ENV PATH=/usr/lib64/ccache:/opt/rh/devtoolset-7/root/usr/bin:${PATH}

# Install the correct version of Boost
RUN cd /root/ \
    && wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz \
    && tar xfz boost_1_65_1.tar.gz \
    && rm boost_1_65_1.tar.gz \
    && cd boost_1_65_1 \
    && ./bootstrap.sh \
    && ./b2 --with-system --with-thread --with-date_time --with-regex --with-serialization \
    && ./b2 --with-system --with-thread --with-date_time --with-regex --with-serialization install \
    && cd ..

RUN cd /root/ \
    && wget -nd https://ftp.isc.org/isc/kea/${KEA_DHCP_VERSION}/kea-${KEA_DHCP_VERSION}.tar.gz \
    && tar zxvf kea-${KEA_DHCP_VERSION}.tar.gz \
    && rm kea-${KEA_DHCP_VERSION}.tar.gz \
    && cd kea-${KEA_DHCP_VERSION} \
    && export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig \
    && declare -x PATH="/usr/lib64/ccache:$PATH" \
    && autoreconf --install \
    && ./configure --with-sysrepo --enable-shell --with-mysql=/usr/bin/mysql_config \
    && make -j4 \
    && make install

FROM centos:7
MAINTAINER yongs2 yongs2@hotmail.com

RUN yum -y install epel-release \
    && yum -y update \
    && yum repolist \
    && yum -y install log4cplus \
    && yum -y install mariadb

COPY --from=builder /usr/local /usr/local/

ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib64/mysql:${LD_LIBRARY_PATH}

ENTRYPOINT ["/usr/local/sbin/kea-dhcp4"]
CMD ["-c", "/usr/local/etc/kea/kea-dhcp4.conf"]
