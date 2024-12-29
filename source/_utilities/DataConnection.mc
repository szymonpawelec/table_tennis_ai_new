// It is common for developers to wrap a makeWebRequest() call in a function
// as displayed below. The function defines the variables for each of the
// necessary arguments in a Communications.makeWebRequest() call, then passes
// these variables as the arguments. This allows for a clean layout of your web
// request and expandability.
import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application;
using Toybox.Time.Gregorian;


class DataConnection {
    private var _ulock;
    public var status;

    function goToPayment() as Void {
        Communications.openWebPage(
        "https://www.sport-ai.net",
        {
            "appType" => $.config.appType,
            "code" => $.config.verificationCode + $.config.appType,
        },
        null
        );
    }

    function getUlock() as Void {
        // Native device unlock code
        _ulock = $.config.masterCode;
        
        // Unlock code entered by the user
        if ($.config.unlockCode.size() != 0){
            _ulock = $.config.unlockCode;
        }
    }

    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html
    function sendTrainingStats() as Void {
        if(($.config.licenseToken["dev_reg_status"] == 2) | ($.config.licenseToken["dev_reg_status"] == 3) & $.trainingStats.totalCount != 0) {
            var url = "https://www.sport-ai.net/cloudsyncpost";                         // set the url
            // Native device unlock code
            self.getUlock();

            var params = {
                // set the parameters
                "unlock" => _ulock[0] + _ulock[1] + _ulock[2] + _ulock[3] + _ulock[4] + _ulock[5],
                "stats" => $.trainingStats.trainingStats,
                "dates" => $.trainingStats.trainingDates,
                "total" => $.trainingStats.totalCount
            };

            var options = {                                             // set the options
                :method => Communications.HTTP_REQUEST_METHOD_POST,      // set HTTP method
                :headers => {                                           // set headers
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };

            // Make the Communications.makeWebRequest() call
            Communications.makeWebRequest(url, params, options, method(:onReceive));
        }
    }
    function onReceive(responseCode as Number, data as String?) as Void {
        // System.println("Training data send");
        if (responseCode == 200) {
        } else {
        }
    }

    function getTrainingStats() as Void {
        var url = "https://www.sport-ai.net/cloudsyncget";                         // set the url
        // Native device unlock code
        self.getUlock();

        var params = {
            // set the parameters
            "unlock" => _ulock[0] + _ulock[1] + _ulock[2] + _ulock[3] + _ulock[4] + _ulock[5],
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        // set responseCallback to onReceive() method
        Communications.makeWebRequest(url, params, options, method(:storeTrainingStats));
    }
    function storeTrainingStats(responseCode as Number, data as String?) as Void {
        if (responseCode == 200) {
            // System.println("Training stats obtained:");
            // System.println(data);

            $.trainingStats.trainingStats = data["stats"];
            $.trainingStats.totalCount = data["total"];
            $.trainingStats.trainingDates = data["dates"];

            Storage.setValue("trainingStats", data["stats"]);
            Storage.setValue("totalCount", data["total"]);
            Storage.setValue("trainingDates", data["dates"]);
        } else {
        }
    }

    function getLicense() as Void {
        var url = "https://www.sport-ai.net/getlicense";                         // set the url

        // Native device unlock code
        self.getUlock();

        // Data token passed to server
        var params = {
            "unlock" => _ulock[0] + _ulock[1] + _ulock[2] + _ulock[3] + _ulock[4] + _ulock[5],
            "dev" => $.config.verificationCode + $.config.appType,
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        // set responseCallback to onReceive() method       
        Communications.makeWebRequest(url, params, options, method(:checkLicense));
    }
    function checkLicense(responseCode as Number, data as String?) as Void {
        self.status = responseCode;
        if (responseCode == 200) {
            // dev_red_status:
            //               -2 - License created based on manually entered code
            //               -1 - License was not created on device
            //                0 - Item not purchased
            //                1 - License OK, App type notOK
            //                2 - License OK, App type OK, dev registered first time
            //                3 - License OK, App type OK, dev already registered
            //                4 - License OK, App type OK, existing dev replaced OK
            //                5 - License OK, App type OK, existing dev replaced notOK

            // TEMPORARY CONDITION to allow users to enter unlock code manually
            if(data["dev_reg_status"] != 0 ) {
                $.config.licenseToken = data;
                Storage.setValue("licenseToken", $.config.licenseToken);
            }
            
            //Download training stats if device registered was replaced or there is no data yet (eg. same device but with factory reset)
            if(($.config.licenseToken["dev_reg_status"] == 4) | ($.config.trainingStats.totalCount == 0)) {
                self.getTrainingStats();
            }
            
            //Send training data based on license reg status
            $.dataConnection.sendTrainingStats();

            // System.println("License aquired");
            // System.println("Data: " + data);
            
        } else {
            // System.println("License NOT aquired. Response: " + responseCode);            // print response code

        }

        $.config.checkUnlock();

    }
    
}