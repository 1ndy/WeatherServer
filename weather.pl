use JSON::XS;
use Data::Dumper;
use POSIX qw(strftime);

require HTTP::Request;
require LWP::UserAgent;

#make a request to CNN's weather API
sub fetch_weather_data {
	my ($location) = @_;
	my $request = HTTP::Request->new(GET => "https://data.api.cnn.io/weather/getForecast/json/$location/true");
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request($request);
	my $data = $response->decoded_content();
	#print(Dumper $data."\n");
	if(length($data) < 10) {
		return;
	}
	my $json = decode_json($data) or die "$location is not a valid zip code";
	
	if(!defined($json) || $json != "" || !defined($json->{'Error'})) {
		return $json;
	} else {
		return;
	}
}

#format time good
sub formatGMTimeLong {
	my ($unixtime) = @_;
	my $timeformat = "%a %h %d %Y %H:%M:%S GMT";
	return strftime($timeformat, gmtime(substr($unixtime, 0, -3)));
}

sub formatLocalTimeLong {
	my ($unixtime) = @_;
	my $timeformat = "%c";
	return strftime($timeformat, localtime(substr($unixtime, 0, -3)));
}

sub formatGMTime {
	my ($unixtime) = @_;
	my $timeformat = "%X %Z";
	return strftime($timeformat, gmtime(substr($unixtime, 0, -3)));
}

sub formatLocalTime {
	my ($unixtime) = @_;
	my $timeformat = "%X %Z";
	return strftime($timeformat, localtime(substr($unixtime, 0, -3)));
}

sub validateZipCode {
	my ($zip) = @_;

	if(substr($zipi,0,1) == 0) {
		$zip = substr($zip, 1);
	}

	if($zip < 1001) {
		return "";
	} elsif($zip >= 99501 && $zip <= 99950) {
		return "AK";
	} elsif($zip >= 35004 && $zip <= 36925) {
		return "AL";
	} elsif($zip >= 71601 && $zip <= 72959 || $zip == 75502) {
		return "AR";
	} elsif($zip >= 85001 && $zip <= 86556) {
		return "AZ";
	} elsif($zip >= 90001 && $zip <= 96162) {
		return "CA";
	} elsif($zip >= 80001 && $zip <= 81658) {
		return "CO";
	} elsif($zip >= 6001 && $zip <= 6389 || $zip >= 6401 && $zip <= 6928) {
		return "CT";
	} elsif($zip >= 20001 && $zip <= 20039 || $zip >= 200042 && $zip <= 20599 || $zip == 20799) {
		return "DC";
	} elsif($zip >= 19701 && $zip <= 19980) {
		return "DE";
	} elsif($zip >= 32004 && $zip <= 34997) {
		return "FL";
	} elsif($zip >= 30001 && $zip <= 31999 || $zip == 39901) {
		return "GA";
	} elsif($zip >= 96701 && $zip <= 96898) {
		return "HI";
	} elsif($zip >= 50001 && $zip <= 52809 || $zip >= 68119 && $zip <= 68120) {
		return "IA";
	} elsif($zip >= 83201 && $zip <= 83876) {
		return "ID";
	} elsif($zip >= 60001 && $zip <= 62999) {
		return "IL";
	} elsif($zip >= 46001 && $zip <= 47997) {
		return "IN";
	} elsif($zip >= 66002 && $zip <= 67954) {
		return "KS";
	} elsif($zip >= 40003 && $zip <= 42788) {
		return "KY";
	} elsif($zip >= 70001 && $zip <= 71232 || $zip >= 71234 && $zip <= 71497) {
		return "LA";
	} elsif($zip >= 1001 && $zip <= 2791 || $zip >= 5501 && $zip <= 5544) {
		return "MA";
	} elsif($zip == 20331 || $zip >= 20335 && $zip <= 20797 || $zip >= 20812 && $zip <= 21930) {
		return "MD";
	} elsif($zip >= 3901 && $zip <= 4992) {
		return "ME";
	} elsif($zip >= 48001 && $zip <= 49971) {
		return "MI";
	} elsif($zip >= 55001 && $zip <= 56763) {
		return "MN";
	} elsif($zip >= 63001 && $zip <= 65899) {
		return "MO";
	} elsif($zip >= 38601 && $zip <= 39776 || $zip == 71233) {
		return "MS";
	} elsif($zip >= 59001 && $zip <= 59937) {
		return "MT";
	} elsif($zip >= 27006 && $zip <= 28909) {
		return "NC";
	} elsif($zip >= 58001 && $zip <= 58856) {
		return "ND";
	} elsif($zip >= 68001 && $zip <= 68118 || $zip >= 68122 && $zip <= 69367) {
		return "NE";
	} elsif($zip >= 3031 && $zip <= 3897) {
		return "NH";
	} elsif($zip >= 7001 && $zip <= 8989) {
		return "NJ";
	} elsif($zip >= 87001 && $zip <= 88441) {
		return "NM";
	} elsif($zip >= 88901 && $zip <= 89883) {
		return "NV";
	} elsif($zip >= 10001 && $zip <= 14975 || $zip == 6390) {
		return "NY";
	} elsif($zip >= 43001 && $zip <= 45999) {
		return "OH";
	} elsif($zip >= 73001 && $zip <= 73199 || $zip >= 73401 && $zip <= 74966) {
		return "OK";
	} elsif($zip >= 97001 && $zip <= 97920) {
		return "OR";
	} elsif($zip >= 15001 && $zip <= 19640) {
		return "PA";
	} elsif($zip >= 2801 && $zip <= 2940) {
		return "RI";
	} elsif($zip >= 29001 && $zip <= 29948) {
		return "SC";
	} elsif($zip >= 57001 && $zip <= 57799) {
		return "SD";
	} elsif($zip >= 37010 && $zip <= 38589) {
		return "TN";
	} elsif($zip >= 75503 && $zip <=79999 || $zip >= 75001 && $zip <= 75501 || $zip >= 88510 && $zip <= 73301 || $zip == 73301) {
		return "TX";
	} elsif($zip >= 84001 && $zip <= 84784) {
		return "UT";
	} elsif($zip >= 20040 && $zip <= 20167 || $zip >= 22001 && $zip <= 24658) {
		return "VA";
	} elsif($zip >= 5001 && $zip <= 5495 || $zip >= 5601 && $zip <= 5907) {
		return "VT";
	} elsif($zip >= 98001 && $zip <= 99403) {
		return "WA";
	} elsif($zip >= 53001 && $zip <= 54990) {
		return "WI";
	} elsif($zip >= 24701 && $zip <= 26886) {
		return "WV";
	} elsif($zip >= 82001 && $zip <= 83128) {
		return "WY";
	} else {
		return "";
	}
	
}

