#!/usr/bin/perl
use Socket;
use POSIX ":sys_wait_h";

use threads;
use threads::shared;

use strict;
use warnings;

require "./weather.pl";

#handle some signals
$SIG{INT} = sub { cleanup(); die "Received Interrupt. Exiting...\n";};
$SIG{KILL} = sub {cleanup(); die "Received kill signal. Exiting...\n"};
$SIG{TERM} = sub {cleanup(); die "Received term signal. Exiting...\n"};
local $SIG{CHLD} = "IGNORE";

sub logtime {
	my $format = "%F %T";
	return strftime($format, gmtime())." ";
}

sub respond_to_request {
	select(TMP_SOCKET);
	my $zip_code = <TMP_SOCKET>;
	if(!defined($zip_code)) {
		select(STDOUT);
		return "<ERROR>NULL";	
	}
	chomp($zip_code);
	$zip_code =~ /[1234567890]+/;
	if(length($zip_code) < 5) {
		print("ERROR: $zip_code is not a valid zip code\n");
		select(STDOUT);
		return "<ERROR>$zip_code";
	}
	$zip_code = substr($zip_code,0,5);
	my %weather = extractWeatherData($zip_code);
	$zip_code = printWeatherData(%weather);
	TMP_SOCKET->flush();
	select(STDOUT);
	return $zip_code;
}

sub cleanup {
	my ($s) = @_;
	if(defined($s)) {
		close($s);
	}
}

my $server_ip = "127.0.0.1";
my $server_port = 5555;
my $socket;


print(logtime()."Starting weather server on address $server_ip:$server_port\n");

socket($socket,2,1,6);

bind($socket, pack_sockaddr_in($server_port, inet_aton($server_ip)))
	or die "ERROR: Can not bind to address $server_ip\n";

listen($socket, 10);
my $client;
my $pid;
my $z;
my $time;
my $cw;
my %locationCache : shared;
while($client = accept(TMP_SOCKET, $socket)) {
	$pid = fork();
	if(!defined($pid)) {
		die "Error: unable to fork";
	} 
	elsif ($pid == 0) {
		$time = logtime();
		($z,$cw) = respond_to_request();
		close(TMP_SOCKET);
		my ($client_port, $client_ip) = unpack_sockaddr_in($client);
		$client_ip = inet_ntoa($client_ip);
		print("$time\t$client_ip:$client_port\t$z\n");
		if(!defined($locationCache{$z})) {
			$locationCache{$z} = $cw;
			print(logtime()."\tAdded $z to cache\n");
		}
		close(TMP_SOCKET);
		exit();
	} 
	else {
		waitpid($pid, WNOHANG);
		close(TMP_SOCKET);
	}
}

