#!/usr/bin/perl
use Socket;
use POSIX ":sys_wait_h";

use Data::Dumper;

use threads;
use threads::shared;

use strict;
use warnings;

require "./weather.pl";
require "./sqliteinteractions.pl";


#handle some signals
$SIG{INT} = sub { cleanup(); die "Received Interrupt. Exiting...\n"};
$SIG{KILL} = sub {cleanup(); die "Received kill signal. Exiting...\n"};
$SIG{TERM} = sub {cleanup(); die "Received term signal. Exiting...\n"};
local $SIG{CHLD} = "IGNORE";

sub logtime {
	my $format = "%F %T";
	return strftime($format, gmtime())." ";
}

sub printlog {
	my ($message,$time) = @_;
	my $restore = select();
	select(STDOUT);
	if(defined($time)) {
		print($time."\t$message\n");
	} else {
		
		print(logtime()."\t$message\n");
	}
	select($restore);
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
	my $dbh = db_connect();
	my %weather;
	if(check_for_record($zip_code, $dbh) == 1) {
		%weather = get_weatherdata($zip_code, $dbh);
		print("From cache\n");
	} else {
		%weather = extractWeatherData($zip_code);
		add_weatherdata($dbh,%weather);
		select(STDOUT);
		printlog("Added $zip_code to weather cache");
		select(TMP_SOCKET);
	}
	$zip_code = printWeatherData(%weather);
	TMP_SOCKET->flush();
	$dbh->disconnect();
	select(STDOUT);
	return ($zip_code);
}

sub cleanup {
	my ($s) = @_;
	if(defined($s)) {
		close($s);
	}
}

sub start_server {
	my $server_ip = "127.0.0.1";
	my $server_port = 5555;
	my $socket;
	printlog("Starting weather server on address $server_ip:$server_port");

	socket($socket,2,1,6);

	bind($socket, pack_sockaddr_in($server_port, inet_aton($server_ip)))
		or die "ERROR: Can not bind to address $server_ip\n";

	listen($socket, 10);
	my $client;
	my $pid;
	my $z;
	my $time;
	my $cw;

	while($client = accept(TMP_SOCKET, $socket)) {
		$pid = fork();
		if(!defined($pid)) {
			die "Error: unable to fork";
		} 
		elsif ($pid == 0) {
			$time = logtime();
			$z = respond_to_request();
			close(TMP_SOCKET);
			my ($client_port, $client_ip) = unpack_sockaddr_in($client);
			$client_ip = inet_ntoa($client_ip);
			printlog("$client_ip:$client_port\t$z",$time);
			exit();
		} 
		else {
			waitpid($pid, WNOHANG);
			close(TMP_SOCKET);
		}
	}
}

sub main {
	my $pid = fork();
	if($pid == 0) {
		my $r;
		while(1) {
			$r = remove_old_records();
			printlog("Removed $r old records");
			sleep(60);
		}
	} else {
		start_server();
	}
}

main;
