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

#get location and pretty print some info
sub printWeatherData {
	my ($zip_code) = @_;
	my $weatherjsonarray = fetch_weather_data($zip_code);
	my $weatherjson;
	if($weatherjsonarray) {
		$weatherjson = @$weatherjsonarray[0];
	} else {
		print("ERROR: $zip_code is not a valid US zip code\n");
		return;
	}
	#print out more specific location info
	my $location = %$weatherjson{'location'};
	my $currentweather = %$weatherjson{'currentConditions'};
	
	print("Weather for $location->{'city'}, $location->{'stateOrCountry'}");
	print(" from source $currentweather->{'observationStation'} on ");
	print(formatGMTimeLong($currentweather->{'lastUpdated'}{time})."\n");
	
	print("\tTemperature: $currentweather->{'temperature'}°F");
	  print(" (feels like $currentweather->{'feelsLikeTemperature_S'}°F)\n");
	print("\tDew Point:   $currentweather->{'dewPoint'}°F\n");
	print("\tWind:        $currentweather->{'wind'}\n");
	print("\tPressure:    $currentweather->{'barometricPressure'} inMg\n");
	print("\tVisibility:  $currentweather->{'visibility'} miles\n");
	print("\tHumidty:     $currentweather->{'humidity_S'}%\n");
	print("\tDescription: $currentweather->{'shortDescription'}\n");
	print("\tSunrise:     ".formatGMTime($currentweather->{'sunriseTime'}{time})."\n");
	print("\tSunset:      ".formatGMTime($currentweather->{'sunsetTime'}{time})."\n");
}
