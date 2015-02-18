#!/bin/bash
set -e

chown -R openldap:openldap /var/lib/ldap/

if [[ ! -f /etc/ldap/docker-configured ]]; then
    if [[ -z "$SLAPD_PASSWORD" ]]; then
        echo >&2 "Error: slapd not configured and SLAPD_PASSWORD not set"
        echo >&2 "Did you forget to add -e SLAPD_PASSWORD=... ?"
        exit 1
    fi

    if [[ -z "$SLAPD_DOMAIN" ]]; then
        echo >&2 "Error: slapd not configured and SLAPD_DOMAIN not set"
        echo >&2 "Did you forget to add -e SLAPD_DOMAIN=... ?"
        exit 1
    fi

    SLAPD_ORGANIZATION="${SLAPD_ORGANIZATION:-${SLAPD_DOMAIN}}"

    cat <<-EOF | debconf-set-selections
        slapd slapd/no_configuration boolean false
        slapd slapd/password1 password $SLAPD_PASSWORD
        slapd slapd/password2 password $SLAPD_PASSWORD
        slapd slapd/internal/adminpw string $SLAPD_PASSWORD
        slapd slapd/internal/generated_adminpw password $SLAPD_PASSWORD
        slapd shared/organization string $SLAPD_ORGANIZATION
        slapd slapd/domain string $SLAPD_DOMAIN
        slapd slapd/backend select hdb
        slapd slapd/allow_ldap_v2 boolean false
        slapd slapd/purge_database boolean false
        slapd slapd/move_old_database boolean true
EOF

    dpkg-reconfigure -f noninteractive slapd >/dev/null 2>&1

    dc_string=""

    IFS="."; declare -a dc_parts=($SLAPD_DOMAIN)

    for dc_part in "${dc_parts[@]}"; do
        dc_string="$dc_string,dc=$dc_part"
    done

    base_string="BASE ${dc_string:1}"

    sed -i "s/^#BASE.*/${base_string}/g" /etc/ldap/ldap.conf

    if [[ -n  "$SLAPD_CONFIG_PASSWORD" ]]; then
        password_hash=`slappasswd -s "${SLAPD_CONFIG_PASSWORD}"`

        slapcat -n0 -F /etc/ldap/slapd.d -l /tmp/config.ldif
        sed -i "s/\(olcRootDN: cn=admin,cn=config\)/\1\nolcRootPW: ${password_hash}/g" /tmp/config.ldif
        rm -rf /etc/ldap/slapd.d/*
        slapadd -n0 -F /etc/ldap/slapd.d -l /tmp/config.ldif >/dev/null 2>&1
    fi

    touch /etc/ldap/docker-configured
fi

exec "$@"
