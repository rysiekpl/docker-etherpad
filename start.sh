#!/bin/bash
#

# make sure the logfile exists and has teh right permissions
mkdir -p /var/log/etherpad/
chown -R etherpad:etherpad /var/log/etherpad

# do we have a settings file?
if [ ! -s /opt/etherpad/config/settings.json ]; then

    #
    # General settings
    #

    # use envvars if set, otherwise -- sane defaults
    ETHERPAD_TITLE="${ETHERPAD_TITLE:-Etherpad}"
    ETHERPAD_FAVICON="${ETHERPAD_FAVICON:-favicon.ico}"
    ETHERPAD_IP="${ETHERPAD_IP:-0.0.0.0}"
    ETHERPAD_PORT="${ETHERPAD_PORT:-9001}"
    ETHERPAD_DEFAULT_PAD_TEXT="${ETHERPAD_DEFAULT_PAD_TEXT:-Welcome to Etherpad!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nGet involved with Etherpad at http:\/\/etherpad.org\n}"

    ETHERPAD_PAD_OPTIONS_NO_COLORS="${ETHERPAD_PAD_OPTIONS_NO_COLORS:-false}"
    ETHERPAD_PAD_OPTIONS_SHOW_CONTROLS="${ETHERPAD_PAD_OPTIONS_SHOW_CONTROLS:-true}"
    ETHERPAD_PAD_OPTIONS_SHOW_CHAT="${ETHERPAD_PAD_OPTIONS_SHOW_CHAT:-true}"
    ETHERPAD_PAD_OPTIONS_SHOW_LINE_NUMBERS="${ETHERPAD_PAD_OPTIONS_SHOW_LINE_NUMBERS:-true}"
    ETHERPAD_PAD_OPTIONS_USE_MONOSPACE_FONT="${ETHERPAD_PAD_OPTIONS_USE_MONOSPACE_FONT:-false}"
    ETHERPAD_PAD_OPTIONS_USER_NAME="${ETHERPAD_PAD_OPTIONS_USER_NAME:-false}"
    ETHERPAD_PAD_OPTIONS_USER_COLOR="${ETHERPAD_PAD_OPTIONS_USER_COLOR:-false}"
    ETHERPAD_PAD_OPTIONS_RTL="${ETHERPAD_PAD_OPTIONS_RTL:-false}"
    ETHERPAD_PAD_OPTIONS_ALWAYS_SHOW_CHAT="${ETHERPAD_PAD_OPTIONS_ALWAYS_SHOW_CHAT:-false}"
    ETHERPAD_PAD_OPTIONS_CHAT_AND_USERS="${ETHERPAD_PAD_OPTIONS_CHAT_AND_USERS:-false}"
    ETHERPAD_PAD_OPTIONS_LANG="${ETHERPAD_PAD_OPTIONS_LANG:-en-gb}"

    ETHERPAD_ALLOW_UNKNOWN_FILE_ENDS="${ETHERPAD_ALLOW_UNKNOWN_FILE_ENDS:-true}"

    # This setting is used if you require authentication of all users.
    # Note: /admin always requires authentication.
    ETHERPAD_REQUIRE_AUTHENTICATION="${ETHERPAD_REQUIRE_AUTHENTICATION:-false}"

    # Require authorization by a module, or a user with is_admin set, see below.
    ETHERPAD_REQUIRE_AUTHORIZATION="${ETHERPAD_REQUIRE_AUTHORIZATION:-false}"

    # when you use NginX or another proxy/ load-balancer set this to true
    ETHERPAD_TRUST_PROXY="${ETHERPAD_TRUST_PROXY:-false}"

    # by default IP logging is disabled
    ETHERPAD_DISABLE_IP_LOGGING="${ETHERPAD_DISABLE_IP_LOGGING:-true}"

    # Allow Load Testing tools to hit the Etherpad Instance.  Warning this will disable security on the instance.
    ETHERPAD_LOAD_TEST="${ETHERPAD_LOAD_TEST:-false}"

    # The log level we are using, can be: DEBUG, INFO, WARN, ERROR
    ETHERPAD_LOG_LEVEL="${ETHERPAD_LOG_LEVEL:-INFO}"
    ETHERPAD_LOG_FILENAME="${ETHERPAD_LOG_FILENAME:-/var/log/etherpad/etherpad.log}"
    ETHERPAD_LOG_MAX_LOG_SIZE="${ETHERPAD_LOG_MAX_LOG_SIZE:-1024}"
    ETHERPAD_LOG_BACKUPS="${ETHERPAD_LOG_BACKUPS:-1}" # how many log files there're gonna be at max

    #
    # SSL settings...
    #
    ETHERPAD_SSL=""
    # ...only if we have a key and a cert
    if [ ! -z ${ETHERPAD_SSL_KEY+x} ] && [ ! -z ${ETHERPAD_SSL_CERT+x} ]; then
        # please note, this one's tricky! it should be of the form:
        # ["/path-to-your/epl-intermediate-cert1.crt", "/path-to-your/epl-intermediate-cert2.crt"]
        ETHERPAD_SSL_CA="${ETHERPAD_SSL_CA:-[]}"

        # put the SSL settings into the file
        read -r -d '' ETHERPAD_SSL <<SSL
    "ssl" : {
        "key"  : "$ETHERPAD_SSL_KEY",
        "cert" : "$ETHERPAD_SSL_CERT",
        "ca": $ETHERPAD_SSL_CA
    },
