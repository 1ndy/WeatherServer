
use DBI;

use strict;
use warnings;

#create the database
sub create_table {
my $dbh = shift;
my $sqlcmd = qq(CREATE TABLE currentweather(ZIP CHAR(5) PRIMARY KEY NOT NULL, LOCATION CHAR(50) NOT NULL,SOURCE CHAR(10) NOT NULL,TIME INT NOT NULL,TEMPERATURE CHAR(5),FEELSLIKETEMPERATURE CHAR(5),DEWPOINT CHAR(5),WIND CHAR(15),PRESSURE CHAR(10),VISIBILITY CHAR(10),HUMIDITY CHAR(5),DESCRIPTION CHAR(20),SUNRISE INT,SUNSET INT););
$dbh->do($sqlcmd);
}

sub add_weatherdata {
	my ($dbh,%weatherdata) = @_;
	my $types = "ZIP,LOCATION,SOURCE,TIME,TEMPERATURE,FEELSLIKETEMPERATURE,DEWPOINT,WIND,PRESSURE,VISIBILITY,HUMIDITY,DESCRIPTION,SUNRISE,SUNSET";
	
	my $values = qq('$weatherdata{'zip_code'}', '$weatherdata{'location'}', '$weatherdata{'source'}', $weatherdata{'time'}, '$weatherdata{'temperature'}', '$weatherdata{'feelsLikeTemperature'}', '$weatherdata{'dewPoint'}', '$weatherdata{'wind'}', '$weatherdata{'pressure'}', '$weatherdata{'visibility'}', '$weatherdata{'humidity'}', '$weatherdata{'description'}', $weatherdata{'sunrise'}, $weatherdata{'sunset'});
	my $sqlcmd = "INSERT INTO currentweather ($types) VALUES ($values)";
	$dbh->do($sqlcmd) or die $DBI::errstr;
}

sub db_connect {
	my $driver = "SQLite";
	my $database = "weathercache.db";
	my $dsn = "DBI:$driver:database=$database";
	my $dbh = DBI->connect($dsn,"","",{RaiseError => 1}) or die $DBI::errstr;
	return $dbh;
}

1;
