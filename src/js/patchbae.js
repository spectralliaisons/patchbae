(function(scope) {

    var app = Elm.Main.init({
        node: document.getElementById('elm')
    });
    
    window.cached = function() {
        
        var key = "patchbae";
        
        var load = function() {

            var out = [];

            try {
                var cached = JSON.parse(localStorage.getItem(key));
                if (cached != null) {
                    out = cached;
                }
            }
            catch (err) {}

            return out;
        };

        var clear = function() {
            localStorage.setItem(key, undefined);
        };
        
        // Corresponds to Main.cached
        return function() {

            try {
                var cachedPatches = load();

                console.log("cache.js cachedPatches: " + JSON.stringify(cachedPatches));
                
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
        }
    };

    // Command from Elm to get symbol data
    // Response will be in the form of Finance.result
    app.ports.cached.subscribe(cached());
})(this);