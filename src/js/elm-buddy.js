/*
Elm ports
*/

(function(scope) {
    
    var storage = function() {
        
        var key = "patchbae";

        // Load cached UserData (uid and patches) or empty data
        var load = function() {

            var out = {uid:null, patches:[]};

            try {
                var cached = JSON.parse(localStorage.getItem(key));
                if (cached != null) {
                    out = cached;
                }
            }
            catch (err) {}

            return out;
        };

        // Attempt to load remote table for user credentials
        var authenticate = function ([uid, password]) {
            
            AWS.config.update({
                region: "us-west-1",
                accessKeyId: "AKIARMA57WRKW54DBSY3", // TODO: how to not have this in code?
                secretAccessKey: password
            });

            var params = {
                TableName: "Patchbae",
                Key: {"UID": uid}
            };

            var docClient = new AWS.DynamoDB.DocumentClient();

            docClient.get(params, function(err, data) {
                if (err || data.Item == undefined) {
                    console.log("Error authenticating:");
                    console.log(JSON.stringify(err, undefined, 2));
                    
                    app.ports.handle_authentication.send("");
                } else {
                    var userData = {uid: data.Item.UID, patches:data.Item.Patches};
                    var res = JSON.stringify(userData);
                    app.ports.handle_authentication.send(res);
                }
            });
        };
        
        // Save UserData in local storage and remotely if user is logged in
        var save = function (dat) {
                
            localStorage.setItem(key, JSON.stringify(dat));

            if (dat.uid != undefined && dat.uid != "anonymous") {

                // TODO
            }
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
        flags: _.extend(storage().load(), {
            size: {
                width: window.innerWidth,
                height: window.innerHeight
            }
        })
    });

    app.ports.authenticate.subscribe(storage().authenticate)
    app.ports.save.subscribe(storage().save);
})(this);