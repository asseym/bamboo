#! /bin/sh

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="bamboo server"
NAME=bamboo
PROJECT_DIR=/var/www/bamboo
VENV_DIR=/home/bamboo/.virtualenvs/bamboo/bin
PIDFILE=$PROJECT_DIR/shared/pids/$NAME.pid
SCRIPTNAME=$PROJECT_DIR/current/bin/$NAME.sh
DAEMON=$VENV_DIR/cherryd
DAEMON_ARGS="-i bamboo -c $PROJECT_DIR/current/config/prod.conf -p $PIDFILE -d"

# load the virtualenv
. $VENV_DIR/activate

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

#
# Function that starts the daemon/service
#
do_start()
{
    $DAEMON $DAEMON_ARGS
}

#
# Function that stops the daemon/service
#
do_stop()
{
    if [ -e $PIDFILE ]
    then
        PID=`cat $PIDFILE`
        if ! kill $PID > /dev/null 2>&1
        then
            echo "Could not send SIGTERM to process $PID" >&2
        fi
        rm -f $PIDFILE
    fi
}

case "$1" in
  start)
	[ "$VERBOSE" != no ] && echo "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && echo 0 ;;
		2) [ "$VERBOSE" != no ] && echo 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && echo "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && echo 0 ;;
		2) [ "$VERBOSE" != no ] && echo 1 ;;
	esac
	;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  restart|force-reload)
	#
	# If the "reload" option is implemented then remove the
	# 'force-reload' alias
	#
	echo "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) echo 0 ;;
			1) echo 1 ;; # Old process is still running
			*) echo 1 ;; # Failed to start
		esac
		;;
	  *)
	  	# Failed to stop
		echo 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac
