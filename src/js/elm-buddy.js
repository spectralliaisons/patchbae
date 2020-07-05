/*
Elm ports
*/

(function(scope) {
    
    var storage = function() {
        
        var key = "patchbae";

        // Load cached UserData (uid and patches) or empty data
        var load = function() {

            var out = {
                // authentication token
                token: null,
                // user data
                data: {uid:null, patches:[]}
            };

            try {
                var cached = JSON.parse(localStorage.getItem(key));
                if (cached != null) {
                    out = cached;
                }
            }
            catch (err) {}

            return out;
        };

        var implClient = function() { 
            return window.pbClient({
                loadCache: load,
                setCache: function(dat) {
                    localStorage.setItem(key, JSON.stringify(dat)); 
                }
            }); 
        }

        // Attempt to load remote table for user credentials
        var authenticate = function (credentials) {
            implClient().authenticate(credentials)
                .then (res => { 
                    app.ports.handle_authentication.send(JSON.stringify(res)); 
                });
        };
        
        // Save UserData in local storage and remotely if user is logged in
        var save = function (rawDat) {
            implClient().save(rawDat);
        };
        
        return {
            load : load,
            authenticate : authenticate,
            save : save
        };
    };

    // Initialize the Elm app with cached data and screen size
    var app = Elm.Main.init({
        node: document.getElementById('elm'),
        flags: _.extend(storage().load().data, {
            size: {
                width: window.innerWidth,
                height: window.innerHeight
            }
        })
    });

    app.ports.authenticate.subscribe(storage().authenticate)
    app.ports.save.subscribe(storage().save);
})(this);