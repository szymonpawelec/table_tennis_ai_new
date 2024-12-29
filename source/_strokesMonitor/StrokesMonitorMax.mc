using Toybox.Sensor;
using Toybox.Math;
using Toybox.UserProfile;
import Toybox.Lang;

class TennisStrokesMonitorMax
{
    public var trainingInitialSteps = ActivityMonitor.getInfo().steps;
    private var _maxSampleRate = 25;
    private var _SampleRate = 1;
    private var _signalX = [] as Array<Number>;
    private var _signalY = [] as Array<Number>;
    private var _signalZ = [] as Array<Number>;
    private var _hrZones;
    public var hrZonesCumulated = [0,0,0,0,0];

    private var _filter = Application.loadResource(Rez.JsonData.jsonFilters);
    
    private var _filterLength = 0 as Number;
    
    private var _signalCurrentMagnitude = 0;
    private var _countStrokeDuration = 20;
    private var _lastStrokeIndex = 0;
    private var _strokeThreshold = $.config.strokeThreshold*(1-$.config.sensitivity.toFloat()/50);
    private var _countHistoryCallback = 0;

    private var _threshold = $.config.signalThreshold + (5 - $.config.sensitivity)*60;

    public var filterSlotUsed = 0;
    private var _calTempStroke =  new[3] as Array<Array<Number>>;

    // variables for handling over max accel signal
    private var _omaxThreshold = -7900; //maximum acceleration captured by devices
    private var _omaxIndex = 0;
    private var _omaxInprocess = false;
    private var _omaxPatchSize = 0;
    private var _omaxPatch =[];
    private var _omaxPatchBefore = 0;
    private var _omaxPatchAfter = 0;
    private var _omaxPatchAfterCarried = false; //this flag tells if it should wait for susequent signal data
    private var _omaxPatchScaleMin = 4500;  //this sets minimum adjacent signal value what would be interpolated
    private var _omaxTemplate = {
        1 => [-8400],
        2 => [-8800, -8200],
        3 => [-8600, -9200, -8600],
        4 => [-8800, -9600, -9067, -8533],
        5 => [-8667, -9333, -10000, -9333, -8667],
        6 => [-8900, -9650, -10400, -9650, -8900, -8240],
        7 => [-8700, -9400, -10100, -10800, -10100, -9400, -8700]
    };


    public function initialize() {
        self._filterLength = self._filter["fh"][0].size();
    }

