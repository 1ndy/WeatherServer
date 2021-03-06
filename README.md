# WeatherServer
A client and server that gets you weather information in the terminal

## What is this thing here now?
I wanted to get perl and sockets so I wrote this set of programs. `weather.pl` is a library type class with functions for pretty printing time, fetching weather info, and printing weather info. The server uses this library to request weather information. Those requests are intitiated by the client program.

I'm very proud of it because I see it as a "proper" server i.e. it forks to handle each seperete request, interacts with a database, etc. I'd love to see a stress test done on it.

## Why didn't you just have the client program call the weather library stuff?
I don't have a good answer for that besides I wanted to learn about sockets (pay attention!). I'm gonna say it was because I wanted to build a caching server...yeah thats good.

Great question! I wanted this project to not take up a ton of API resources so by building an intermediate server I can cache requests and reduce internet traffic. Because, you know, tons of people are gonna use this one day.

## Speaking of API's, where do yo get your data from?
Heheheheh yeah about that...so somewhere on a site owned by CNN there lives a URL that gives you access to JSON weather data and forecasts for every zip code in America. I stumbled upon it a while ago an decided to do something with it. Not sure if it's supposed to be available for everyone to use, that's part of the reason there's a caching server in the mix.

## Caching server?
Yes! Well, no. Kind of. Initially I thought I could just store all the data I pulled down in a nested hash in memory, but that would be hard because I would have had to share the hash across multiple threads. So I let someone else deal with that problem by using a database, SQLite to be specific. I like SQLite because it keeps everything nice and compact, no server needed. As of right now, the server clears out records that are an average of 15 minutes old. This code actually makes a significant difference; cached lookups are way faster than API calls. That should be like a law or a theory or something.

## Zip code...how accurate is your weather data then?
Not that accurate, temporally or geographically. As far as I can tell, the weather data is from an airport in the zip code and it's not updated super often (every few hours I think). It's good enough for CNN's weather site, leave me alone.

## This code is a mess! You could have been so much more effcient!
Probably. I'm learning perl. I think I mentioned that.

## How do you send data between the client and server?
To quote a professor I once had: "Low-cal, low-fat plaintext". Wireshark it. _I dare you_.

## Does this conform to _XYZ_ standard?
Heck no!

## How do I do the thing with the stuff?
First you'll need to make a database file. There is a perl function written to do it. I'll leave it as an excercise to the reader make it work. Or you could do it manually, but get the columns right. Eventually I'll add some intelligence that can create the database if it doesn't exist.

Next, start up the weather server. Currently the listen address and port is hardcoded to `127.0.0.1:5555`. Change if you like.
```shell
$ perl server.pl
```
You should see some nice output about the server starting. Next, run the client:
```shell
$ perl client.pl <zip code>
```
Make sure you put a zip code as an argument. If theres some data for your location (i.e. your zip code is real), you'll get some nice data back. Otherwise, the server will complain A LOT but it won't crash I think.

Sample output for the best city:
```
Zipcode: 44101
Weather for Cleveland, OH from source KBKL on Sat Nov 17 2018 00:53:00 GMT
	Temperature: 40°F (feels like 29°F)
	Dew Point:   33°F
	Wind:        W 24 mph
	Pressure:    30.02 inMg
	Visibility:  9 miles
	Humidty:     77%
	Description: Cloudy
	Sunrise:     07:16:33 AM CST
	Sunset:      05:05:56 PM CST
```
