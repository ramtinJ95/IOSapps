#  ClimaApp

## Overview of the project

I followed the specification quite closely but did some modifications. One of the modifications is that when the application is started, the first view that meets the user shows the weather at their current location. This does not work on the simulator when running it in Xcode though, in Xcode it defaults to the standard CoreLocation which is at the apple campus. 

Another modification to the specifiation is that on the screen/view where one can see the three offices, there is a "searchbar" where one can enter any city in the world and press "get weather" and then get detailed information for that city aswell. Also all the maps in the app are interactive so one can move them around and take a look around the city. 

The last major modification I have made to the specification is that instead of adding recommendations I added images that show what the weather is like. I figured that most of us know what to do if we see a big sun as the image etc.

## Design and Components

For the design part of the code I did nothing too fancy, I simply followed the MVC (Model-View-Controller) structure since it makes the most sence to me in this case. For the code itself I used camelcase for my variable and function/method names and tried to write the code to be as self-documenting as possible since I personally don't really like my code to have too many comments. 

The main class, or rather the most important class in the project is the WeatherViewController.swift class. In This class I have all the network related code and also parse the JSON results in here as well. 

One thing that could be improved a bit is the UX of the project. For example if I had more time over I would have tried to add some constraints to the labels and buttons in the views so that they scale properly to many diffrent screen sizes. 

There is one thing in the plist file that may not seem intuitive so I will explain it here. The follwing XML code had to be added:

```XML
        <key>NSAppTransportSecurity</key>
        <dict>
            <key>NSExceptionDomains</key>
            <dict>
                <key>openweathermap.org</key>
                <dict>
                    <key>NSIncludesSubdomains</key>
                    <true/>
                    <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                    <true/>
                </dict>
            </dict>
        </dict>
```
This is because apple does not like their apps to use API:s that are not using HTTPS. But to use HTTPS when using openweathermap one has to pay money, so I performed this workaround after googling for a bit.

## How to run the project

To run the project please update your Xcode and your apple development tools to the latest version. Then unzip this file and double click the Clima.xcworkspace file to open it in Xcode. There run the app and make sure that it is built for the iPhone XR versions since that is the verison that I used in my testing. 

Once in the application press the double arrows to the top right in the first view to move to the screen/view where you can choose office location or query for any city in the world. In the second view there is also a back button that takes you back to the previous screen. 
