![alt text][RX-M LLC]


# Spark


## Spark Operation

This lab demonstrates a simple local deployment where there is one master and one worker.


### 1 - Install Java

Spark runs in the Java virtual machine (JVM), we will install Java 11 to support our Spark work.

```
~$ sudo apt update

...

~$ sudo apt install openjdk-11-jdk -y

...

~$ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

~$ export PATH=$PATH:$JAVA_HOME/bin

~$ javac -version

javac 11.0.15

~$
```

Now install Scala:

```
sudo apt install scala

$ scala -version

Scala code runner version 2.11.12 -- Copyright 2002-2017, LAMP/EPFL

$
```


### 2 - Download Spark

We are using a very recent version of Spark for this lab.

https://spark.apache.org/downloads.html

* 3.2.1
* Pre-built for Apache Hadoop 3.3 and later (Scala 2.13) // latest greatest as of 24-March-2022

> N.B. Spark installs its own version of scala

```
~$ curl -sLO https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2-scala2.13.tgz

~$ tar zxf spark-3.2.1-bin-hadoop3.2-scala2.13.tgz

~$ mv spark-3.2.1-bin-hadoop3.2-scala2.13/ spark/

~$ export SPARK_HOME=$HOME/spark

~$ export PATH=$SPARK_HOME/sbin:$PATH

~$ export PATH=$SPARK_HOME/bin:$PATH

~$ ls $SPARK_HOME/{bin,sbin}

/home/ubuntu/spark/bin:
beeline               find-spark-home.cmd  pyspark.cmd      spark-class       spark-shell.cmd   spark-sql2.cmd     sparkR
beeline.cmd           load-spark-env.cmd   pyspark2.cmd     spark-class.cmd   spark-shell2.cmd  spark-submit       sparkR.cmd
docker-image-tool.sh  load-spark-env.sh    run-example      spark-class2.cmd  spark-sql         spark-submit.cmd   sparkR2.cmd
find-spark-home       pyspark              run-example.cmd  spark-shell       spark-sql.cmd     spark-submit2.cmd

/home/ubuntu/spark/sbin:
decommission-slave.sh   start-all.sh                    start-slaves.sh         stop-master.sh                 stop-worker.sh
decommission-worker.sh  start-history-server.sh         start-thriftserver.sh   stop-mesos-dispatcher.sh       stop-workers.sh
slaves.sh               start-master.sh                 start-worker.sh         stop-mesos-shuffle-service.sh  workers.sh
spark-config.sh         start-mesos-dispatcher.sh       start-workers.sh        stop-slave.sh
spark-daemon.sh         start-mesos-shuffle-service.sh  stop-all.sh             stop-slaves.sh
spark-daemons.sh        start-slave.sh                  stop-history-server.sh  stop-thriftserver.sh

~$
```

Of note are the sbin scripts to start and stop the related processes.


### 3 - Spark Shell

We will use Spark Shell for our client application.

```
~$ spark-shell

WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.apache.spark.unsafe.Platform (file:/home/ubuntu/spark/jars/spark-unsafe_2.13-3.2.1.jar) to constructor java.nio.DirectByteBuffer(long,int)
WARNING: Please consider reporting this to the maintainers of org.apache.spark.unsafe.Platform
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.2.1
      /_/

Using Scala version 2.13.5 (OpenJDK 64-Bit Server VM, Java 11.0.15)
Type in expressions to have them evaluated.
Type :help for more information.
22/06/18 18:53:23 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Spark context Web UI available at http://ip-172-31-37-156.us-east-2.compute.internal:4040
Spark context available as 'sc' (master = local[*], app id = local-1655578404593).
Spark session available as 'spark'.

scala>
```

To exit hit control^d.

```
scala> control^d
:quit
~$
```


### 4 - Running the Spark Master

Launch the Spark master on all interfaces.

