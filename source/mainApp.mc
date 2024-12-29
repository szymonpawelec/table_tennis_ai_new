import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;
using Toybox.ActivityRecording;

// Define views
var calibrationView;
var calibrationDelegate;
var statsView;
var statsDelegate;

// Define objects for recording strokes and app data
var dataFields;
var strokesMonitor;
var strokesHistory;
var calibration;
var config;
var trainingStats;
var dataConnection;

class mainApp extends Application.AppBase {
    

    function initialize() {
        AppBase.initialize();

        $.dataConnection = new DataConnection();
        $.config = new Config();
        $.trainingStats = new TrainingStats();
        $.config.checkVersion();
        $.config.checkUnlock();
        $.dataConnection.getLicense();

        $.dataFields = new DataFields();
        $.strokesHistory = new TennisStrokeHistory();

        $.strokesMonitor = new TennisStrokesMonitorMax();
        $.statsView = new StatsView();
        $.statsDelegate = new StatsViewDelegate($.statsView);

    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView(){
        return [$.statsView, $.statsDelegate];
    }

}

function getApp() as mainApp {
    return Application.getApp() as mainApp;
}
