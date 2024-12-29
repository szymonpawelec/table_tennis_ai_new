using Toybox.System;
import Toybox.Application;
import Toybox.Lang;

class TrainingStats  {
    public var historyLength = $.config.trainingHistoryLength;

    public var totalCount = 0;

    public var trainingDates = new[self.historyLength];

    public var trainingStats = {
        "fh" => {
            "totalcount" => 0,
            "lastTrainingGauss" => new[10],
            "avg" => new[self.historyLength] as Array<Number>,
            "countHist" => new[self.historyLength] as Array<Number>,
            "winHist" => new[self.historyLength] as Array<Number>,
            "faulHist" => new[self.historyLength] as Array<Number>,
        },
        "bh" => {
            "totalcount" => 0,
            "lastTrainingGauss" => new[10],
            "avg" => new[self.historyLength] as Array<Number>,
            "countHist" => new[self.historyLength] as Array<Number>,
            "winHist" => new[self.historyLength] as Array<Number>,
            "faulHist" => new[self.historyLength] as Array<Number>,
        },
        "sv" => {
            "totalcount" => 0,
            "lastTrainingGauss" => new[10],
            "avg" => new[self.historyLength] as Array<Number>,
            "countHist" => new[self.historyLength] as Array<Number>,
            "winHist" => new[self.historyLength] as Array<Number>,
            "faulHist" => new[self.historyLength] as Array<Number>,
        },
        "bs" => {
            "totalcount" => 0,
            "lastTrainingGauss" => new[10],
            "avg" => new[self.historyLength] as Array<Number>,
            "countHist" => new[self.historyLength] as Array<Number>,
            "winHist" => new[self.historyLength] as Array<Number>,
            "faulHist" => new[self.historyLength] as Array<Number>,
        },
        "fs" => {
            "totalcount" => 0,
            "lastTrainingGauss" => new[10],
            "avg" => new[self.historyLength] as Array<Number>,
            "countHist" => new[self.historyLength] as Array<Number>,
            "winHist" => new[self.historyLength] as Array<Number>,
            "faulHist" => new[self.historyLength] as Array<Number>,
        },
    };

    function initialize() {
        self.loadTrainingStatisctics();
    }

    function loadTrainingStatisctics() {
        if (Application.Storage.getValue("totalCount") != null) {
            self.totalCount = Application.Storage.getValue("totalCount");
            self.trainingDates = Application.Storage.getValue("trainingDates");
            self.trainingStats = Application.Storage.getValue("trainingStats");
        } else {
            for( var i = 0; i < $.config.strokeTypes.size(); i += 1 ) {
                var type = $.config.strokeTypes[i];
                for( var j = 0; j < self.historyLength; j += 1 ) {
                    self.trainingStats[type]["avg"][j] = 0;
                    self.trainingStats[type]["countHist"][j] = 0;
                    self.trainingStats[type]["winHist"][j] = 0;
                    self.trainingStats[type]["faulHist"][j] = 0;
                }
                for( var j = 0; j < 10; j += 1 ) {
                    self.trainingStats[type]["lastTrainingGauss"][j] = 0;
                }
            }
        }
    }

    function saveTrainingStatistics() {

        self.totalCount += $.strokesHistory.totalCount;

        var time = $.strokesHistory.activityStartDate;
        var date = time.year + "/" + time.month + "/" + time.day + "/" + time.hour.format("%02d") + ":" + time.min.format("%02d");
        self.trainingDates = self.trainingDates.add(date).slice(1, self.trainingDates.size());

        for( var i = 0; i < $.config.strokeTypes.size(); i += 1 ) {
            var type = $.config.strokeTypes[i];
            var avg = 0;
            var count = 0;
            var win = 0;
            var foul = 0;
            var powerGauss = $.strokesHistory.registerPowerGauss[type];

            if($.strokesHistory.currentCount[type] > 0) {
                avg = $.strokesHistory.registerByType[type][4].toNumber();
                count = $.strokesHistory.currentCount[type];
                win = $.strokesHistory.registerWinners[type];
                foul = $.strokesHistory.registerFauls[type];
            }

            self.trainingStats[type]["totalcount"] += count;
            self.trainingStats[type]["lastTrainingGauss"] = powerGauss;
            self.trainingStats[type]["avg"] = self.trainingStats[type]["avg"].add(avg).slice(1, self.trainingStats[type]["avg"].size());
            self.trainingStats[type]["countHist"] = self.trainingStats[type]["countHist"].add(count).slice(1, self.trainingStats[type]["countHist"].size());
            self.trainingStats[type]["winHist"] = self.trainingStats[type]["winHist"].add(win).slice(1, self.trainingStats[type]["winHist"].size());
            self.trainingStats[type]["faulHist"] = self.trainingStats[type]["faulHist"].add(foul).slice(1, self.trainingStats[type]["faulHist"].size());
            
        }

        Storage.setValue("trainingStats", self.trainingStats);
        Storage.setValue("totalCount", self.totalCount);
        Storage.setValue("trainingDates", self.trainingDates);

        // send data to cloud
        $.dataConnection.sendTrainingStats();

    }

    public function removeTraining(i) as Void {

        var id = historyLength - 1 - i;
        // Remove dates
        self.trainingDates = [null].addAll(self.trainingDates.slice(null,id)).addAll(self.trainingDates.slice(id + 1,null));
        
        for( var j = 0; j < $.config.strokeTypes.size(); j += 1 ) {
            var type = $.config.strokeTypes[j];

            // correct total count
            var countRemove = self.trainingStats[type]["countHist"][id];
            if(countRemove != null){
                self.totalCount -= countRemove;
                self.trainingStats[type]["totalcount"] -= countRemove;
            }

            // remove from History
            var cHist = self.trainingStats[type]["countHist"];
            self.trainingStats[type]["countHist"] = [0].addAll(cHist.slice(null,id)).addAll(cHist.slice(id + 1,null));

            var wHist = self.trainingStats[type]["winHist"];
            self.trainingStats[type]["winHist"] = [0].addAll(wHist.slice(null,id)).addAll(wHist.slice(id + 1,null));

            var fHist = self.trainingStats[type]["faulHist"];
            self.trainingStats[type]["faulHist"] = [0].addAll(fHist.slice(null,id)).addAll(fHist.slice(id + 1,null));

            var avg = self.trainingStats[type]["avg"];
            self.trainingStats[type]["avg"] = [0].addAll(avg.slice(null,id)).addAll(avg.slice(id + 1,null));

            // remove gauss histogram
            if(i == 0){
                for( var k = 0; k < 10; k += 1 ) {
                    self.trainingStats[type]["lastTrainingGauss"][k] = 0;
                }
            }

        }

        Storage.setValue("trainingStats", self.trainingStats);
        Storage.setValue("totalCount", self.totalCount);
        Storage.setValue("trainingDates", self.trainingDates);

    }

    public function getMaxTotalCount() as Number {
        var max = 0;
        var strokeList = $.config.strokeTypesView.size();

        for(var i = 0; i < strokeList; i += 1 ) {
            var type = $.config.strokeTypesView[i];
            for(var k = 0; k < 20; k += 1 ) {
                if (max < self.trainingStats[type]["countHist"][k]) {
                    max = self.trainingStats[type]["countHist"][k];
                }
            }
        }

        return max;
    }

}