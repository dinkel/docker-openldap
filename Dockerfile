FROM debian:wheezy

MAINTAINER Christian Luginbühl <dinke@pimprecords.com>

ENV OPENLDAP_VERSION 2.4.31

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ldap-utils=${OPENLDAP_VERSION}* \
        slapd=${OPENLDAP_VERSION}* \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mv /etc/ldap /etc/ldap.dist

EXPOSE 389

VOLUME ["/etc/ldap", "/var/lib/ldap"]

COPY modules/ /etc/ldap.dist/modules

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

ENV MAX_NOFILE 8192

CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]
