(function(scope) {

    var app = Elm.Main.init({
        node: document.getElementById('elm')
    });
    
    var storage = function() {
        
        var key = "patchbae";
        
        var load = function() {

            // var out = [];
            // TODO: remove this
            var out = initMyInstruments();

            try {
                var cached = JSON.parse(localStorage.getItem(key));
                if (cached != null) {
                    out = cached;
                }
            }
            catch (err) {}

            return out;
        };

        // TODO: remove -- this is temporary and for me only!
        var initMyInstruments = function() {

            var out = [];

            // add all program slots for Prophet Rev2

            var prophetBanks = ["U1","U2","U3","U4"];
            var prophetPrograms = 128;
            var programSlots = _.range(1,prophetPrograms+1);

            var count = -1;

            _.forEach(prophetBanks, function(bank){
                _.forEach(programSlots, function(program){

                    count += 1;

                    var sfx = String(program);
                    if (sfx.length == 1) {
                        sfx = "0" + sfx;
                    }
                    var address = bank + "-" + sfx;

                    var patch = {
                        id: "pb-" + String(count),
                        instrument: "Prophet Rev2",
                        category: "Pad",
                        address: address,
                        name: "XXX",
                        rating: 1,
                        tags: [],
                        projects: [],
                        family: [],
                        friends: []
                    };

                    out.push(patch);
                })
            });

            // add all program slots for Roland TR-8S

            _.forEach(programSlots, function(program){
                count += 1;
                var patch = {
                    id: "pb-" + String(count),
                    instrument: "Roland TR-8S",
                    category: "Kick",
                    address: "Kit" + String(program),
                    name: "XXX",
                    rating: 1,
                    tags: [],
                    projects: [],
                    family: [],
                    friends: []
                };

                out.push(patch);
            });

            return out;
        }

        var clear = function() {
            localStorage.setItem(key, undefined);
        };
        
        // Corresponds to Main.cached
        return {
            cached : 
                function () {

                    try {
                        var cachedPatches = load();
                        
                        app.ports.receive.send(cachedPatches);
                        // else {
                            
                            // var params = {
                            //     method: "GET",
                            //     headers:  {
                            //         "x-rapidapi-host": "apidojo-yahoo-finance-v1.p.rapidapi.com",
                            //         "x-rapidapi-key": apiKey
                            //     }
                            // };

                            // var url = apiUrl(interval, range, symbols);
                            // fetch(url, params)
                            //     .then(res => res.json())
                            //     .then(res => {

                            //         // save data for the symbols we received
                            //         set(response.symbol, range, interval, response.timestamp, response.quotes);
                                    
                            //         _.each(response.compare_symbols, function(symbol, i) {
                                        
                            //             set(symbol, range, interval, response.timestamp, response.compare_close[i]);
                            //         });
                                    
                            //         // we finally have all the data we need, so save it and send it over to be displayed
                            //         update(response);
                            //     });
                        // }
                    }
                    catch (err) {
                        console.log(err);
                    }
                },
            
            save : function (patches) {
                
                localStorage.setItem(key, JSON.stringify(patches));
            }
        };
    };
    
    app.ports.cached.subscribe(storage().cached);
    app.ports.save.subscribe(storage().save);
})(this);