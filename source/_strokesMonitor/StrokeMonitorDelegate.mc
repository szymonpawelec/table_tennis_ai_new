import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Position;
var session = null;


class StrokeMonitorDelegate extends WatchUi.BehaviorDelegate {

    private var saveMenu = new WatchUi.Menu();
    private var saveMenuDelegate = new SaveMenuDelegate();

    function initialize() {
        self.handleActivity();  
        BehaviorDelegate.initialize();
        saveMenu.setTitle($.config.langText["paused"]);
        saveMenu.addItem($.config.langText["resume"], :resume);
        saveMenu.addItem($.config.langText["save"], :save);
        saveMenu.addItem($.config.langText["discard"], :discard);
         
    }
    
    function onLocationEvent(_oInfo as Position.Info) as Void {
    }

    function onKey(keyEvent) {

        switch (keyEvent.getKey()) {
            case 4:
                // System.println("START/STOP button was pressed");
                self.handleActivity();
                break;
            case 5:
                // System.println("BACK/LAP button was pressed");
                if (Toybox has :ActivityRecording) {
                    if (session == null) {
                        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                    }
                    else if ((session != null) && session.isRecording()) {
                        $.strokesHistory.addFoul();
                    }
                    else if ((session != null) && !session.isRecording()) {
                        WatchUi.pushView(saveMenu, saveMenuDelegate, WatchUi.SLIDE_IMMEDIATE);
                    }
                }
                break;
            case 8:
                // System.println("PAGE DOWN button was pressed");
                        $.strokesHistory.addWinner();
                break;
            case 13:
                // System.println("PAGE UP button was pressed");
                break;
            default:
                // System.println("No known button pressed!");
        }

        return true;
    }

    function onMenu() as Boolean {
        return true;
    }
    
    function onSwipe(evt) {
        var direction = evt.getDirection();
        switch(direction) {
            case SWIPE_LEFT: $.strokesHistory.addWinner(); break;
            case SWIPE_RIGHT: $.strokesHistory.addFoul(); break;
        }
        return true;
    }

    // use the select Start/Stop or touch for recording
    function handleActivity() {

        var vibeData = null;
        if (Attention has :vibrate) {
            vibeData =
            [
                new Attention.VibeProfile(50, 1000), // On for two seconds
            ];
            Attention.vibrate(vibeData);
        }

        if (Toybox has :ActivityRecording) {
            if (session == null) {

                $.strokesHistory = new TennisStrokeHistory();
                $.strokesMonitor = new TennisStrokesMonitorMax();

                // https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html
                if ((Activity has :SUB_SPORT_TABLE_TENNIS) & (Activity has :SPORT_RACKET)) {
                    session = ActivityRecording.createSession({
                        :name=>$.config.langText["app_name"],
                        :sport=>Activity.SPORT_RACKET,
                        :subSport=>Activity.SUB_SPORT_TABLE_TENNIS
                    });
                } else {
                    session = ActivityRecording.createSession({
                        :name=>$.config.langText["app_name"],
                        :sport=>Activity.SPORT_TENNIS,
                        :subSport=>Activity.SUB_SPORT_GENERIC
                    });
                }

                $.strokesMonitor.enableAccel();

                // Enable position events
                if($.config.recordGps) {
                    Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocationEvent));
                }

                session.start();

                // Time for display timer
                $.strokesHistory.activityStartTime = Toybox.Time.now();
                // Date for training stats data storage
                $.strokesHistory.activityStartDate = Toybox.Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

                // Play tone for activity start
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_START);
                }

                // Create the custom FIT data field we want to record.
                $.dataFields.createDataField("fh");
                $.dataFields.createDataField("bh");
                $.dataFields.createDataField("sv");
                $.dataFields.createDataField("bs");
                $.dataFields.createDataField("fs");
                $.dataFields.createDataFieldTotal();

                $.dataFields.createDataFieldAccelerometer();

            } else if ((session != null) && !session.isRecording()) {
                // Enable Activity recording
                session.start();
                // Enable Strokes Monitor
                $.strokesMonitor.enableAccel();
                // Enable position events
                if($.config.recordGps) {
                    Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocationEvent));
                }
                // Play tone for activity start
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_START);
                }

            } else if ((session != null) && session.isRecording()) {
                // Disable position events
                if($.config.recordGps) {
                    Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onLocationEvent));
                }
                $.strokesMonitor.disableAccel();
                session.stop();                                      // stop the session
                // Play tone for activity stop
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_STOP);
                }
                // Display save menu
                WatchUi.pushView(saveMenu, saveMenuDelegate, WatchUi.SLIDE_IMMEDIATE);
            }
        }

        return true;                                                 // return true for onSelect function
    }

    function onTap(clickEvent as WatchUi.ClickEvent){
        var touchCoord = clickEvent.getCoordinates();   // e.g. [36, 40]
        var touchType = clickEvent.getType().toString().toNumber();    // CLICK_TYPE_TAP = 0
        var rad = $.config.screenWidth/2;

        // handle SCORE/FAULT touch events
        if((touchType == CLICK_TYPE_TAP) & (touchCoord[1] > rad)){
            if(touchCoord[0] > rad*7/6){
                $.strokesHistory.addFoul();
            } else if(touchCoord[0] < rad*5/6) {
                $.strokesHistory.addWinner();
            }
        }

        return true;
    }

    function onShow(dc) as Void {
        return;
    }

}