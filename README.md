# SweetURL
Helpers and stuff for networking in Swift.

---

## URL Extensions

### `asRequest`

This Swift code provides an extension to URL that allows creating a URLRequest object from a given URL. 

The `asRequest` computed property returns a URLRequest object that is initialized with the URL, and the HTTP method set to GET.

#### Usage

```swift
// Create a URL
let url = URL(string: "https://example.com/api/data")!

// Create a URLRequest using the URL
let request = url.asRequest
```

### `asRequest(method:)`

The asRequest method can also take an additional HTTPMethod parameter to specify the HTTP method of the request. 

#### Usage

```swift
// Create a URLRequest using the URL and POST HTTP method
let request = url.asRequest(method: .post)
```

This extension can be useful when making API requests with URLSession. The returned URLRequest can be used to create a data task or upload task with the URLSession.

---

## URLRequest Extensions
This repository contains a collection of extensions for URLRequest in Swift, which provide some useful functionality for making HTTP requests.

### `asCurlCommand` 
The asCurlCommand extension adds a computed property to URLRequest that returns a string containing a curl command that can be used to reproduce the request. This can be useful for debugging or testing purposes.

### Usage
To use this extension, simply call the asCurlCommand property on a URLRequest object, like this:

```swift
let request = URLRequest(url: URL(string: "https://example.com/api/data")!)
let curlCommand = request.asCurlCommand

print(curlCommand ?? "Failed to generate curl command")
```

This will print the curl command for the request to the console, or a message indicating that the command could not be generated.

### `set(body:)` 
The set extension adds a method to URLRequest that allows you to set the body of the request to a Data object. This can be useful when you need to send a custom payload in the request body.

#### Usage
To use this extension, call the set method on a URLRequest object and pass in a Data object containing the request body, like this:

```swift
var request = URL(string: "https://example.com/api/data")!.asRequest

// Anything that can be turned in to `Data`.
struct User: Codable {
    let name: String
    let age: Int
}
let user = User(name: "John", age: 30)

let bodyData = try JSONEncoder().encode(user)

request = request.set(body: bodyData)
```

This will set the request body to the specified data.

## `HTTPMethod` Enumeration and `set(method:)` Extension

The HTTPMethod enumeration provides a set of HTTP methods that can be used when making requests. This can be useful for ensuring that your code is using the correct HTTP method for a given request.

#### Usage

To use this enumeration, simply call the set method on a URLRequest object and pass in the appropriate HTTPMethod value, like this:

```swift
var request = URL(string: "https://example.com/api/data")!
    .asRequest
    .set(method: .post)
```
This will set the HTTP method of the request to POST.

### Header Enumeration
The Header enumeration provides a set of HTTP header keys and values that can be used when setting headers on a request. This can be useful for ensuring that your code is using the correct header keys and values for a given request.

#### Usage
To use this enumeration, simply call the set method on a URLRequest object and pass in the appropriate Header.Key and Header.Value values, like this:

```swift
var request = URL(string: "https://example.com/api/data")!
    .asRequest
    .set(header: .contentType, value: .applicationJSON)
```

This will set the Content-Type header of the request to application/json. You can also use the set(header:value:) method to set custom header keys and values.
