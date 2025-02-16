#!/bin/sh
#--------------------------------------------------------------
# Simple shell-script to run HornetQ standalone for 
#--------------------------------------------------------------

export HORNETQ_HOME=..
mkdir -p ../logs

# By default, the server is started in the non-clustered standalone configuration

if [ a"$1" = a ]; then CONFIG_DIR=$HORNETQ_HOME/config/stand-alone/non-clustered; else CONFIG_DIR="$1"; fi
if [ a"$2" = a ]; then FILENAME=hornetq-beans.xml; else FILENAME="$2"; fi

if [ ! -d $CONFIG_DIR ]; then
    echo script needs to be run from the HORNETQ_HOME/bin directory >&2
    exit 1
fi

HORNETQ_HOST=`ip addr show eth0 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | head -n 1`;
if [ a"$HORNETQ_HOST" = a ]; then HORNETQ_HOST=localhost; fi

RESOLVED_CONFIG_DIR=`cd "$CONFIG_DIR"; pwd`
export CLASSPATH=$RESOLVED_CONFIG_DIR:$HORNETQ_HOME/schemas/

# Use the following line to run with different ports
export CLUSTER_PROPS="-Djnp.port=1099 -Djnp.rmiPort=1098 -Djnp.host=$HORNETQ_HOST -Dhornetq.remoting.netty.host=$HORNETQ_HOST -Dhornetq.remoting.netty.port=5445"

export JVM_ARGS="$CLUSTER_PROPS -XX:+UseParallelGC -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -Xms512M -Xmx$JAVA_MAX_HEAP -Dhornetq.config.dir=$RESOLVED_CONFIG_DIR -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dlogging.configuration=file://$RESOLVED_CONFIG_DIR/logging.properties -Djava.library.path=./lib/linux-i686:./lib/linux-x86_64"

# Use the following line to debug
#export JVM_ARGS="-Djnp.host=$HORNETQ_HOST -Djava.rmi.server.hostname=$HORNETQ_HOST -Dhornetq.remoting.netty.host=$HORNETQ_HOST -Xmx512M -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dlogging.configuration=$CONFIG_DIR/logging.properties -Dhornetq.config.dir=$CONFIG_DIR -Djava.library.path=. -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"

# Use the following line to development mode
#export JVM_ARGS="-Xmx512M -Djnp.host=$HORNETQ_HOST -Djava.rmi.server.hostname=$HORNETQ_HOST -Dhornetq.remoting.netty.host=$HORNETQ_HOST -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dlogging.configuration=$CONFIG_DIR/logging.properties -Dhornetq.config.dir=$CONFIG_DIR -Djava.library.path=. "

for i in `ls $HORNETQ_HOME/lib/*.jar`; do
	CLASSPATH=$i:$CLASSPATH
done

echo "***********************************************************************************"
echo "java $JVM_ARGS -classpath $CLASSPATH org.hornetq.integration.bootstrap.HornetQBootstrapServer $FILENAME"
echo "***********************************************************************************"
java $JVM_ARGS -classpath $CLASSPATH -Dcom.sun.management.jmxremote org.hornetq.integration.bootstrap.HornetQBootstrapServer $FILENAME
