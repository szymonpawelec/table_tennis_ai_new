import Toybox.Lang;
import Toybox.Timer;
import Toybox.Graphics;

class TennisStrokeHistory
{
    public var register = [] as Array<Number>;

    public var registerByType = {
        "fh" => [] as Array<Array<Number>>,
        "bh" => [] as Array<Array<Number>>,
        "sv" => [] as Array<Array<Number>>,
        "bs" => [] as Array<Array<Number>>,
        "fs" => [] as Array<Array<Number>>};

    public var registerPowerGauss = {
        "fh" => new[10],
        "bh" => new[10],
        "sv" => new[10],
        "bs" => new[10],
        "fs" => new[10]};

    public var registerFauls = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};
    public var registerWinners = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};

    public var timeRegisterLength = 20;
    public var timeRegister = null;
    public var timeRegisterLast = "";
    public var activityStartTime;
    public var activityStartDate;

    public var currentCount = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};
    public var totalCount = 0;
    
    public function initialize() {
        self._initTimeRegister();
        self._initPowerGauss();
    }

    private function _initTimeRegister() as Void {
        self.timeRegister = new[self.timeRegisterLength];
        for( var i = 0; i < self.timeRegister.size(); i += 1 ) {
            self.timeRegister[i] = [null, null, null];
        }
    }

    private function _initPowerGauss() as Void {
        for( var i = 0; i < $.config.strokeTypes.size(); i += 1 ) {
            var type = $.config.strokeTypes[i];
            for( var j = 0; j < 10; j += 1 ) {
                self.registerPowerGauss[type][j] = 0;
            }
        }
    }

    public function wipeCurrentCounter() as Void {
        self.currentCount = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};
    }

    public function addStroke(type as String, mag as Number) as Void {
        var time = System.getClockTime(); // ClockTime object
        var currentTime =time.hour.format("%02d") + ":" + time.min.format("%02d") + ":" + time.sec.format("%02d");
        
        var power = (mag - $.config.signalThreshold).toFloat()/($.config.strokeSignalMaxScale - $.config.signalThreshold)*100;
        if (power < 1) {
            power = 1;
        } else if(power > 100) {
        power = 100;
        }

        var avgPower = 0;
        var maxPower = 0;

        // Set avg and max power based on stroke Type
        if(self.currentCount[type] == 0) {
            avgPower = power;
            maxPower = power;

        } else {
            var strokesCount = self.currentCount[type];
            avgPower = (self.registerByType[type][4]*strokesCount+power)/(strokesCount+1);
            if(power > self.registerByType[type][5]) {
                maxPower = power;
            } else {
                maxPower = self.registerByType[type][5];
            }

        }

        // Update counters
        self.currentCount[type]++;
        self.totalCount++;
        self._addStrokeToPowerGauss(type, power);
        
        // Store recorded stroke data
        // stroke time, type, magnitude, power, average power, max power, foul?, winner?
        self.registerByType[type] = [currentTime, type, mag, power, avgPower, maxPower, false, false];
        self.register = [currentTime, type, mag, power, avgPower, maxPower, false, false];

        $.dataFields.addStrokeToRegister(type, power);
        $.dataFields.setDataField(type, power, avgPower, maxPower, self.currentCount[type], true, self.registerFauls[type], self.registerWinners[type]);
        
    }

    private function _addStrokeToPowerGauss(type as String, pow as Double) as Void {
        var power = pow;
        if(power > 100) {
            power = 100;
        }

        for( var i = 0; i < 10; i += 1 ) {
            if ((power > i*10) & (power <= (i+1)*10)) {
                self.registerPowerGauss[type][i]++;
            }
        }

    }

    public function addFoul() as Void {

        if(self.register.size() != 0) {
            var type = self.register[1];
            var foul = self.registerByType[type][6];
            var winner = self.registerByType[type][7];

            // check if there is already a winner registered
            if(foul) {
                self.registerByType[type][6] = false;
                self.register[6] = false;
                self.registerFauls[type] -= 1;
            // if not register a winner
            } else {
                self.registerByType[type][6] = true;
                self.register[6] = true;
                self.registerFauls[type] += 1;
                // delete already registered winner:
                if(winner) {
                    self.registerByType[type][7] = false;
                    self.register[7] = false;
                    self.registerWinners[type] -= 1;
                }
            }
            var count = self.currentCount[type];
            var avgPower = self.registerByType[type][4];
            var maxPower = self.registerByType[type][5];
            var fouls = self.registerFauls[type];
            var winners = self.registerWinners[type];

            $.dataFields.setDataFieldSummary(type, count, avgPower.toNumber(), maxPower.toNumber(), fouls, winners);
        }
    }

    public function addWinner() as Void {

        if(self.register.size() != 0) {
            var type = self.register[1];
            var foul = self.registerByType[type][6];
            var winner = self.registerByType[type][7];

            // check if there is already a winner registered
            if(winner) {
                self.registerByType[type][7] = false;
                self.register[7] = false;
                self.registerWinners[type] -= 1;
            // if not register a winner
            } else {
                self.registerByType[type][7] = true;
                self.register[7] = true;
                self.registerWinners[type] += 1;
                // delete already registered foul:
                if(foul) {
                    self.registerByType[type][6] = false;
                    self.register[6] = false;
                    self.registerFauls[type] -= 1;
                }
            }

            var count = self.currentCount[type];
            var avgPower = self.registerByType[type][4];
            var maxPower = self.registerByType[type][5];
            var fouls = self.registerFauls[type];
            var winners = self.registerWinners[type];

            $.dataFields.setDataFieldSummary(type, count, avgPower.toNumber(), maxPower.toNumber(), fouls, winners);
        }
    }

    public function updateStrokeTimeRegister() as Void {
        self.timeRegister = self.timeRegister.slice(1,self.timeRegister.size());
        var time = self.register[0];
        var type = self.register[1];
        var power = self.register[3];
        
        if(self.timeRegisterLast != time) {
            self.timeRegister.add([time, type, power]);
            self.timeRegisterLast = time;
        } else {
            self.timeRegister.add([null, null, null]);
            // type, power, avg power, max power, count, stroke?, foul?, winner?
            $.dataFields.setDataField("", null, null, null, null, false, false, false);
        }
    }

    private function _updateCount(type as String) {
        self.currentCount[type]++;
    }

    public function getMaxTotalCount() as Number {
        var counts = [
            self.currentCount["fh"],
            self.currentCount["bh"],
            self.currentCount["sv"],
            self.currentCount["bs"],
            self.currentCount["fs"]
            ];  
        var countsSize = counts.size();

        var max = counts[0];
        for (var i = 1; i < countsSize; i++) {
            if (max < counts[i]) {
            max = counts[i];
            }
        }

        return max;
    }

}
