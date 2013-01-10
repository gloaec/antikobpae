#!/bin/bash
### BEGIN INIT INFO
# Provides: god
# Required-Start: 
# Required-Stop: 
# Default-Start: 2 3 4 5
# Default-Stop: 0 6
# Short-Description: Services Monitoring
# Chkconfig: - 99 1
# Description: start, stop, restart God (bet you feel powerful)
### END INIT INFO

# source function library
. /lib/lsb/init-functions # LINUX
#. /etc/rc.d/init.d/functions # UBUNTU

RUBY_PATH="<%= rvm_path %>/bin"
GEM_PATH="<%= rvm_gem_path %>/bin"
PATH=$RUBY_PATH:$GEM_PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=$GEM_PATH/god
PIDFILE=/var/run/god.pid
LOGFILE=/var/log/god.log
SCRIPTNAME=/etc/init.d/god
CONFIGFILEDIR=/etc/god

#DEBUG_OPTIONS="--log-level debug"
DEBUG_OPTIONS=""

# Gracefully exit if 'god' gem is not available.
test -x $DAEMON || (echo "gem 'god' not found in '$GEM_PATH'" && exit 0)

RETVAL=0

god_start() {
  start_cmd="$DAEMON -l $LOGFILE -P $PIDFILE $DEBUG_OPTIONS"
  #stop_cmd="kill -QUIT `cat $PIDFILE`"
  echo $start_cmd
  $start_cmd || echo -en "god already running"
  RETVAL=$?
  if [ "$RETVAL" == '0' ]; then
    sleep 2 # wait for server to load before loading config files
    if [ -d $CONFIGFILEDIR ]; then
      for file in `ls -1 $CONFIGFILEDIR/*.god`; do
        echo "god: loading $file ..."
        $DAEMON load $file
      done
    fi
  fi
  return $RETVAL
}

god_stop() {
  stop_cmd="god terminate"
  echo $stop_cmd
  $stop_cmd || echo -en "god not running"
}

case "$1" in
  start)
    god_start
    RETVAL=$?
    ;;
  stop)
    god_stop
    RETVAL=$?
    ;;
  restart)
    god_stop
    god_start
    RETVAL=$?
    ;;
  status)
    $DAEMON status
    RETVAL=$?
    ;;
  *)
    echo "Usage: god {start|stop|restart|status}"
    exit 1
    ;;
esac

exit $RETVAL