```
~$ which start-master.sh

/home/ubuntu/spark/sbin/start-master.sh

~$ start-master.sh --host 0.0.0.0

starting org.apache.spark.deploy.master.Master, logging to /home/ubuntu/spark/logs/spark-ubuntu-org.apache.spark.deploy.master.Master-1-ip-172-31-37-156.out

~$
```


### 5 - Confirmation of Master Process Launched

```
~$ tail $HOME/spark/logs/spark-ubuntu-org.apache.spark.deploy.master.Master*

22/06/18 18:54:45 INFO SecurityManager: Changing modify acls to: ubuntu
22/06/18 18:54:45 INFO SecurityManager: Changing view acls groups to:
22/06/18 18:54:45 INFO SecurityManager: Changing modify acls groups to:
22/06/18 18:54:45 INFO SecurityManager: SecurityManager: authentication disabled; ui acls disabled; users  with view permissions: Set(ubuntu); groups with view permissions: Set(); users  with modify permissions: Set(ubuntu); groups with modify permissions: Set()
22/06/18 18:54:46 INFO Utils: Successfully started service 'sparkMaster' on port 7077.
22/06/18 18:54:46 INFO Master: Starting Spark master at spark://0.0.0.0:7077
22/06/18 18:54:46 INFO Master: Running Spark version 3.2.1
22/06/18 18:54:46 INFO Utils: Successfully started service 'MasterUI' on port 8080.
22/06/18 18:54:46 INFO MasterWebUI: Bound MasterWebUI to 0.0.0.0, and started at http://ip-172-31-37-156.us-east-2.compute.internal:8080
22/06/18 18:54:46 INFO Master: I have been elected leader! New state: ALIVE

~$ pgrep -a java

129421 /usr/lib/jvm/java-11-openjdk-amd64/bin/java -cp /home/ubuntu/spark/conf/:/home/ubuntu/spark/jars/* -Xmx1g org.apache.spark.deploy.master.Master --host ip-172-31-37-156.us-east-2.compute.internal --port 7077 --webui-port 8080 --host 0.0.0.0

~$
```


### 6 - Running the Spark Worker

Similar to the master, lets run a worker, telling it where the master is.

```
~$ which start-worker.sh

/home/ubuntu/spark/sbin/start-worker.sh

~$ start-worker.sh spark://localhost:7077

starting org.apache.spark.deploy.worker.Worker, logging to /home/ubuntu/spark/logs/spark-ubuntu-org.apache.spark.deploy.worker.Worker-1-ip-172-31-37-156.out

~$
```


### 7 - Confirming the Worker Process Launched

Confirms it worked.

```
~$ tail $HOME/spark/logs/spark-ubuntu-org.apache.spark.deploy.worker.Worker*

22/06/18 18:56:39 INFO Worker: Running Spark version 3.2.1
22/06/18 18:56:39 INFO Worker: Spark home: /home/ubuntu/spark
22/06/18 18:56:39 INFO ResourceUtils: ==============================================================
22/06/18 18:56:39 INFO ResourceUtils: No custom resources configured for spark.worker.
22/06/18 18:56:39 INFO ResourceUtils: ==============================================================
22/06/18 18:56:40 INFO Utils: Successfully started service 'WorkerUI' on port 8081.
22/06/18 18:56:40 INFO WorkerWebUI: Bound WorkerWebUI to 0.0.0.0, and started at http://ip-172-31-37-156.us-east-2.compute.internal:8081
22/06/18 18:56:40 INFO Worker: Connecting to master localhost:7077...
22/06/18 18:56:40 INFO TransportClientFactory: Successfully created connection to localhost/127.0.0.1:7077 after 55 ms (0 ms spent in bootstraps)
22/06/18 18:56:40 INFO Worker: Successfully registered with master spark://0.0.0.0:7077

~$
```

We can now check the master and worker are running.

