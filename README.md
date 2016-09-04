# Trackr

##Introduction

Location Manager application is a basic application that helps a user find his/her current location and also helps them to find nearby loaction with the help of search functionality.

###Features

1. Helps to find the current user location as soon as the applciation is opened.
2. Helps to find user desired nearby location with the help of a serach bar (This feature requires internet connection.)
3. On long click over the searched location annotation a button with a car option comes on clicking it a new sceen with the the specified route comes for routing.( This feature is not avaliable for Indian maps as apple does not support it)
4. The user location is updated every 100m he travels.
5. When the user reaches 100 m close to the desired location a alert pops stating that he is near the desired location.
6. At the bottom of the screen we have a distance tracker that tracks the total distance travelled from the current location to the searched location.

###Steps to Use

In order to use this application on simulator we need to follow the follwing steps

1. Go to xcode debug option -> simulate Location  -> select a location (Do this when the application is running)
2. For testing the free run go to simulator -> debug -> Location -> selct Free Way Drive.
3. Select a point using the serach controller somewhere in the free drive such that the distance is less than 100m .
4. ON reaching near that location a alert will come stating that you are near your destination and the location updates will stop
    untill you serach a new location.
