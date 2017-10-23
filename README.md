# Apache Mod JK to Tomcat

This is an attempt to get Apache with mod_jk to proxy request to Tomcat


## Build Apache with mod_jk

This is where it was difficult going. Apache doesn't have this module installed by default.

Following these instructions https://tomcat.apache.org/connectors-doc/webserver_howto/apache.html led me on the following journey:

1. Defined a new plan with `core/httpd` as a dependency.
1. Learned to build this module `core/httpd` needed to be a build dependency because it contains `bin/apxs`.
1. That file did not have a correctly defined shebang at the top because `core/httpd` is not build with `core/perl`
1. Added `core/perl` as a dependency for `core/httpd`.
1. When attempting to re-build `core/httpd` it failed because of some version conflicts with `core/apr-util`
1. Re-build `core/apr-util` with no changes whatsoever - just to get latest version of package that was causing the dependency conflict (it becomes `franklinwebber/apr-util`)
1. Finally then able to build this fork of `core/httpd` with perl (it becomes `franklinwebber/httpd`)
1. This sets the shebang at the top of the file correctly and now `franklinwebber/apache-mod-jk` is able to build.
1. Apache modules need to be installed in a particular path so I need to copy `core/httpd`'s hooks, config and defaults and modify it
1. I set the apache ServerRoot to `core/httpd` but then say that the new mod_jk is in the current package
1. The apache service starts
1. I define a binding to tomcat as that seems like it is necessary to populate the `worker.properties` file
1. re-build the package

```
# !!!! You will have to change all the uses of my origin/packagename as dependencies and build dependencies
$ hab studio enter
$ build apr-util
$ build httpd
$ build apache-mod-jk
```

## Build Tomcat7

This was less difficult but did require some modifications to get them to run.

1. The default `core/tomcat7` and `core/tomcat8` plans do not have any dependencies on java so I needed to create my own
1. Created a new plan called `tcat` added `core/tomcat7` and `core/jre8` as dependencies
1. There is nothing to build or install
1. Copy all the config from `core/tomcat7`. Modified it based on a working example provided by Sean.
1. Copy all the hooks from `core/tomcat7`. Modified the hooks to copy not from this package but from `core/tomcat7`.
1. Build the package

```
# !!!! You will have to change all the uses of my origin/packagename as dependencies and build dependencies
$ build tcat
```

## Run

```
$ hab svc start franklinwebber/tcat
$ hab svc start franklinwebber/apache-mod-jk --bind=tomcat:tcat.default
```

The logs look like this:

