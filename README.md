docker-openldap
===============

A Docker image running OpenLDAP on Debian stable ("wheezy" at the moment). The
Dockerfile is inspired by the well written one from
[cnry/openldap](https://registry.hub.docker.com/u/cnry/openldap/), but as said
before, running a stable Debian and be a little less verbose, but more complete
in the configuration.

NOTE: On purpose, there is no secured channel (TLS/SSL), because I believe that
this service should never be exposed to the internet, but only be used directly
by Docker containers using the `--link` option.

Usage
-----

The most simple form would be to start the application like so (however this is
not the recommended way - see above):

    docker run -d -p 389:389 -e SLAPD_PASSWORD=mysecretpassword -e SLAPD_DOMAIN=ldap.example.org dinkel/openldap

To get the full potential this image offers, one should first create a data-only
container (see "Data persistence" below), start the OpenLDAP daemon as follows:

    docker run -d -name openldap --volumes-from your-data-container dinkel/openldap

An application talking to OpenLDAP should then `--link` the container:

    docker run -d --link openldap:openldap image-using-openldap

The name after the colon in the `--link` section is the hostname where the
OpenLDAP daemon is listening to (the port is the default port `389`).

Configuration (environment variables)
-------------------------------------

For the first run one has to set at least two envrironment variables. The first

    SLAPD_PASSWORD

sets the password for the `admin` user.

The second

    SLAPD_DOMAIN

sets the DC (Domain component) parts. E.g. if one sets it to `ldap.example.org`,
the generated base DC parts would be `...,dc=ldap,dc=example,dc=org`.

There is an optinal third variable

    SLAPD_ORGANIZATION (defaults to $SLAPD_DOMAIN)

that represents the human readable company name (e.g. `Example Inc.`).

After the first start of the image (and the initial configuration), these
envirnonment variables are not evaluated anymore.

Data persistence
----------------

The image exposes the directory, where the data is written
(`VOLUME ["/var/lib/ldap"`). Please make sure that
these directories are saved (in a data-only container or alike) in order to make
sure that everything is restored after a new restart of the application.
