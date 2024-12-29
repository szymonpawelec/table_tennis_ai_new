import Toybox.Lang;
using Toybox.ActivityRecording;
using Toybox.FitContributor;

class DataFields {

    private const _TOTAL_COUNT_ID = 160;
    private var _total_name = "Total stroke count";
    private var _statsTotal = null;

    private const _POWER_ID = {"fh" => 0, "bh" => 1, "sv" => 2, "bs" => 3, "fs" => 4};
    private const _STATS_POWER_ID = {"fh" => 10, "bh" => 11, "sv" => 12, "bs" => 13, "fs" => 14};
    private const _STATS_STROKE_ID = {"fh" => 100, "bh" => 110, "sv" => 120, "bs" => 130, "fs" => 140};

    private var _power = {"fh" => null, "bh" => null, "sv" => null, "bs" => null, "fs" => null};
    private var _statsPower = {"fh" => null, "bh" => null, "sv" => null, "bs" => null, "fs" => null};
    private var _statsStroke = {"fh" => null, "bh" => null, "sv" => null, "bs" => null, "fs" => null};

    private var _power_name = {"fh" => "Forehand power" as String,
                                "bh" => "Backhand power",
                                "sv" => "Serve power",
                                "bs" => "Backhand Slice power",
                                "fs" => "Forehand Slice power"};

    private var _stats_name = {"fh" => "Forehand stats",
                                "bh" => "Backhand stats",
                                "sv" => "Serve stats",
                                "bs" => "Backhand Slice stats",
                                "fs" => "Forehand Slice stats"};

    // this keeps the last strokes power untill it is printed on the fitFiled graph
    private var _temporaryRegister = {
        "fh" => [] as Array<Array<Number>>,
        "bh" => [] as Array<Array<Number>>,
        "sv" => [] as Array<Array<Number>>,
        "bs" => [] as Array<Array<Number>>,
        "fs" => [] as Array<Array<Number>>};

    // this dictionary keeps track of number of seconds last stroke was printed on graph, if exceeded $config.graphDataRetention it is no longer in register/graph
    private var _temporaryRegisterToggle = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};

    private var _sensorAccelerationX;
    private var _sensorAccelerationY;
    private var _sensorAccelerationZ;
    
    public const FITFIELD_SENSORACCELERATIONX_HD = 5;
    public const FITFIELD_SENSORACCELERATIONY_HD = 15;
    public const FITFIELD_SENSORACCELERATIONZ_HD = 150;
                                

    function initialize() {
    }

    public function createDataFieldAccelerometer() {
        if ($.config.recordAccel) {
            self._sensorAccelerationX = session.createField(
                "SensorAccelerationX_HD",
                self.FITFIELD_SENSORACCELERATIONX_HD,
                FitContributor.DATA_TYPE_SINT16,
                {:count => 25,
                :mesgType => FitContributor.MESG_TYPE_RECORD as Number,
                :units => "mgn" }
                );
            self._sensorAccelerationY = session.createField(
                "SensorAccelerationY_HD",
                self.FITFIELD_SENSORACCELERATIONY_HD,
                FitContributor.DATA_TYPE_SINT16,
                {:count => 25,
                :mesgType => FitContributor.MESG_TYPE_RECORD as Number,
                :units => "mgn" }
                );
            self._sensorAccelerationZ = session.createField(
                "SensorAccelerationZ_HD",
                self.FITFIELD_SENSORACCELERATIONZ_HD,
                FitContributor.DATA_TYPE_SINT16,
                {:count => 25,
                :mesgType => FitContributor.MESG_TYPE_RECORD as Number,
                :units => "mgn" }
                );
        }
    }

    public function setDataFieldAcceleration(accelX as Array<Number>, accelY as Array<Number>, accelZ as Array<Number>) as Void {
        if ((session != null) && session.isRecording() && $.config.recordAccel) {
            self._sensorAccelerationX.setData(accelX);
            self._sensorAccelerationY.setData(accelY);
            self._sensorAccelerationZ.setData(accelZ);
        }
    }

    public function createDataField(type as String) as Void {
        self._power[type] = session.createField(
            self._power_name[type],
            self._POWER_ID[type],
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"}
            );

        self._statsPower[type] = session.createField(
            self._stats_name[type],
            self._STATS_POWER_ID[type],
            FitContributor.DATA_TYPE_STRING,
            {:mesgType=>FitContributor.MESG_TYPE_SESSION, :count=>15}
            );
            
        self._statsStroke[type] = session.createField(
            self._stats_name[type],
            self._STATS_STROKE_ID[type],
            FitContributor.DATA_TYPE_STRING,
            {:mesgType=>FitContributor.MESG_TYPE_SESSION, :count=>15}
            );

        self._power[type].setData(0);
        self._statsPower[type].setData("- / -");
        self._statsStroke[type].setData("- / - / -");
    }

    public function createDataFieldTotal() as Void {
        self._statsTotal = session.createField(
            self._total_name,
            self._TOTAL_COUNT_ID,
            FitContributor.DATA_TYPE_STRING,
            {:mesgType=>FitContributor.MESG_TYPE_SESSION, :count=>15}
            );

        self._statsTotal.setData(" - ");
    }

    public function setDataField(type as String, power as Number, avgPower as Number, maxPower as Number, count as Number, stroke as Boolean, foulCount as Number, winnerCount as Number) as Void {
        if ((session != null) && session.isRecording() && stroke) {
            setDataFieldSummary(type, count, avgPower, maxPower, foulCount, winnerCount);
            self._statsTotal.setData($.strokesHistory.totalCount.toNumber().toString());
        }
    }

    public function setDataFieldSummary(type as String, count as Number, avgPower as Number, maxPower as Number, foulCount as Number, winnerCount as Number){
        if ((session != null) && session.isRecording()) {
            self._statsPower[type].setData(avgPower.toNumber().toString() + " / " + maxPower.toNumber().toString());
            self._statsStroke[type].setData(count.toString() + " / " + winnerCount.toNumber().toString() + " / " + foulCount.toNumber().toString());
        }

    }

    // this method adds each stroke to temp register which is subsequently used to plot strokes power on a graph
    public function addStrokeToRegister(type as String, Power as Number){
        self._temporaryRegister[type].add(Power);
    }

    // this method registers the strokes to the graph fitField and retain it for the period defined by $.config.graphDataRetention
    public function setGraphData(){
        if ((session != null) && session.isRecording()) {
            for (var i = 0; i < $.config.strokeTypes.size(); i++) {

                var type = $.config.strokeTypes[i];

                if(self._temporaryRegister[type].size() == 0){
                    self._power[type].setData(0);
                } else {
                    self._power[type].setData(self._temporaryRegister[type][0].toNumber());
                    self._temporaryRegisterToggle[type]++;
                    if (self._temporaryRegisterToggle[type] > $.config.graphDataRetention - 1){
                        self._temporaryRegister[type].remove(self._temporaryRegister[type][0]);
                        self._temporaryRegisterToggle[type] = 0;
                    }
                }
            }
        }
    }

}