

## About

This is an example iOS app that retrieves and displays a list of buckets using the [Contactually API](http://developers.contactually.com). When the user taps on a bucket, I display a list of contacts associated with that bucket.


## Known Issues

I use the API Key for authentication and allow the user to obtain the key via a Web View (copy/paste).
On the simulator this works well.  On a device I encountered some issues interacting with the Contactually web site:

  * Occasionally simply placing the cursor in the e-mail field in the popup dialog for login would submit the form 
and bring up the Forgot your password form.
  * Upon a successful login to the Contactually web site, it was sometimes difficult to select the API key for copying on the 
device.

As an alternative to manually getting the API Key from the web site, for testing purposes I allow the API key to be
hardcoded in EnterApiKeyController.m.    See NSString *const ApiKey = @"replace_with_your_api_key";  

I've included a button on the App login screen to use this value.



## Project Details

I've included additional details about the project in README.rtf (use of Core Data for caching, Authentication, etc).


