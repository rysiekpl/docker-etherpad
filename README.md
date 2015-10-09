# Docker Etherpad

Highly configurable Etherpad docker container with LDAP auth support.

## Environment variables

Most of these environment variables are used in the etherpad config file and correspond directly to similarily-named configuration options. See the example Etherpad configuration file.

### Basic configuration options:

 - `ETHERPAD_TITLE` (default: `Etherpad`)

The title of this Etherpad instance.

 - `ETHERPAD_FAVICON` (default: `favicon.ico`)

Favicon to use with this instance.

 - `ETHERPAD_IP` (default: `0.0.0.0`)

IP address to listen on.

 - `ETHERPAD_PORT` (default: `9001`)

TCP port to listen on.

 - `ETHERPAD_DEFAULT_PAD_TEXT` (default: `Welcome to Etherpad!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nGet involved with Etherpad at http:\/\/etherpad.org\n`)

Text to display on a newly created pad.

### Database settings:

 - `ETHERPAD_DB_TYPE` (default: `dirty`)

Database type to use. Possible types: `dirty`, `sqlite`, `postgres`, `mysql`. You shouldn't use `dirty` for for anything else than testing or development!

 - `ETHERPAD_DB_HOST` (default: `localhost`)

Database host (ignored if type is `dirty` or `sqlite`).

 - `ETHERPAD_DB_USER` (default: `etherpad`)

Database user (ignored if type is `dirty` or `sqlite`).

 - `ETHERPAD_DB_PORT` (default: `5432`)

Database port(ignored if type is `dirty` or `sqlite`). For type `postgres` this can also be a socket directory, like `/var/run/postgresql/`; for `mysql` this can also be a socket, like `/var/lib/mysql/mysql.sock`.

 - `ETHERPAD_DB_DATABASE` (default: `etherpad`)

Database name (ignored if type is `dirty` or `sqlite`).

 - `ETHERPAD_DB_PASSWORD`

Database user password (ignored if type is `dirty` or `sqlite`).

 - `ETHERPAD_DB_FILENAME`

Database file filename (ignored if type is `postgres` or `mysql`).

### Optional SSL settings

Optionally you can provide SSL key, certificate and CA file paths. For SSL key and cert are mandatory, CA is optional.

 - `ETHERPAD_SSL_KEY`

SSL key file path.

 - `ETHERPAD_SSL_CERT`

SSL certificate file path.

 - `ETHERPAD_SSL_CA`

Optional CA chain file paths as a JSON array of strings, for example: `[ "/path/to/ca1", "/path/to/ca2" ]`.

### Optional auth settings:

 - `ETHERPAD_ADMIN_PASSWORD`

Password for the `admin` user. If not provided, `/admin` will not be available.

 - `ETHERPAD_LDAP_URL`

LDAP connection URL, for instance `ldapi://%2fvar%2frun%2fldapi` or `ldap://example.com:389/`.

 - `ETHERPAD_LDAP_ACCOUNT_BASE`

LDAP search base for accounts to authenticate against; for example: `ou=people,dc=example,dc=pl`.

 - `ETHERPAD_LDAP_GROUP_SEARCH_BASE`

LDAP search base for groups; for example: `ou=groups,dc=example,dc=pl`.

 - `ETHERPAD_LDAP_ANONYMOUS_READONLY` (default: `true`)

Does the directory allow for readonly search access?

 - `ETHERPAD_LDAP_SEARCH_DN`

LDAP DN for non-readonly search access.

 - `ETHERPAD_LDAP_SEARCH_PWD`

LDAP pasword for non-readonly search access.

 - `ETHERPAD_LDAP_ACCOUNT_PATTERN` (default: `"(&(objectClass=*)(uid={{username}}))"`)

LDAP search pattern for accounts to authenticate against.

 - `ETHERPAD_LDAP_DISPLAY_NAME_ATTRIBUTE` (default: `cn`)

LDAP display name attribute.

 - `ETHERPAD_LDAP_GROUP_ATTRIBUTE` (default: `member`)

LDAP group member attribute.

 - `ETHERPAD_LDAP_GROUP_ATTRIBUTE_IS_DN` (default: `true`)

Does the LDAP group attribute contain a full DN?

 - `ETHERPAD_LDAP_SEARCH_SCOPE` (default: `sub`)

LDAP accounts search scope.

 - `ETHERPAD_LDAP_GROUP_SEARCH` (default: `(&(cn=admin)(objectClass=groupOfNames))`)

 LDAP group search query.
 
### Default settings (can be changed by every pad user for themselves):

 - `ETHERPAD_PAD_OPTIONS_NO_COLORS` (default: `false`)

Should the colors be disabled?

 - `ETHERPAD_PAD_OPTIONS_SHOW_CONTROLS` (default: `true`)

Should the controls be shown?

 - `ETHERPAD_PAD_OPTIONS_SHOW_CHAT` (default: `true`)

Should the chat be visible?

 - `ETHERPAD_PAD_OPTIONS_SHOW_LINE_NUMBERS` (default: `true`)

Should the lines be numbered?
 
 - `ETHERPAD_PAD_OPTIONS_USE_MONOSPACE_FONT` (default: `false`)

Should the font be monospace?

 - `ETHERPAD_PAD_OPTIONS_USER_NAME` (default: `false`)

Default username to use.

 - `ETHERPAD_PAD_OPTIONS_USER_COLOR` (default: `false`)

Default colour to use.

 - `ETHERPAD_PAD_OPTIONS_RTL` (default: `false`)

Should the pad assume text is right-to-left (i.e. Arabic, etc)?

 - `ETHERPAD_PAD_OPTIONS_ALWAYS_SHOW_CHAT` (default: `false`)

Always show chat window?

 - `ETHERPAD_PAD_OPTIONS_CHAT_AND_USERS` (default: `false`)

Always show chat window and users?

 - `ETHERPAD_PAD_OPTIONS_LANG` (default: `gb`)

Default pad interface language.

### Advanced configuration options:

 - `ETHERPAD_ALLOW_UNKNOWN_FILE_ENDS` (default: `true`)

Should the pad accept uploads of files with unknown extentions?

 - `ETHERPAD_REQUIRE_AUTHENTICATION` (default: `false`)

This setting is used if you require authentication of all users. Note: /admin always requires authentication.

 - `ETHERPAD_REQUIRE_AUTHORIZATION` (default: `false`)

Always require authorization by a module, or a user with is_admin set, see below.

 - `ETHERPAD_TRUST_PROXY` (default: `false`)

When you use `nginx` or another proxy/load-balancer set this to true.

 - `ETHERPAD_DISABLE_IP_LOGGING` (default: `true`)

By default IP logging is disabled, for better privacy. Besides, you will probbaly use Etherpad with an `nginx` or other reverse proxy anyway.

 - `ETHERPAD_LOAD_TEST` (default: `false`)

Allow Load Testing tools to hit the Etherpad Instance. **Warning this will disable security on the instance**!

 - `ETHERPAD_LOG_LEVEL` (default: `INFO`)

The log level we are using, can be: DEBUG, INFO, WARN, ERROR; used for both logfile and console logging.

 - `ETHERPAD_LOG_FILENAME` (default: `/var/log/etherpad/etherpad.log`)

Logfile path.

 - `ETHERPAD_LOG_MAX_LOG_SIZE` (default: `1024`)

Maximum size of the logfile.

 - `ETHERPAD_LOG_BACKUPS` (default: `1`)

Maximum number of logfiles.