```
~$ pgrep -a java

129421 /usr/lib/jvm/java-11-openjdk-amd64/bin/java -cp /home/ubuntu/spark/conf/:/home/ubuntu/spark/jars/* -Xmx1g org.apache.spark.deploy.master.Master --host ip-172-31-37-156.us-east-2.compute.internal --port 7077 --webui-port 8080 --host 0.0.0.0
129503 /usr/lib/jvm/java-11-openjdk-amd64/bin/java -cp /home/ubuntu/spark/conf/:/home/ubuntu/spark/jars/* -Xmx1g org.apache.spark.deploy.worker.Worker --webui-port 8081 spark://localhost:7077

~$
```

Confirming all via jps. jps is experimental and unsupported, yet has been around for years!

```
~$ jps

129617 Jps
129421 Master
129503 Worker

~$
```

Your pids will differ.


### 8 - Spark UI

In this section we look at the Spark Master UI. The Spark Master and Client have their own UIs.

```
~$ curl http://checkip.amazonaws.com

18.118.134.44 # yours will differ, same IP used when SSHing

~$ curl -sL 18.223.115.142:8080 | grep Spark

        <title>Spark Master at spark://0.0.0.0:7077</title>
                Spark Master at spark://0.0.0.0:7077

~$
```

Open a browser on your laptop to http://18.118.134.44:8080 (use your IP).

![](images/2022-04-24-15-46-28.png)

> nb. If you have another application running on 8080, the next port is selected, example below.

```
~$ tail $HOME/spark/logs/spark-ubuntu-org.apache.spark.deploy.master.Master* | grep 8080

22/04/24 22:35:03 WARN Utils: Service 'MasterUI' could not bind on port 8080. Attempting port 8081.

~$
```


### 9 - Running Test Job

```
~$ spark-shell --master spark://localhost:7077

WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.apache.spark.unsafe.Platform (file:/home/ubuntu/spark/jars/spark-unsafe_2.13-3.2.1.jar) to constructor java.nio.DirectByteBuffer(long,int)
WARNING: Please consider reporting this to the maintainers of org.apache.spark.unsafe.Platform
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 3.2.1
      /_/

Using Scala version 2.13.5 (OpenJDK 64-Bit Server VM, Java 11.0.15)
Type in expressions to have them evaluated.
Type :help for more information.
22/06/18 18:59:14 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Spark context Web UI available at http://ip-172-31-37-156.us-east-2.compute.internal:4040
Spark context available as 'sc' (master = spark://localhost:7077, app id = app-20220618185916-0000).
Spark session available as 'spark'.

scala>
```

Example creation of data that is created in Scala and processed via Spark.

```
scala> val data = 1 to 1000

val data: scala.collection.immutable.Range.Inclusive = Range 1 to 1000

scala> val rdd = sc.parallelize(data, 2)

val rdd: org.apache.spark.rdd.RDD[Int] = ParallelCollectionRDD[0] at parallelize at <console>:1

scala> val odds = rdd.filter(i => i % 2 != 0)

val odds: org.apache.spark.rdd.RDD[Int] = MapPartitionsRDD[1] at filter at <console>:1

scala> odds.take(5)

val res1: Array[Int] = Array(1, 3, 5, 7, 9)
```


### 10 - Client UI

The client has its own UI on port 4040.

![](images/2022-04-24-16-00-31.png)


### 11 - Stopping Spark

```
scala> ^d

:quit

~$ stop-worker.sh

stopping org.apache.spark.deploy.worker.Worker

  ~$ stop-master.sh

stopping org.apache.spark.deploy.master.Master

~$ jps

129887 Jps

~$
```

### 12 - Conclusion

In this lab we installed Spark and used Spark Shell.

<br>

Congratulations, you have completed the Lab.

<br>

_Copyright (c) 2013-2022 RX-M LLC, Cloud Native Consulting, all rights reserved_

[RX-M LLC]: http://rx-m.io/rxm-cnc.png "RX-M LLC"
