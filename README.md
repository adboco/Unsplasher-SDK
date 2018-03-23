# UNSPLASHER SDK
![build](https://img.shields.io/badge/build-passing-green.svg) ![platform](https://img.shields.io/badge/platform-iOS%209.0%2B-lightgrey.svg) ![platform](https://img.shields.io/badge/xcode-9.0%2B-lightgrey.svg) ![swift version](https://img.shields.io/badge/swift-4.0-orange.svg) ![cocoapods](https://img.shields.io/badge/pod-v1.0.2-blue.svg)

An Unsplash API client written in Swift. It supports user authentication, likes, manage collections and every feature of the [official API](https://unsplash.com/documentation).

## Requirements
* Platform: iOS 9.0+
* Xcode 9.0+
* Dependencies:
	- [Alamofire](https://github.com/Alamofire/Alamofire)
	- [SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper)

## Installation
Using [CocoaPods](https://cocoapods.org):
```ruby
pod "UnsplasherSDK"
```

## Usage
```swift
import UnsplasherSDK
```

First thing you need is to configure the Unsplash instance with your credentials and scopes. Do it, for example, in your AppDelegate:
```swift
// Setup application ID and Secret
Unsplash.configure(appId: "{YOUR_APPLICATION_ID}", secret: "{YOUR_SECRET}", scopes: Unsplash.PermissionScope.all) // All scopes
// or
Unsplash.configure(appId: "{YOUR_APPLICATION_ID}", secret: "{YOUR_SECRET}", scopes: [.readUser, .writeLikes, ...]) // Specific scopes
```

### Authentication
To authenticate the user, you need to call ``authenticate`` method when your View Controller has been presented, because it'll show a modal View Controller where the user can login in his/her account:
```swift
Unsplash.shared.authenticate(self) { result in
	switch result {
	case .success:
		getUser()
		getPhotos()
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}
```

> _Note:_ Make sure your Authorization callback URL is set to ``unsplash-{YOUR_APPLICATION_ID}://token``.

### Current User
```swift
let currentUserClient = Unsplash.shared.currentUser

// Get user's profile
currentUserClient.profile(completion: { result in
	switch result {
	case .success(let user):
		print("Name: \(user.name)")
		print("Followers: \(user.followersCount)")
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Update user's profile
user.bio = "Photography lover since 1998"
currentUserClient.update(user) { result in 
	switch result {
	case .success(let user):
		print("User's profile updated.")
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}
```

### Users
```swift
let usersClient = Unsplash.shared.users

// Get user by nickname
usersClient.user("ari_spada") { result in 
	switch result {
	case .success(let user):
		print("User found: \(user.name)")
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Get user's portfolio url
usersClient.portfolio(by: user.username) { result in 
	switch result {
	case .success(let link):
		print("Portfolio url: \(link.url?.absoluteString)")
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Get user's photos
usersClient.photos.by(user.username, page: 3, perPage: 5, orderBy: .latest) { result in 
	switch result {
	case .success(let photos):
		for photo in photos {
			print("\(photo.id), Likes: \(photo.likes)")
		}
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Photos liked by user
usersClient.photos.liked(by: user.username) { result in /* handle the result */ }

// Get user's collections
usersClient.collections.by(user.username) { result in /* handle the result */ }
```

### Photos
```swift
let photosClient = Unsplash.shared.photos

// Get photos
photosClient.photos(page: 1, perPage: 10, orderBy: .popular, curated: true) { result in 
	switch result {
	case .success(let photos):
		for photo in photos {
			print("\(photo.id), Full photo url: \(photo.urls?.full.absoluteString)")
		}
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Get photo by id
photosClient.photo(id: photo.id, width: 1200, height: 800) { result in /* handle the result */ }

// Update photo
photo.location.country = "Spain"
photo.location.city = "Valencia"
photosClient.update(photo) { result in /* handle the result */ }

// Like and unlike a photo
photosClient.like(id: photo.id) { result in /* handle the result */ }

photosClient.unlike(id: photo.id) { result in /* handle the result */ }

// Get a list of random photos
photosClient.randomPhotos(query: "city", orientation: .landscape, count: 20) { result in /* handle the result */ }
photosClient.randomPhotos(collectionIds: [176316]) { result in /*handle the result */ }

// Get a random photo
photosClient.randomPhoto(featured: true, query: "forest", username: "henry") { result in /* handle the result */ }

// Get download link
photosClient.downloadLink(id: photo.id) { result in /* handle the result */ }
```

### Collections
```swift
let collectionsClient = Unsplash.shared.collections

// Get a list of collections
collectionsClient.collections(list: .featured, page: 1, perPage: 10) { result in 
	switch result {
	case .success(let collections):
		for collection in collections {
			print("\(collection.title), Total photos: \(collection.totalPhotos)")
		}
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Get collection by id
collectionsClient.collection(id: collection.id) { result in /* handle the result */ }

// Get collection's photos
collectionsClient.photos(in: collection.id, page: 2, perPage: 8) { result in /* handle the result */ }

// Get a list of collections related with a given one
collectionsClient.collections(relatedWith: collection.id) { result in /* handle the result */ }

// Create a new collection
collectionsClient.create(title: "My collection", description: "Amazing landscape photos!", isPrivate: false) { result in /* handle the result */ }

// Update collection
collection.title = "New title"
collection.isPrivate = true
collectionsClient.update(collection) { result in /* handle the result */ }

// Deleta a collection
collectionsClient.delete(id: collection.id) { result in /* handle the result */ }

// Add a photo to a collection
collectionsClient.add(photoId: "3794hdjks", to: collection.id) { result in /* handle the result */ }

// Remove a photo from a collection
collectionsClient.remove(photoId: "3975yjksd", from: collection.id) { result in /* handle the result */ }
```

### Search
```swift
let searchClient = Unsplash.shared.search

// Search users
searchClient.users(query: "tom", page: 1, perPage: 10) { result in
	switch result {
	case .success(let search):
		for user in search.users {
			print("\(user.username)")
		}
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Search photos
searchClient.photos(query: "landscape", page: 3, perPage: 20, orientation: .portrait) { result in
	let photos = result.value?.photos
}

// Search collections
searchClient.collections(query: "urban", page: 2, perPage: 25) { result in
	let collections = result.value?.collections
}
```

### Pagination
There is a simple way to iterate over pages if you use a paginated request. Here's an example:
```swift
// Get next page of the current request
photosClient.next { result in 
	switch result {
	case .success(let photos):
		for collection in collections {
			print("\(collection.title), Total photos: \(collection.totalPhotos)")
		}
	case .failure(let error):
		print("Error: " + error.localizedDescription)
	}
}

// Previous page
photosClient.prev { result in /* handle the result */ }

// Last page
photosClient.last { result in /* handle the result */ }

// First page
photosClient.first { result in /* handle the result */ }

// Also available in users, collections and search
Unsplash.shared.users.photos.{next,prev,last,first}
Unsplash.shared.users.collections.{next,prev,last,first}
Unsplash.shared.collections.{next,prev,last,first}
Unsplash.shared.search.{next,prev,last,first}
```

This methods will return error if the requested page is not available or the last request made doesn't match with the new expected response type:
```swift
Unsplash.shared.photos.randomPhotos { result in /* ... */ }

Unsplash.shared.photos.next { result in /* Success */ }

/* 
 * Returns error because the previous request returns an array of Photo
 * and the new request expects an array of Collection
 */
Unsplash.shared.collections.next { result in /* Failure */ }
```

## About
This project is funded and maintained by [adboco](https://github.com/adboco). It's a contribution to open source software! 🔶

## License
Unsplasher SDK is available under MIT license. See the LICENSE file for more information.