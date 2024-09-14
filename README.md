# Subdomain Router
A Vapor class and middleware to handle subdomain specific routing.

This will allow developers to create Controllers that have a separation of concerns based on the subdomain you want them to handle. A use case may be that you have a specific admin section of your site while the remaining users visit the app section of your site. In addition, you host public pages at any other wildcard outside of those two. So your site map would look as such:

* admin.yoursite.io
* app.yoursite.io
* \*.yoursite.io

Now when initializing an application, you can create routers that will be only for that specific subdomain as such:
```
try app.register(collection: AppController(), at: "app")
```

Where `app` would be the subdomain to your full domain like `app.coolapp.io`

Next, enable the middleware in the application after the routes have been loaded:

```
app.enableSubdomains()
```

This will take all of the nodes that have routes, create a TrieRouter for them, and register all the routes in the TrieRouter. Then, when making a call to the application, it will check if the subdomain exists in the SubdomainRouter, and if it does that it responds to the route in question. If it does, then the route is executed, otherwise the default application handler is passed.

## Future Plans
- [ ] Command to print out all of the subdomains
- [x] Easier insertion/retrieval from the app
- [x] Prevent wildcards except at apex
- [x] Limit the depth of subdomains
- [x] Refactor to reduce models/complexity
- [ ] Document all functions
- [ ] Restrict access to internal features for simplicity

## Configuring SubdomainHandler in your Vapor App

While this may sound pedantic, the first step is to make sure you have `SubomainHandler` added as a package in `Package.swift`:

```
dependencies: [
  ...
  .package(url: "https://github.com/bhaze31/subdomain-handler.git", from: "0.0.2"),
  ...
],
targets: [
  .executableTarget(
    name: "App",
    dependencies: [
      ...
      .product(name: "SubdomainHandler", package: "subdomain-handler"),
      ...
    ]
  )
]
```

Next, we need to actually register a `RouteCollection` at a specific subdomain. Lets say you have a domain `coolapp.io` for your app, and you want to have a web admin panel, but instead of having it reside at `coolapp.io/admin` you want it to be `admin.coolapp.io`. However you register your routes you can call:

```
try app.register(collection: AdminController(), at: "admin")
``` 

You can register multiple controllers at the same subdomain too if you segment code.

``` 
try app.register(collection: AdminController(), at: "admin")
try app.register(collection: Admin2Controller(), at: "admin")
```

Now that it is installed and routes are configured, we need to enable it to work in app. The default setup file for a Vapor application is `configure.swift`, but add this wherever you configure your instance of `Application`. Note that this step ___must___ be placed after you set up your routes, or it will not work. The reason being is that `SubdomainHandler` uses a `TrieRouter` under the hood for each subdomain, but we only register routes in the individual router when `enableSubdomains` is called. So if you add a `RouteCollection` after this is called that route will not resolve.

```
app.enableSubdomains()
```


