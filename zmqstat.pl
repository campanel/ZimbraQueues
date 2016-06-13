#!/usr/bin/perl
#Author:
#        cleber.campanel@interop.com.br)
use strict;
use Getopt::Long;
use POSIX;
use File::Basename;
use Data::Dumper;
# Global variables
our $name = basename($0, ".pl");
our ($oHelp, $oVerbose, $oWarn, $oCrit, $oQueue);
#--------------------------------------------------------------------------------------
sub main {
        getoption();

        my @output = `sudo /opt/zimbra/libexec/zmqstat 2>&1`;
        chomp @output;
        #print Dumper @output;
        #print Dumper $?;
        if($? != 0 ){
                quit("ERROR: ".@output[0], 3);
        }


        my $value;
        foreach my $line (@output){
                #print "$line\n";
                my @words = split /=/, $line;
                 #print Dumper  @words[1];
                if(@words[0] eq $oQueue){
                        $value = @words[1];
                }
        }
        #print Dumper  $value;

        my $msg ="Queue $oQueue: $value";
        my $exit_code = 3;


        if($oWarn && $oWarn){
                $exit_code = metric($value);


        }else{
                $exit_code = 0;
        }
        my $perf = " | '".$oQueue."'=".$value.";".$oWarn.";".$oCrit.";0;";

        quit( $msg.$perf, $exit_code);

}
#--------------------------------------------------------------------------------------
sub metric {
        my $value = shift;
        if ($value >= $oCrit) { return 2
        }elsif ($value >= $oWarn) { return 1
        }elsif ($value < $oWarn) { return 0
        }else{ quit("Unable to check.",3) }
}
#--------------------------------------------------------------------------------------
sub quit {
        my $mgs = shift;
        my $code = shift;
        print $mgs,"\n";
        exit($code);
}
#--------------------------------------------------------------------------------------
sub getoption  {
        Getopt::Long::Configure('bundling');
        GetOptions(
                'c|critical=i' => \$oCrit,
                'h|help' => \$oHelp,
                'v|verbose=i' => \$oVerbose,
                'w|warning=i' => \$oWarn,
                'q|queue=s' => \$oQueue,
        );
        if($oHelp){
                printUsage();
                exit(3);
        }
        if (!$oQueue){
                printUsage();
                exit(3);
        }
        my @array = qw/hold corrupt deferred active incoming/;
        if(!grep $_ eq $oQueue, @array)
        {
                printUsage();
                exit(3);
        }
}
#--------------------------------------------------------------------------------------
sub printUsage {
       print <<EOB
Usage: $name.pl [OPTION]...

-c, --critical
-h, --help
-w, --warning
-v, --verbose
-q, --queue [hold|corrupt|deferred|active|incoming]

Grant permission to the nagios user:
\t nagios ALL=(zimbra) NOPASSWD:/opt/zimbra/bin/zmcontrol

EOB
}
#--------------------------------------------------------------------------------------
&main;
