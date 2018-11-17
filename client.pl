use Socket;

use warnings;
use strict;

require "./weather.pl";

$SIG{INT} = sub {die "Exiting\n"};

my $server_ip = "127.0.0.1";
my $server_port = "5555";


my $ARGC = @ARGV;

if($ARGC != 1) {
	die("Inlcude only ZIP code as argument");
}


my $zip = $ARGV[0];

#print("Zipcode: ");
#my $zip = <stdin>;
#chomp $zip;

$zip =~ m/[1234567890]+/; 
$zip = $&;

if(length($zip) < 5) {
	die "Invalid ZIP Code, (must have leading 0)\n";
} elsif(length($zip) > 5 ) {
	die "Invalid ZIP Code, must only have 5 numbers\n";
}

if(validateZipCode($zip) eq "") {
	die("Invalid US ZIP code\n");
}
socket(SOCKET,2,1,6) or die "Can not create socket\n";
connect(SOCKET, pack_sockaddr_in($server_port, inet_aton($server_ip))) 
	or die "Can't connect to server\n";

send(SOCKET,$zip."\n", 0);

my $line;
while($line = <SOCKET>) {
	print("$line");
}

close(SOCKET) or die "close $!";

