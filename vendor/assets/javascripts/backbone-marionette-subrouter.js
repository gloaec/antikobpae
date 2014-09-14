// This is heavily based on Backbone.SubRoute 
// (https://github.com/ModelN/backbone.subroute) by Dave Cadwallader


(function (factory) {
    if (typeof define === 'function' && define.amd) {
        define(['underscore', 'backbone', 'marionette'], factory);
    } else {
        factory(_, Backbone, Marionette);
    }
}(function(_, Backbone) {
    Marionette.SubRouter = Marionette.AppRouter.extend({
        constructor: function(options) {
 
            var routes = {};
 
            // Prefix is optional, set to empty string if not passed
            if(this.prefix === undefined){
                this.prefix = prefix = options.prefix || "";
            } else {
                 prefix = this.prefix;
            }
 
            // SubRoute instances may be instantiated using a prefix with or without a trailing slash.
            // If the prefix does *not* have a trailing slash, we need to insert a slash as a separator
            // between the prefix and the sub-route path for each route that we register with Backbone.
            this.separator = (prefix.slice(-1) === "/")
                            ? ""
                            : "/";
 
            // If you want to match "books" and "books/" without creating separate routes, set this
            // option to "true" and the sub-router will automatically create those routes for you.
            var createTrailingSlashRoutes = options && options.createTrailingSlashRoutes;
 
            if (this.appRoutes) {
 
                if (options && options.controller) {
                    this.controller = options.controller;
                }
 
                _.each(this.appRoutes, function(callback, path) {
                    if (path) {
                        // Strip off any leading slashes in the sub-route path,
                        // since we already handle inserting them when needed.
                        if (path.substr(0) === "/") {
                            path = path.substr(1, path.length);
                        }
 
                        routes[prefix + this.separator + path] = callback;
 
                        if (createTrailingSlashRoutes) {
                            routes[prefix + this.separator + path + "/"] = callback;
                        }
                    } else {
                        // Default routes (those with a path equal to the empty string)
                        // are simply registered using the prefix as the route path.
                        routes[prefix] = callback;
 
                        if (createTrailingSlashRoutes) {
                            routes[prefix + "/"] = callback;
                        }
                    }
                }, this);
 
                // Override the local sub-routes with the fully-qualified routes that we just set up.
                this.appRoutes = routes;
            }
 
            Marionette.AppRouter.prototype.constructor.call(this, options);

            // grab the full URL
            var hash;
            if (Backbone.history.fragment) {
                hash = Backbone.history.getFragment();
            } else {
                hash = Backbone.history.getHash();
            }

            _.every(this.appRoutes, function(key, route){
                if (hash.match(Backbone.Router.prototype._routeToRegExp(route))) {
                    Backbone.history.loadUrl(hash);
                    return false;
                }
                return true;
            }, this);
        }
    });
 
    return Marionette.SubRouter;
}));