    // Initializes the view and registers for accelerometer data
    public function enableAccel() as Void {

         // initialize accelerometer to request the maximum amount of data possible
        var options = {:period => self._SampleRate, :sampleRate => self._maxSampleRate, :enableAccelerometer => true};
        try {
            Toybox.Sensor.registerSensorDataListener(method(:accelHistoryCallback), options);
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }
    // Disable accelerometer monitor
    public function disableAccel() as Void {

        try {
            Toybox.Sensor.unregisterSensorDataListener();
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    private function updateHrZone() as Void {
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        _hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());

        if(heartRate != null){

            for( var i = 0; i < hrZonesCumulated.size(); i += 1 ) {
                if(heartRate > _hrZones[_hrZones.size() - i - 2]){
                    hrZonesCumulated[hrZonesCumulated.size() - i - 1] += 1;
                    break;
                }
            }

            if(heartRate <= _hrZones[0]){hrZonesCumulated[0] += 1;}
        }

    }

    // Prints acclerometer data that is recevied from the system
    public function accelHistoryCallback(sensorData as Sensor.SensorData) as Void {

        var filtResult = 0 as Number;
        var strokeType = "" as String;

        updateHrZone();
        
        if($.config.leftHanded) {
            for( var i = 0; i < sensorData.accelerometerData.x.size(); i += 1 ) { 
                self._signalX.add(-sensorData.accelerometerData.x[i]);
            }
        } else {
            self._signalX.addAll(sensorData.accelerometerData.x);
        }

        self._signalY.addAll(sensorData.accelerometerData.y);
        self._signalZ.addAll(sensorData.accelerometerData.z);

        $.dataFields.setDataFieldAcceleration(sensorData.accelerometerData.x,
                                                sensorData.accelerometerData.y,
                                                sensorData.accelerometerData.z);

        //  handling over max accel signal
        for( var i = 0; i < self._SampleRate*25; i += 1 ) { 
            // index pointing within current signalX
            var loopIndex = self._signalX.size() - self._SampleRate*25 + i;
            // index poining within entire history
            var histIndex = loopIndex + self._countHistoryCallback;

            // record whenever signal is omax
            if (self._signalX[loopIndex] < self._omaxThreshold) {

                // capture BEFORE signal to serve as scaling parameter
                if(!self._omaxInprocess & (loopIndex > 1)) {
                   self._omaxPatchBefore = self._signalX[loopIndex - 1];
                }

                self._omaxInprocess = true;
                self._omaxPatch.add(self._signalX[loopIndex]);
                self._omaxPatchSize += 1;

                // make sure stronger signal than in template is handled
                if(self._omaxPatchSize > 6) {
                    self._omaxPatchSize = 7;
                }

                // capture AFTER signal to serve as scaling parameter
                if(i < 24) {
                    self._omaxPatchAfter = self._signalX[loopIndex + 1];
                } else {
                    self._omaxPatchAfterCarried = true;
                }

            } else if (self._omaxInprocess || self._omaxPatchSize > 6) {

                //if last omax was at the edge of previous 25signal, store first value for scaling
                if(self._omaxPatchAfterCarried) {
                    self._omaxPatchAfterCarried = false;
                    self._omaxPatchAfter = self._signalX[loopIndex];
                }

                // if signal is not omax anymore -> reconstruct it
                self._omaxInprocess = false;
                self._omaxIndex = histIndex - self._omaxPatchSize;

                //calculate scaling parameter
                var scale = Math.mean([self._omaxPatchAfter, self._omaxPatchBefore]).abs();
                scale = (scale - _omaxPatchScaleMin)/(-_omaxThreshold - _omaxPatchScaleMin);
                if(!((scale > 0) & (scale < 1))){
                    scale = 0;
                }
                scale = 1-0.045*(1-scale);

                // replace signal:
                for( var j = 0; j < self._omaxPatchSize; j += 1 ) {
                    self._signalX[self._omaxIndex - self._countHistoryCallback + j] = (self._omaxTemplate[self._omaxPatchSize][j].toFloat()*scale).toNumber();
                }
                
                self._omaxPatch = [];
                self._omaxPatchSize = 0;
                self._omaxPatchAfter = 0;
                self._omaxPatchAfter = 0;
            }
            
        }

        if(self._signalX.size() > 75) {
            for( var i = 0; i < self._SampleRate*25; i += 1 ) {

                var loopIndex = self._signalX.size() - self._SampleRate*25 - self._filterLength/2 + i - 10;
                var xSign = self._signalX[loopIndex].abs();
                var zSign = self._signalZ[loopIndex].abs();
                // System.println(loopIndex + self._countHistoryCallback + ": " + xSign);   
                
                // Check if signal X mag is above threshold and last recorded maximum signal
                if(((xSign > self._threshold) | (zSign > self._threshold)) & (xSign > self._signalCurrentMagnitude)) {
                    self._signalCurrentMagnitude = xSign;
                    self._lastStrokeIndex = loopIndex + self._countHistoryCallback;
                    self._calTempStroke = [null, null, null];
                    self._calTempStroke[0] = self._signalX.slice(loopIndex - 21, loopIndex + 21);
                    self._calTempStroke[1] = self._signalY.slice(loopIndex - 21, loopIndex + 21);
                    self._calTempStroke[2] = self._signalZ.slice(loopIndex - 21, loopIndex + 21);
                }
                // Check if there was no signal maximum through the last countStrokeDuration number of data points
                if((loopIndex + self._countHistoryCallback - self._lastStrokeIndex > self._countStrokeDuration) & (self._signalCurrentMagnitude > self._threshold)) {
                    
                    // System.println(self._calTempStroke);

                    var maxScore = 0;
                    var maxType = null;

                    for(var j=0; j<$.config.strokeFilterTypes.size(); j+=1) {
                        var type = $.config.strokeFilterTypes[j];

                        var score = self._calculateScore(type);


                        if(score > maxScore) {
                            maxScore = score;
                            // System.println(type);
                            maxType = $.config.strokeTypesAssign[type];
                        }
                    }
                    if (maxScore > self._strokeThreshold){
                        // System.println(maxType);
                        var power = self._calTempStroke[0][21].abs();
                        $.strokesHistory.addStroke(maxType, power);
                        }

                    // Wipe last signal magnitude to allow to seek for subsequent stroke
                    self._signalCurrentMagnitude = 0;
 
                }

            }

            self._signalX = self._signalX.slice(self._signalX.size() - 75,self._signalX.size());
            self._signalY = self._signalY.slice(self._signalY.size() - 75,self._signalY.size());
            self._signalZ = self._signalZ.slice(self._signalZ.size() - 75,self._signalZ.size());

            self._countHistoryCallback = self._countHistoryCallback + 25;
        }
    }

    private function _calculateScore(filtType as String) as Number {
        
        var type = filtType;
        var filt_x = 0 as Number;
        var filt_y = 0 as Number;
        var filt_z = 0 as Number;

        for (var i=0; i<self._filterLength; i += 1){
            filt_x += self._filter[type][0][i] * _calTempStroke[0][i];
            filt_y += self._filter[type][1][i] * _calTempStroke[1][i];
            filt_z += self._filter[type][2][i] * _calTempStroke[2][i];
        }

        return (filt_x + filt_y + filt_z).abs();
    }

    private function findMax(x,y,z,w,q) as Number {
        var array = [x, y, z, w, q];
        var max = 0 as Number;
        for (var i = 0; i < array.size(); i += 1) {
            if(array[i] > max) {
                max = array[i];
            }
        }
        return max;
    }

    public function getLastSignal() as Array {
        return [self._signalX, self._signalY, self._signalZ];
    }

}