sub sanitize_zip_code {
	my ($zip) = @_;
	print("zip before: $zip");
	chomp($zip);
	$zip = m/[0..9]/;
	$zip = $&;
	$zip = substr($zip,0,5);
	if(length($zip) < 5) {
		$zip = "0".$zip;
	}
	print("zip after: $zip");
}

#extract current forecast and pack into hash
sub extractWeatherData {
	my ($zip_code) = @_;
	my $weatherjsonarray = fetch_weather_data($zip_code);
	my $weatherjson;
	if($weatherjsonarray) {
		$weatherjson = @$weatherjsonarray[0];
	} else {
		print("ERROR: $zip_code is not a valid US zip code\n");
		return "<ERROR>.$zip_code";
	}
	#store weather data in depth 1 hash
	my $location = %$weatherjson{'location'};
	my $currentWeather = %$weatherjson{'currentConditions'};
	my %weatherdata;
	$weatherdata{'zip_code'} = $zip_code;
	$weatherdata{'location'} = "$location->{'city'},$location->{'stateOrCountry'}";
	$weatherdata{'source'} = "$currentWeather->{'observationStation'}";
	$weatherdata{'time'} = "$currentWeather->{'lastUpdate'}{time}";
	$weatherdata{'temperature'} = "$currentWeather->{'temperature'}°F";
	$weatherdata{'feelsLikeTemperature'} = "$currentWeather->{'feelsLikeTemperature'}°F";
	$weatherdata{'dewPoint'} = "$currentWeather->{'dewPoint'}°F";
	$weatherdata{'wind'} = "$currentWeather->{'wind'}";
	$weatherdata{'pressure'} = "$currentWeather->{'barometricPressure'} inMg";
	$weatherdata{'visibility'} = "$currentWeather->{'visibility'} miles";
	$weatherdata{'humidity'} = "$currentWeather->{'humidity_S'}%";
	$weatherdata{'description'} = "$currentWeather->{'shortDescription'}";
	$weatherdata{'sunrise'} = "$currentWeather->{'sunriseTime'}{time}";
	$weatherdata{'sunset'} = "$currentWeather->{'sunsetTime'}{time}";
	return %weatherdata;
}

#print out more specific location info
sub printWeatherData {
	my (%weatherdata) = @_;
	print("Weather for $weatherdata{'location'}");
	print(" from source $weatherdata->{'source'} on ");
	print(formatGMTimeLong($weatherdata{'time'})."\n");
	
	print("\tTemperature: $weatherdata{'temperature'}");
	  print(" (feels like $weatherdata{'feelsLikeTemperature'})\n");
	print("\tDew Point:   $weatherdata{'dewPoint'}\n");
	print("\tWind:        $weatherdata{'wind'}\n");
	print("\tPressure:    $weatherdata{'pressure'}\n");
	print("\tVisibility:  $weatherdata{'visibility'}\n");
	print("\tHumidty:     $weatherdata{'humidity'}\n");
	print("\tDescription: $weatherdata{'description'}\n");
	print("\tSunrise:     ".formatGMTime($weatherdata{'sunrise'})."\n");
	print("\tSunset:      ".formatGMTime($weatherdata{'sunset'})."\n");
	return $weatherdata{'zip_code'};

}

