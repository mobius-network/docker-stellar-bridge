#!/bin/sh

set -eu

if [ "X$BRIDGE_SKIP_DB_INIT" == "Xfalse" ]
then

  _db_type=$(/bin/grep -vE '^[ \t]*$' $BRIDGE_CONFIG_FILE |
    /bin/grep -A2 '\[database\]' |
    /bin/grep -E '^[ \t]*type' |
    /bin/sed -E 's/type[ \t]*=[ \t]*"(.*)"/\1/')

  _db_conn_str=$(/bin/grep -vE '^[ \t]*$' $BRIDGE_CONFIG_FILE |
    /bin/grep -A2 '\[database\]' |
    /bin/grep -E '^[ \t]*url' |
    /bin/sed -E 's/url[ \t]*=[ \t]*"(.*)"/\1/')

  case $_db_type in
    postgres)
      echo "Waiting for PostgreSQL DB..."

      until /usr/bin/psql "${_db_conn_str}" -c '\q'
      do
        >&2 echo "PostgreSQL is unavailable - sleeping.."
        sleep 1
      done

      >&2 echo "PostgreSQL is up - continuing..."

      if /usr/bin/psql "${_db_conn_str}" -c "\dt" 2>&1 | grep -qE "(No relations|Did not find any)"
      then
        echo -n "Database is not initialized. Initializing... "
        /usr/local/bin/bridge -c $BRIDGE_CONFIG_FILE --migrate-db && echo "done!"
        exit $?
      fi
      ;;
    mysql)
      echo "Sorry, mysql db auto-migration is not supported."
      echo "Mysql client does not accept go-style Mysql DSN:"
      echo "(https://github.com/go-sql-driver/mysql#dsn-data-source-name)."
      exit 1
      ;;
    *)
      echo "Unknown database type for Bridge server."
      exit 1
      ;;
  esac

  echo "Database was already initialized. Skipping."
else
  echo "Database automatic initialization is disabled. Skipping."
fi
