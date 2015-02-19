docker-openldap
===============

A Docker image running OpenLDAP on Debian stable ("wheezy" at the moment). The
Dockerfile is inspired by
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

The fourth (somewhat) optional variable

    SLAPD_CONFIG_PASSWORD

allows password protected access to the `dn=config` branch. This helps to
reconfigure the server without interruption (read the
[official documentation](http://www.openldap.org/doc/admin24/guide.html#Configuring%20slapd)).

One can load additional schemas provided in the `slapd` package that are not
installed using the

    SLAPD_ADDITIONAL_SCHEMAS

environment variable with comma-separated enties. As of writing these
instructions, there are the following additional schemas available:
`collective`, `corba`, `duaconf`, `dyngroup`, `java`, `misc`, `openldap`, `pmi`
and `ppolicy`.

After the first start of the image (and the initial configuration), these
envirnonment variables are not evaluated anymore.

Data persistence
----------------

The image exposes one directory (`VOLUME ["/var/lib/ldap"]`). It both holds the
database and the configuration (which is symlinked in a pretty hacky way - see
the `entrypoint.sh` file if interested). Please make sure that this directory is
saved (in a data-only container or alike) in order to make sure that everything
is restored after a new restart of the container.