SSL
fi


    #
    # Database settings
    #

    # The Type of the database. You can choose between dirty, postgres, sqlite and mysql
    # You shouldn't use "dirty" for for anything else than testing or development
    ETHERPAD_DATABASE=""

    case "$ETHERPAD_DB_TYPE" in
        'postgres')
            # required!
            if [ -z ${ETHERPAD_DB_PASSWORD+x} ]; then
                echo
                echo "ERROR: no database password set for postgres; if you whish to use an empty password"
                echo "ERROR: please explicitly set ETHERPAD_DB_PASSWORD to an empty string"
                echo "ERROR: note that this is strongly discouraged, however!"
                exit 1
            fi
            # defaults should be fine
            ETHERPAD_DB_HOST="${ETHERPAD_DB_HOST:-localhost}"
            ETHERPAD_DB_USER="${ETHERPAD_DB_USER:-etherpad}"
            ETHERPAD_DB_PORT="${ETHERPAD_DB_PORT:-5432}" # this can also be a socket directory, like /var/run/postgresql/
            ETHERPAD_DB_DATABASE="${ETHERPAD_DB_DATABASE:-etherpad}"
            # get the config
            read -r -d '' ETHERPAD_DATABASE <<DBPOSTGRES
    "dbType" : "postgres",
    "dbSettings" : {
        "user"    : "$ETHERPAD_DB_USER",
        "host"    : "$ETHERPAD_DB_HOST",
        "password": "$ETHERPAD_DB_PASSWORD",
        "database": "$ETHERPAD_DB_DATABASE"
        "port"    : "$ETHERPAD_DB_PORT"
    },
DBPOSTGRES
        ;;
        'mysql')
            # required!
            if [ -z ${ETHERPAD_DB_PASSWORD+x} ]; then
                echo
                echo "ERROR: no database password set for mysql; if you whish to use an empty password"
                echo "ERROR: please explicitly set ETHERPAD_DB_PASSWORD to an empty string"
                echo "ERROR: note that this is strongly discouraged, however!"
                exit 1
            fi
            # defaults should be fine
            ETHERPAD_DB_HOST="${ETHERPAD_DB_HOST:-localhost}"
            ETHERPAD_DB_USER="${ETHERPAD_DB_USER:-etherpad}"
            ETHERPAD_DB_PORT="${ETHERPAD_DB_PORT:-3306}" # this can also be a socket, like /var/lib/mysql/mysql.sock
            ETHERPAD_DB_DATABASE="${ETHERPAD_DB_DATABASE:-etherpad}"
            # get the config
            read -r -d '' ETHERPAD_DATABASE <<DBMYSQL
    "dbType" : "mysql",
    "dbSettings" : {
        "user"    : "$ETHERPAD_DB_USER",
        "host"    : "$ETHERPAD_DB_HOST",
        "password": "$ETHERPAD_DB_PASSWORD",
        "database": "$ETHERPAD_DB_DATABASE"
        "port"    : "$ETHERPAD_DB_PORT"
    },
DBMYSQL
        ;;
        'sqlite')
            ETHERPAD_DB_FILENAME="${ETHERPAD_DB_FILENAME:-var/database.sqlite}"
            read -r -d '' ETHERPAD_DATABASE <<DBSQLITE
    "dbType" : "sqlite",
    "dbSettings" : {
        "filename" : "$ETHERPAD_DB_FILENAME"
    },
