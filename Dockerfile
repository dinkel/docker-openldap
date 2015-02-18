FROM debian:wheezy

MAINTAINER Christian Luginbühl <dinke@pimprecords.com>

ENV OPENLDAP_VERSION 2.4.31

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        slapd=${OPENLDAP_VERSION}* \
        ldap-utils=${OPENLDAP_VERSION}* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 389

VOLUME ["/var/lib/ldap"]

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["slapd", "-d", "32768"]
