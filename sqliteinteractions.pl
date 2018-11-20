
use DBI;
use POSIX qw(strftime);

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
	print("Added $weatherdata{'time'}to db\n");
	$dbh->do($sqlcmd) or die $DBI::errstr;
}

sub check_for_record {
	my ($zip,$dbh) = @_;
	my $sqlcmd = "SELECT EXISTS(SELECT * FROM currentweather WHERE ZIP == '$zip')";
	my $sth = $dbh->prepare($sqlcmd);
	my $rv = $sth->execute();
	my @result = $sth->fetchrow_array();
	my $exist = $result[0];
	return $exist;
}

sub get_weatherdata {
	my ($zip,$dbh) = @_;
	my %weatherdata;
	my $sqlcmd = "SELECT * FROM currentweather WHERE ZIP == '$zip'";
	my $sth = $dbh->prepare($sqlcmd);
	my $rv = $sth->execute() or die $DBI::errstr;
	my @result = $sth->fetchrow_array();
	if(@result) {
		$weatherdata{'zip_code'} = $result[0];
		$weatherdata{'location'} = $result[1];
		$weatherdata{'source'} = $result[2];
		$weatherdata{'time'} = $result[3];
		$weatherdata{'temperature'} = $result[4];
		$weatherdata{'feelsLikeTemperature'} = $result[5];
		$weatherdata{'dewPoint'} = $result[6];
		$weatherdata{'wind'} = $result[7];
		$weatherdata{'presure'} = $result[8];
		$weatherdata{'visibility'} = $result[9];
		$weatherdata{'humidity'} = $result[10];
		$weatherdata{'description'} = $result[11];
		$weatherdata{'sunrise'} = $result[12];
		$weatherdata{'sunset'} = $result[13];
		return %weatherdata;
	}
}

sub remove_record {
	my ($zip,$dbh) = @_;
	my $sqlcmd = "DELETE FROM currentweather WHERE ZIP == $zip";
	my $sth = $dbh->prepare($sqlcmd);
	return $sth->execute();	
}

sub remove_old_records {
	my $dbh = db_connect();
	#this should get records removed after an average of 15 minutes
	my $expire_time = time() - (7.5 * 60);
	my $sqlcmd = "SELECT ZIP FROM currentweather WHERE TIME < $expire_time";
	my $sth = $dbh->prepare($sqlcmd);
	my $rv = $sth->execute();
	my @result = $sth->fetchrow_array();
	my $r = scalar(@result);
	foreach my $record (@result) {
		remove_record($record, $dbh);
	}
	return $r;
}

sub db_connect {
	my $driver = "SQLite";
	my $database = "weathercache.db";
	my $dsn = "DBI:$driver:database=$database";
	my $dbh = DBI->connect($dsn,"","",{RaiseError => 1}) or die $DBI::errstr;
	return $dbh;
}

1;
