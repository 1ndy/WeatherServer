use Socket;

use warnings;
use strict;

$SIG{INT} = sub {die "Exiting\n"};

my $server_ip = "127.0.0.1";
my $server_port = "5555";


socket(SOCKET,2,1,6) or die "Can not create socket\n";
connect(SOCKET, pack_sockaddr_in($server_port, inet_aton($server_ip))) 
	or die "Can't connect to server\n";

print("Zipcode: ");
my $zip = <stdin>;
chomp $zip;

$zip =~ m/[1234567890]+/; 
$zip = $&;

if(length($zip) < 5) {
	die "Invalid Zip Code\n";
}

$zip = substr($zip,0,5);

send(SOCKET,$zip."\n", 0);
#send(SOCKET,"\n", 0);

my $line;
while($line = <SOCKET>) {
	print("$line");
}

close(SOCKET) or die "close $!";