DBSQLITE
        ;;
        'dirty')
            ETHERPAD_DB_FILENAME="${ETHERPAD_DB_FILENAME:-var/dirty.db}"
            echo "WARNING: use of database type 'dirty' is strongly discouraged; consider sqlite if possible!"
            read -r -d '' ETHERPAD_DATABASE <<DBDIRTY
    "dbType" : "dirty",
    "dbSettings" : {
        "filename" : "$ETHERPAD_DB_FILENAME"
    },
DBDIRTY
        ;;
        *)
            echo
            echo "ERROR: unknown database type: '$ETHERPAD_DB_TYPE'"
            exit 1
        ;;
    esac


    #
    # Users and authentication settings
    #

    # Admin user for basic authentication. is_admin = true gives access to /admin.
    if [ ! -z ${ETHERPAD_ADMIN_PASSWORD+x} ]; then
        echo "admin user password provided, setting up admin acccount"
        read -r -d '' ETHERPAD_ADMIN <<ADMINUSER
        "admin": {
            "password": "$ETHERPAD_ADMIN_PASSWORD",
            "is_admin": true
        },
ADMINUSER
    else
        # If not set, /admin will not be available!
        echo "WARNING: admin user password not provided, /admin will not be available"
    fi

    # LDAP auth config?
    # ETHERPAD_LDAP_URL can be any valid LDAP url -- ldaps://host:port/ ldap://host:port/ ldapi://%2fvar%2frun%2fldap
    if [ ! -z ${ETHERPAD_LDAP_URL+x} ]; then
        echo "LDAP url provided, setting up LDAP auth..."
        # required settings
        [ -z ${ETHERPAD_LDAP_ACCOUNT_BASE+x} ] && {
            echo
            echo 'ERROR: using LDAP auth and ETHERPAD_LDAP_ACCOUNT_BASE is not set!'
            exit 2
        }
        [ -z ${ETHERPAD_LDAP_GROUP_SEARCH_BASE+x} ] && {
            echo
            echo 'ERROR: using LDAP auth and ETHERPAD_LDAP_GROUP_SEARCH_BASE is not set!'
            exit 2
        }
        # by default we assume that an anonymous bind will give us read-only access to the LDAP directory
        # if that is not the case...
        if [ ! -z ${ETHERPAD_LDAP_ANONYMOUS_READONLY+x} ] && [ $ETHERPAD_LDAP_ANONYMOUS_READONLY == "false" ]; then
            # make sure we have credentials for non-anonymous binding!
            [ -z ${ETHERPAD_LDAP_SEARCH_DN+x} ] && {
                echo
                echo 'ERROR: using LDAP auth and ETHERPAD_LDAP_SEARCH_DN is not set though ETHERPAD_LDAP_ANONYMOUS_READONLY is false!'
                exit 2
            }
            [ -z ${ETHERPAD_LDAP_SEARCH_PWD+x} ] && {
                echo
                echo 'ERROR: using LDAP auth and ETHERPAD_LDAP_SEARCH_PWD is not set though ETHERPAD_LDAP_ANONYMOUS_READONLY is false!'
                exit 2
            }
        fi
        # settings with sane defaults
        ETHERPAD_LDAP_ACCOUNT_PATTERN="${ETHERPAD_LDAP_ACCOUNT_PATTERN:-"(&(objectClass=*)(uid={{username}}))"}"
        ETHERPAD_LDAP_DISSPLAY_NAME_ATTRIBUTE="${ETHERPAD_LDAP_DISSPLAY_NAME_ATTRIBUTE:-cn}"
        ETHERPAD_LDAP_GROUP_ATTRIBUTE="${ETHERPAD_LDAP_GROUP_ATTRIBUTE:-member}"
        ETHERPAD_LDAP_GROUP_ATTRIBUTE_IS_DN="${ETHERPAD_LDAP_GROUP_ATTRIBUTE_IS_DN:-true}"
        ETHERPAD_LDAP_SEARCH_SCOPE="${ETHERPAD_LDAP_SEARCH_SCOPE:-sub}"
        ETHERPAD_LDAP_GROUP_SEARCH="${ETHERPAD_LDAP_GROUP_SEARCH:-(&(cn=admin)(objectClass=groupOfNames))}"
        ETHERPAD_LDAP_ANONYMOUS_READONLY="${ETHERPAD_LDAP_ANONYMOUS_READONLY:-true}"
        # get the config text
        read -r -d '' ETHERPAD_LDAP <<LDAPAUTH
        "ldapauth": {
            "url": "$ETHERPAD_LDAP_URL",
            "accountBase": "$ETHERPAD_LDAP_ACCOUNT_BASE",
            "accountPattern": "$ETHERPAD_LDAP_ACCOUNT_PATTERN",
            "displayNameAttribute": "$ETHERPAD_LDAP_DISSPLAY_NAME_ATTRIBUTE",
            "searchDN": "$ETHERPAD_LDAP_SEARCH_DN",
            "searchPWD": "$ETHERPAD_LDAP_SEARCH_PWD",
            "groupSearchBase": "$ETHERPAD_LDAP_GROUP_SEARCH_BASE",
            "groupAttribute": "$ETHERPAD_LDAP_GROUP_ATTRIBUTE",
            "groupAttributeIsDN": $ETHERPAD_LDAP_GROUP_ATTRIBUTE_IS_DN,
            "searchScope": "$ETHERPAD_LDAP_SEARCH_SCOPE",
            "groupSearch": "$ETHERPAD_LDAP_GROUP_SEARCH"
            "anonymousReadonly": $ETHERPAD_LDAP_ANONYMOUS_READONLY
        },
