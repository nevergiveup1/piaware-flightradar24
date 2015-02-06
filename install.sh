#!/bin/bash

CONFIGFILE=~/.fr24feed.conf
FR24VERSION=242
INITFILE=/etc/init.d/fr24feed
PROGDIR=/home/pi/fr24
PIDFILE=/var/run/fr24feed.pid


# Stop fr24feed if it's running
if [ -f ${PIDFILE} ]
then
  echo Stop fr24feed from running.
  service fr24feed stop
fi

# Do some initial cleanup.
if [ -d ${PROGDIR} ]
then
  echo Cleaning up the installed fr24feed
  rm -rf ${PROGDIR}
fi

rm -rf ${INITFILE}
rm -rf ${PROGDIR}


# Get the FR24 station key.
if [ -f ${CONFIGFILE} ]
then
  source ${CONFIGFILE} 
else
  echo -n "Enter your station key and press [ENTER]: "
  read FR24KEY 
  echo "FR24KEY=${FR24KEY}" > ${CONFIGFILE} 
fi    


# Create the init.d script
cat <<'EOF' > ${INITFILE} 
### BEGIN INIT INFO
#
# Provides:        fr24feed
# Required-Start:      $network $remote_fs $time
# Required-Stop:        $network $remote_fs $time
# Default-Start:        2 3 4 5
# Default-Stop:        0 1 6
# Short-Description:    fr24feed initscript
# Description:          Enable service provided by daemon.
#
### END INIT INFO

OWNER=pi
PIDDIR=/var/run
LOGDIR=/var/log

# Edit for your environment
FR24FEED=fr24feed_arm-rpi_242
FR24FEED_PATH=/home/pi/fr24
FR24FEED_ARGS="--fr24key=FR24KEY"
FR24FEED_PID=$PIDDIR/fr24feed.pid
FR24FEED_LOG=$LOGDIR/fr24feed.log

# See if the daemons are there
test -x $FR24FEED_PATH/$FR24FEED || exit 

. /lib/lsb/init-functions

start() {
    log_daemon_msg "Starting"

    log_progress_msg "fr24feed"
    if ! start-stop-daemon --start --oknodo --make-pidfile --pidfile $FR24FEED_PID \
        --background --no-close --chuid $OWNER \
        --exec $FR24FEED_PATH/$FR24FEED -- $FR24FEED_ARGS > $FR24FEED_LOG 2>&1
    then
        log_end_msg 1
        exit 1
    fi

    log_end_msg 0
}

stop() {
    log_daemon_msg "Stopping"

    log_progress_msg "fr24feed"
    start-stop-daemon --stop --quiet --pidfile $FR24FEED_PID
    rm -f $FR24FEED_PID

    log_end_msg 0
}

## Check to see if we are running as root first.
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

case "$1" in
    start)
        start
        exit 0
    ;;
    stop)
        stop
        exit 0
    ;;
    reload|restart|force-reload)
        stop
        start
        exit 0
    ;;
    **)
        echo "Usage: $0 {start|stop|reload}" 1>&2
        exit 1
    ;;
esac

exit 0
EOF

sudo sed -i s/FR24KEY/${FR24KEY}/ ${INITFILE}
sudo chmod 0755 ${INITFILE}



# Since we are logging to a file, we should maintain it.
cat <<'EOF' > /etc/logrotate.d/fr24feed
/var/log/fr24feed.log {
  rotate 12
  monthly
  compress
  missingok
  notifempty
}
EOF


# Download and unpack the software
mkdir -p ${PROGDIR}
cd ${PROGDIR}
wget -q https://dl.dropboxusercontent.com/u/66906/fr24feed_arm-rpi_${FR24VERSION}.tgz
tar -xzf fr24feed_arm-rpi_${FR24VERSION}.tgz
chown -R pi:pi ${PROGDIR}


# Set it all up to start at boot time
update-rc.d fr24feed defaults
service fr24feed start
