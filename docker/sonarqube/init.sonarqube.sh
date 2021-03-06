#!/bin/sh
# Start/stop the cron daemon.
#
### BEGIN INIT INFO
# Provides:          cron
# Required-Start:    $remote_fs $syslog $time
# Required-Stop:     $remote_fs $syslog $time
# Should-Start:      $network $named slapd autofs ypbind nscd nslcd winbind
# Should-Stop:       $network $named slapd autofs ypbind nscd nslcd winbind
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Regular background program processing daemon
# Description:       cron is a standard UNIX program that runs user-specified
#                    programs at periodic scheduled times. vixie cron adds a
#                    number of features to the basic UNIX cron, including better
#                    security and more powerful configuration options.
### END INIT INFO

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/opt/sonarqube/bin
DESC="SonarQube Server daemon"
NAME=sonarqube
DAEMON_START=/opt/sonarqube/bin/start-sonarqube
DAEMON_STOP=/opt/sonarqube/bin/stop-sonarqube
DAEMON_STATUS=/opt/sonarqube/bin/status-sonarqube
PIDFILE=/var/run/sonarqube.pid
SCRIPTNAME=/etc/init.d/"$NAME"

test -f $DAEMON_START || exit 0

. /lib/lsb/init-functions

[ -r /etc/default/sonarqube ] && . /etc/default/sonarqube

# Read the system's locale and set cron's locale. This is only used for
# setting the charset of mails generated by cron. To provide locale
# information to tasks running under cron, see /etc/pam.d/cron.
#
# We read /etc/environment, but warn about locale information in
# there because it should be in /etc/default/locale.
parse_environment ()
{
    for ENV_FILE in /etc/environment /etc/default/locale; do
        [ -r "$ENV_FILE" ] || continue
        [ -s "$ENV_FILE" ] || continue

         for var in LANG LANGUAGE LC_ALL LC_CTYPE; do
             value=`egrep "^${var}=" "$ENV_FILE" | tail -n1 | cut -d= -f2`
             [ -n "$value" ] && eval export $var=$value

             if [ -n "$value" ] && [ "$ENV_FILE" = /etc/environment ]; then
                 log_warning_msg "/etc/environment has been deprecated for locale information; use /etc/default/locale for $var=$value instead"
             fi
         done
     done

# Get the timezone set.
    if [ -z "$TZ" -a -e /etc/timezone ]; then
        TZ=`cat /etc/timezone`
    fi
}

# Parse the system's environment
if [ "$READ_ENV" = "yes" ] ; then
    parse_environment
fi


case "$1" in
start)	log_daemon_msg "Starting Sonarqube Server" "sonarqube"
        start_daemon -p $PIDFILE $DAEMON_START $EXTRA_OPTS
        log_end_msg $?
	;;
stop)	log_daemon_msg "Stopping Sonarqube Server" "sonarqube"
        /bin/bash -c $DAEMON_STOP
        killproc -p $PIDFILE $DAEMON_START
        RETVAL=$?
        [ $RETVAL -eq 0 ] && [ -e "$PIDFILE" ] && rm -f $PIDFILE
        log_end_msg $RETVAL
        ;;
restart) log_daemon_msg "Restarting Sonarqube Server" "sonarqube"
        $0 stop
        $0 start
        ;;
status)
        echo "Sonarqube Server status : $(/bin/bash -c $DAEMON_STATUS)"
        status_of_proc -p $PIDFILE $DAEMON_START $NAME && exit 0 || exit $?
        ;;
*)	log_action_msg "Usage: /etc/init.d/sonarqube {start|stop|status|restart}"
        exit 2
        ;;
esac
exit 0
