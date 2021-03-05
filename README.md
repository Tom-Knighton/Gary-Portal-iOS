# Gary Portal - iOS v4.0


Gary Portal is a social media application that mimicks popular features from top iOS apps, as well as introducing fun unique features for Gary Portal members. 

# Version 4 update info:

  - Vast and significant codebase improvements
    - Strongly typed obects!
  - Move from Firebase RTDB access to calling hosted API
  - Staff Powers
  - SwiftUI
  - Dark mode support
  - Own chat system
 
# Features:
 - Profile signup / login
 - Queuing system
 - Staff / admin powers and app management
 - Profile view
 - 'Feed' including user-uploaded image and video posts, polls and short logs that exist for 24 hours
 - Chat system

### Dependencies

Gary Portal uses a number of open source projects to work properly:

* [TOCropViewController](https://github.com/TimOliver/TOCropViewController)
* [SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper)
* [Introspect](https://github.com/siteline/SwiftUI-Introspect)
* [ActionClosurable](https://github.com/takasek/ActionClosurable)
* [SwiftDate](https://github.com/malcommac/SwiftDate)
* [SignalRClient](https://github.com/moozzyk/SignalR-Client-Swift)

### Setup

Gary Portal comes with the required files and API client to run. The API is hosted at [https://api-dev.garyportal.tomk.online/api/](https://api-dev.garyportal.tomk.online/api/]) however the base urls used within the application can easily be swapped out for locally/externally hosted ones, from GaryPortal.swift -> GaryPortalConstants
The app relies on a JWT token from the API server to authenticate

### Development

Pull requests are welcome

License
----

MIT



