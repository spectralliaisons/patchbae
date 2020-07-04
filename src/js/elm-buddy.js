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

        var getCredentials = function () {

            var curr = load();
            var token = curr.token;

            // defined at ./src/js/priv/cognitoConfig.js
            var config = configureCognito();

            var loginDat = {};
            loginDat['cognito-idp.' + config.region + '.amazonaws.com/' + config.UserPoolId] = token;

            AWS.config.region = config.region;
            AWS.config.credentials = new AWS.CognitoIdentityCredentials({
                IdentityPoolId : config.IdentityPoolId, 
                Logins : loginDat
            });

            return AWS.config.credentials;
        }

        // Attempt to load remote table for user credentials
        var authenticate = function ([username, password]) {
            
            // defined at ./src/js/priv/cognitoConfig.js
            var config = configureCognito();
            
            var sendError = function(err) {
                
                console.log("Error authenticating:");
                console.log(JSON.stringify(err, undefined, 2));
                            
                app.ports.handle_authentication.send("");
            }
            
            var userPool = new AmazonCognitoIdentity.CognitoUserPool(config);
            let authenticationData = { Username: username, Password: password };
            let authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
            let userData = { Username: username, Pool: userPool };
            let cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

            cognitoUser.authenticateUser(authenticationDetails, {
                onSuccess: function (result) {
                    
                    var authToken = result.getIdToken().getJwtToken();

                    // remember this authentication token
                    var curr = load();
                    curr.token = authToken;
                    localStorage.setItem(key, JSON.stringify(curr));

                    getCredentials().get(function(err) {
                        if (!err) {
                            var uid = AWS.config.credentials.identityId;
                            console.log('Cognito Identity ID '+ uid);

                            // Load the DynamoDB data for this user
                            var params = {
                                TableName: configureCognito().TableName,
                                Key: {"UID": uid}
                            };

                            var docClient = new AWS.DynamoDB.DocumentClient({region: config.region});
                            docClient.get(params, function(err, data) {
                                if (err || !data || data.Item == undefined) {
                                    
                                    // Initialize a data table for this user
                                    var res = {uid:uid, patches:[]};

                                    // use this instead to use my real patches for a user with no data
                                    // var res = _.extend(pb_demo(), {uid:uid});

                                    // remember this authentication token and user data
                                    var curr = load();
                                    curr.token = authToken;
                                    curr.data = res;
                                    localStorage.setItem(key, JSON.stringify(curr));
                                    
                                    app.ports.handle_authentication.send(JSON.stringify(res));
                                } else {
                                    
                                    var userData = {uid: data.Item.UID, patches:data.Item.Patches};
                                    var res = JSON.stringify(userData);
                                    
                                    app.ports.handle_authentication.send(res);
                                }
                            });
                        }
                        else {
                            console.log('Error getting Cognito Identity ID!');
                            sendError(err);
                        }
                    });
                },
                onFailure: function (err) {
                    sendError(err);
                },
                newPasswordRequired: function (userAttributes, requiredAttributes) {
                    console.log('Error authenticating: New Password Is Required');
                    sendError({});
                }
            });
        };
        
        // Save UserData in local storage and remotely if user is logged in
        var save = function (rawDat) {
            
            // transform data into format of DynamoDB
            var dat = {"UID": rawDat.uid, "Patches":rawDat.patches};

            console.log("save() UID: " + dat.UID + " Patches: " + JSON.stringify(dat.Patches));
            
            // save to local storage
            var curr = load();
            // log out?
            if (!rawDat.uid) {
                curr.token = null;
            }
            localStorage.setItem(key, JSON.stringify(_.extend(curr, {data:rawDat})));
            
            if (rawDat.uid != null && rawDat.uid != "anonymous") {
                getCredentials().get(function(err) {
                    if (!err) {
                        var config = configureCognito();
                        
                        // Load the DynamoDB data for this user
                        var params = {
                            TableName: config.TableName,
                            Item: dat
                        };

                        var docClient = new AWS.DynamoDB.DocumentClient({region: config.region});
                        docClient.put(params, function(err, data) {
                            if (err) {
                                console.log("Error saving patches remotely:");
                                console.log(JSON.stringify(err, undefined, 2));
                            }
                            else {
                                console.log("Successfully saved patches remotely!")
                            }
                        });
                    }
                    else {
                        console.log('Error getting Cognito Identity ID:');
                        console.log(JSON.stringify(err, undefined, 2));
                    }
                });
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