```
tcat.default(SR): Configuration recompiled
tcat.default(SR): Initializing
tcat.default hook[init]:(HK): Preparing TOMCAT_HOME...
tcat.default hook[init]:(HK): Linking conf_server.xml
tcat.default hook[init]:(HK): '/hab/svc/tcat/var/tc/conf/server.xml' -> '/hab/svc/tcat/config/conf_server.xml'
tcat.default hook[init]:(HK): Linking conf_tomcat-users.xml
tcat.default hook[init]:(HK): '/hab/svc/tcat/var/tc/conf/tomcat-users.xml' -> '/hab/svc/tcat/config/conf_tomcat-users.xml'
tcat.default hook[init]:(HK): Linking webapps_host-manager_META-INF_context.xml
tcat.default hook[init]:(HK): '/hab/svc/tcat/var/tc/webapps/host-manager/META-INF/context.xml' -> '/hab/svc/tcat/config/webapps_host-manager_META-INF_context.xml'
tcat.default hook[init]:(HK): Done preparing TOMCAT_HOME
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/config/conf_tomcat-users.xml': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/config/conf_server.xml': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/config/webapps_host-manager_META-INF_context.xml': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/hooks/run': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/hooks/init': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/hooks': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/logs/init.stdout.log': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/logs/init.stderr.log': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/logs': Operation not permitted
tcat.default hook[init]:(HK): chown: changing ownership of '/hab/svc/tcat/run': Operation not permitted
tcat.default(SV): Starting service as user=hab, group=hab
tcat.default(O): Starting Apache Tomcat
tcat.default(O): Executing Tomcat here: /hab/svc/tcat/var/tc/bin/catalina.sh
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Server version:        Apache Tomcat/7.0.73
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Server built:          Nov 7 2016 21:27:23 UTC
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Server number:         7.0.73.0
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: OS Name:               Linux
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: OS Version:            4.9.49-moby
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Architecture:          amd64
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Java Home:             /hab/pkgs/core/jre8/8u131/20170622181030
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: JVM Version:           1.8.0_131-b11
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: JVM Vendor:            Oracle Corporation
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: CATALINA_BASE:         /hab/svc/tcat/var/tc
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: CATALINA_HOME:         /hab/svc/tcat/var/tc
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Djava.util.logging.config.file=/hab/svc/tcat/var/tc/conf/logging.properties
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Djdk.tls.ephemeralDHKeySize=2048
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Djava.security.egd=file:/dev/./urandom
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Djava.endorsed.dirs=/hab/svc/tcat/var/tc/endorsed
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Dcatalina.base=/hab/svc/tcat/var/tc
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Dcatalina.home=/hab/svc/tcat/var/tc
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.VersionLoggerListener log
tcat.default(O): INFO: Command line argument: -Djava.io.tmpdir=/hab/svc/tcat/var/tc/temp
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.coyote.AbstractProtocol init
tcat.default(O): INFO: Initializing ProtocolHandler ["http-bio-8080"]
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.coyote.AbstractProtocol init
tcat.default(O): INFO: Initializing ProtocolHandler ["ajp-bio-8009"]
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.Catalina load
tcat.default(O): INFO: Initialization processed in 519 ms
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.core.StandardService startInternal
tcat.default(O): INFO: Starting service Catalina
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.core.StandardEngine startInternal
tcat.default(O): INFO: Starting Servlet Engine: Apache Tomcat/7.0.73
tcat.default(O): Oct 23, 2017 7:59:48 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deploying web application directory /hab/svc/tcat/var/tc/webapps/examples
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deployment of web application directory /hab/svc/tcat/var/tc/webapps/examples has finished in 450 ms
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deploying web application directory /hab/svc/tcat/var/tc/webapps/docs
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deployment of web application directory /hab/svc/tcat/var/tc/webapps/docs has finished in 24 ms
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deploying web application directory /hab/svc/tcat/var/tc/webapps/host-manager
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deployment of web application directory /hab/svc/tcat/var/tc/webapps/host-manager has finished in 43 ms
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deploying web application directory /hab/svc/tcat/var/tc/webapps/manager
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deployment of web application directory /hab/svc/tcat/var/tc/webapps/manager has finished in 30 ms
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deploying web application directory /hab/svc/tcat/var/tc/webapps/ROOT
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.HostConfig deployDirectory
tcat.default(O): INFO: Deployment of web application directory /hab/svc/tcat/var/tc/webapps/ROOT has finished in 23 ms
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.coyote.AbstractProtocol start
tcat.default(O): INFO: Starting ProtocolHandler ["http-bio-8080"]
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.coyote.AbstractProtocol start
tcat.default(O): INFO: Starting ProtocolHandler ["ajp-bio-8009"]
tcat.default(O): Oct 23, 2017 7:59:49 PM org.apache.catalina.startup.Catalina start
tcat.default(O): INFO: Server startup in 634 ms
hab-sup(MR): Starting franklinwebber/apache-mod-jk
tcat.default(HK): Hooks compiled
apache-mod-jk.default(HK): init, compiled to /hab/svc/apache-mod-jk/hooks/init
apache-mod-jk.default(HK): reload, compiled to /hab/svc/apache-mod-jk/hooks/reload
apache-mod-jk.default(HK): reconfigure, compiled to /hab/svc/apache-mod-jk/hooks/reconfigure
apache-mod-jk.default(HK): Hooks compiled
apache-mod-jk.default(SR): Hooks recompiled
default(CF): Updated workers.properties fb8f91bb1ddcbb9590a832e77040aa251d47a896e5c7adc0d9bc03e04887640c
default(CF): Updated httpd.conf 37f4cb6e31ca3efd72e9875c3f1dc37ce85e7fd9a5c41a2b7e2c71b5a6bbb2c4
apache-mod-jk.default(SR): Configuration recompiled
apache-mod-jk.default(SR): Initializing
apache-mod-jk.default(SV): Starting service as user=root, group=root
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.902281 2017] [jk:warn] [pid 2053] No JkLogFile defined in httpd.conf. Using default /hab/pkgs/core/httpd/2.4.27/20171015104412/logs/mod_jk.log
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.902450 2017] [jk:warn] [pid 2053] No JkShmFile defined in httpd.conf. Using default /hab/pkgs/core/httpd/2.4.27/20171015104412/logs/jk-runtime-status
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.957743 2017] [ssl:warn] [pid 2053] AH01873: Init: Session Cache is not configured [hint: SSLSessionCache]
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.957814 2017] [jk:warn] [pid 2053] No JkLogFile defined in httpd.conf. Using default /hab/pkgs/core/httpd/2.4.27/20171015104412/logs/mod_jk.log
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.957939 2017] [jk:warn] [pid 2053] No JkShmFile defined in httpd.conf. Using default /hab/pkgs/core/httpd/2.4.27/20171015104412/logs/jk-runtime-status
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.961803 2017] [mpm_prefork:notice] [pid 2053] AH00163: Apache/2.4.27 (Unix) OpenSSL/1.0.2l mod_jk/1.2.42 configured -- resuming normal operations
apache-mod-jk.default(O): [Mon Oct 23 20:00:12.961901 2017] [core:notice] [pid 2053] AH00094: Command line: 'httpd -D FOREGROUND -f /hab/svc/apache-mod-jk/config/httpd.conf'
```

There are some errors/warnings but it still ran and tomcat was available.

Running `curl localhost:8080`.

Running `curl localhost`.

```
tcat.default(O): Oct 23, 2017 8:00:27 PM org.apache.coyote.http11.AbstractHttp11Processor process
tcat.default(O): INFO: Error parsing HTTP request header
tcat.default(O):  Note: further occurrences of HTTP header parsing errors will be logged at DEBUG level.
tcat.default(O): java.lang.IllegalArgumentException: Invalid character found in method name. HTTP method names must be tokens
tcat.default(O): 	at org.apache.coyote.http11.InternalInputBuffer.parseRequestLine(InternalInputBuffer.java:136)
tcat.default(O): 	at org.apache.coyote.http11.AbstractHttp11Processor.process(AbstractHttp11Processor.java:1000)
tcat.default(O): 	at org.apache.coyote.AbstractProtocol$AbstractConnectionHandler.process(AbstractProtocol.java:637)
tcat.default(O): 	at org.apache.tomcat.util.net.JIoEndpoint$SocketProcessor.run(JIoEndpoint.java:316)
tcat.default(O): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
tcat.default(O): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
tcat.default(O): 	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)
tcat.default(O): 	at java.lang.Thread.run(Thread.java:748)
tcat.default(O):
apache-mod-jk.default(O): 127.0.0.1 - - [23/Oct/2017:20:00:27 +0000] "GET / HTTP/1.1" 502 232
```
