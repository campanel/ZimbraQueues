# Monitoring Zimbra Queues

Grant permission to the nagios user in visudo:

nagios ALL=(zimbra) NOPASSWD:/opt/zimbra/bin/zmcontrol


"# /usr/local/opmon/libexec/priax/zimbra/zmqstat.pl -q deferred -w 20 -c 25"

Queue deferred: 9 | 'deferred'=9;20;25;0;