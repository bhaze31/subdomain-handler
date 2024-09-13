# Subdomain Router
A Vapor class and middleware to handle subdomain specific routing.

This will allow developers to create Controllers that have a separation of concerns based on the subdomain you want them to handle. A use case may be that you have a specific admin section of your site while the remaining users visit the app section of your site. In addition, you host public pages at any other wildcard outside of those two. So your site map would look as such:

* admin.yoursite.io
* app.yoursite.io
* \*.yoursite.io

Now when initializing an application, you can create routers that will be only for that specific subdomain as such:
```
let adminSubdomain = try application.createSubdomain("admin")
let controller = SomeAdminController()

try controller.boot(routes: adminSubdomain.routes!)
```

Note that we force unwrapped here, as some nodes might not have routes on them, but when we create a new subdomain we are sure that it will have routes for the returned node.

Next, enable the middleware in the application after the routes have been loaded:

```
try app.middleware.register(SubdomainMiddleware())
```

This will take all of the nodes that have routes, create a TrieRouter for them, and register all the routes in the TrieRouter. Then, when making a call to the application, it will check if the subdomain exists in the SubdomainRouter, and if it does that it responds to the route in question. If it does, then the route is executed, otherwise the default application handler is passed.

### To be accomplished
- [ ] Command to print out all of the subdomains
- [ ] Easier insertion/retrieval from the app
- [ ] Prevent wildcards except at apex
- [ ] Limit the depth of subdomains
- [ ] Refactor to reduce models/complexity
- [ ] Document all functions
- [ ] Restrict access to internal features for simplicity