LDAPAUTH
    fi

    if [ ! -z ${ETHERPAD_ADMIN+x} ] || [ ! -z ${ETHERPAD_LDAP+x} ]; then
        read -r -d '' ETHERPAD_USERS <<USERS
    "users": {
        $ETHERPAD_ADMIN
        $ETHERPAD_LDAP
    },
USERS
    fi

    #
    # The complete settings file
    #

    cat <<SETTINGS > /opt/etherpad/config/settings.json
{
    "title": "$ETHERPAD_TITLE",
    "favicon": "$ETHERPAD_FAVICON",
    "ip": "$ETHERPAD_IP",
    "port" : $ETHERPAD_PORT,
    "defaultPadText" : "$ETHERPAD_DEFAULT_PAD_TEXT",
    "padOptions": {
        "noColors": $ETHERPAD_PAD_OPTIONS_NO_COLORS,
        "showControls": $ETHERPAD_PAD_OPTIONS_SHOW_CONTROLS,
        "showChat": $ETHERPAD_PAD_OPTIONS_SHOW_CHAT,
        "showLineNumbers": $ETHERPAD_PAD_OPTIONS_SHOW_LINE_NUMBERS,
        "useMonospaceFont": $ETHERPAD_PAD_OPTIONS_USE_MONOSPACE_FONT,
        "userName": $ETHERPAD_PAD_OPTIONS_USER_NAME,
        "userColor": $ETHERPAD_PAD_OPTIONS_USER_COLOR,
        "rtl": $ETHERPAD_PAD_OPTIONS_RTL,
        "alwaysShowChat": $ETHERPAD_PAD_OPTIONS_ALWAYS_SHOW_CHAT,
        "chatAndUsers": $ETHERPAD_PAD_OPTIONS_CHAT_AND_USERS,
        "lang": "$ETHERPAD_PAD_OPTIONS_LANG"
    },
    "suppressErrorsInPadText" : true,
    "requireSession" : false,
    "editOnly" : false,
    "sessionNoPassword" : false,
    "minify" : true,
    "maxAge" : 21600,
    "abiword" : "/usr/bin/abiword",
    "tidyHtml" : "/usr/bin/tidy",
    "allowUnknownFileEnds" : $ETHERPAD_ALLOW_UNKNOWN_FILE_ENDS,
    "requireAuthentication" : $ETHERPAD_REQUIRE_AUTHENTICATION,
    "requireAuthorization" : $ETHERPAD_REQUIRE_AUTHORIZATION,
    "trustProxy" : $ETHERPAD_TRUST_PROXY,
    "disableIPlogging" : $ETHERPAD_DISABLE_IP_LOGGING,
    "socketTransportProtocols" : ["xhr-polling", "jsonp-polling", "htmlfile"],
    "loadTest": $ETHERPAD_LOAD_TEST,
    "loglevel": "$ETHERPAD_LOG_LEVEL",
    "logconfig" : {
        "appenders": [
            {
                "type": "console"
            },
            {
                "type": "file",
                "filename": "$ETHERPAD_LOG_FILENAME",
                "maxLogSize": $ETHERPAD_LOG_MAX_LOG_SIZE,
                "backups": $ETHERPAD_LOG_BACKUPS
            }
        ]
    },
    $ETHERPAD_SSL
    $ETHERPAD_DATABASE
    $ETHERPAD_USERS
}
SETTINGS

fi

# run etherpad
exec su -c "/opt/etherpad/bin/run.sh" etherpad