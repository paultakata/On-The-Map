# On-The-Map
Project 3 of my Udacity iOS Nanodegree course work.

This app is to demonstrate my newfound knowledge of networking clients and MapKit.
It also reinforces the UIKit skills gained in previous modules.

I found this project difficult. This was the first time I had to do anything
related to remote networking and HTTP calls, so the learning curve was steep.
Nevertheless, with the example app as a guide, Google at my fingertips and some 
choice comments from my reviewer I eventually finished the app to specification.

The most challenging parts for me were twofold: creating a networking client
from scratch, and learning about custom delegate protocols.

To write the networking client I had to learn about HTTP methods, completion
handlers, value capture and passing, threads and GCD, networking errors, timing
issues, JSON parsing and probably other things as well. Pretty much everything
then! I followed the example given and tried to compartmentalise the code as
much as possible, and make it as reusable and expandable as possible. The
client contains generic methods for many HTTP calls like GET and POST, and
convenience methods for specific purposes within the app.

We were tasked with communicating primarily with two servers: Udacity and
Parse. They each have their own requirements and quirks so I used an enum to
differentiate between them in the convenience methods. This let me reuse much
of the code for both servers, and allows for easy extension of the client to
cover other servers in future.

I wasn't intending to write a custom delegate for this project, mainly
because I didn't know how to, but I kept getting annoyed by what should have
been a simple thing to do: refresh the map or table view after the user posts
their data. I just couldn't figure out why it wouldn't refresh no matter
what I tried!

So I read up on delegates and how to write them, creating a simple one that
let me call a refresh method in the parent view controller from the posting
view controller. Ha! Take that, small yet irritating problem!

I also integrated the Facebook framework into this app to demonstrate the
"Login With Facebook" authentication method. This gave the user the option
to authenticate themselves either using their Udacity credentials or their
Facebook identity.