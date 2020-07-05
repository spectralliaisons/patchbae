/*
Authenticate user via Amazon Cognito, get and set data in local storage via cacheInterface and save remotely via Amazon DynamoDB
*/

window.pbClient = function (cacheInterface) {
    
    var loadCache = cacheInterface.loadCache;
    var setCache = cacheInterface.setCache;

    // AWS Ids to authenticate users and get/set data
    var awsConfig = function() {
        return {
            region: 'us-west-2',
            // https://us-west-2.console.aws.amazon.com/cognito/pool/edit/?region=us-west-2&id=us-west-2:523d5740-2025-42c1-b376-0e088fd434fe
            IdentityPoolId: 'us-west-2:523d5740-2025-42c1-b376-0e088fd434fe',
            UserPoolId: "us-west-2_L73KMG0qo",
            ClientId: "4levi3hs6507ihbakebflni1lr",
            TableName: "Patchbae"
        };
    };

    // Return properly configured AWS credentials
    var configuredCredentials = function () {

        var curr = loadCache();
        var token = curr.token;
        var config = awsConfig();

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
        return new Promise( (resolve) => {
            
            var config = awsConfig();
                
            var sendError = function(err) {
                
                console.log("Error authenticating:");
                console.log(JSON.stringify(err, undefined, 2));
                
                resolve(err.message);
            };
            
            var userPool = new AmazonCognitoIdentity.CognitoUserPool(config);
            let authenticationData = { Username: username, Password: password };
            let authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(authenticationData);
            let userData = { Username: username, Pool: userPool };
            let cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

            cognitoUser.authenticateUser(authenticationDetails, {
                onSuccess: function (result) {
                    
                    var authToken = result.getIdToken().getJwtToken();

                    // remember this authentication token
                    var curr = loadCache();
                    curr.token = authToken;
                    setCache(curr);

                    configuredCredentials().get(function(err) {
                        if (!err) {
                            var uid = AWS.config.credentials.identityId;
                            console.log('Cognito Identity ID '+ uid);

                            // Load the DynamoDB data for this user
                            var params = {
                                TableName: awsConfig().TableName,
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
                                    var curr = loadCache();
                                    curr.token = authToken;
                                    curr.data = res;
                                    setCache(curr);
                                    resolve(res);
                                } else {
                                    var res = {uid: data.Item.UID, patches:data.Item.Patches};
                                    resolve(res);
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
                    sendError({message:'Error authenticating: New Password Is Required'});
                }
            });
        });
    };
    
    // Save UserData in local storage and remotely if user is logged in
    var save = function (rawDat) {
        return new Promise( (resolve) => {
            // transform data into format of DynamoDB
            var sanitizedDat = {"UID": rawDat.uid, "Patches":rawDat.patches};
            
            // save to local storage
            var curr = loadCache();

            // if user was logged in and now requests to log out, then 
            if (!rawDat.uid) {
                curr.token = null;
            }
            setCache(_.extend(curr, {data:rawDat}));
            
            if (rawDat.uid != null && rawDat.uid != "anonymous") {
                configuredCredentials().get(function(err) {
                    if (!err) {
                        var config = awsConfig();

                        // Load the DynamoDB data for this user
                        var params = {
                            TableName: config.TableName,
                            Item: sanitizedDat
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
        } );
    };

    return {
        authenticate : authenticate,
        save : save
    }
};