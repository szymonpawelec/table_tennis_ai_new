import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Position;


class StatsViewDelegate extends WatchUi.BehaviorDelegate {

    private var _statsView;

    function initialize(statsView) {
        self._statsView = statsView;
        BehaviorDelegate.initialize();
    }
    
    function onLocationEvent(_oInfo as Position.Info) as Void {
    }

    function onKey(keyEvent) {

        switch (keyEvent.getKey()) {
            case 4:
                if((!$.config.trialExpired | $.config.isUnlocked) & !(_statsView.displayIndex == 3)){
                    var strokeView = new StrokeMonitorView();
                    var strokeDelegate = new StrokeMonitorDelegate();
                    WatchUi.pushView(strokeView, strokeDelegate, WatchUi.SLIDE_IMMEDIATE);
                } else if(_statsView.displayIndex == 3) {
                    _statsView.skipToNextTraining();
                    WatchUi.requestUpdate();
                }
                // System.println("START/STOP button was pressed");
                break;
            case 5:
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                // System.println("BACK/LAP button was pressed");
                break;
            case 8:
                self._statsView.nextType();
                WatchUi.requestUpdate();
                // System.println("PAGE DOWN button was pressed");
                break;
            case 13:
                self._statsView.previousType();
                WatchUi.requestUpdate();
                // System.println("PAGE UP button was pressed");
                break;
            default:
                // System.println("No known button pressed!");
        }

        self._statsView.noAction = false;

        return true;
    }

    function onNextPage() as Boolean {
        self._statsView.nextType();
        WatchUi.requestUpdate();
        
        self._statsView.noAction = false;
        return true;
    }

    function onPreviousPage() as Boolean {
        self._statsView.previousType();
        WatchUi.requestUpdate();

        self._statsView.noAction = false;
        return true;
    }

    function onMenu() as Boolean {
        var settingsMenu = new WatchUi.Menu();
        var settingsMenuDelegate = new SettingsMenuDelegate();
        settingsMenu.setTitle($.config.langText["settings"]);

        settingsMenu.addItem($.config.langText["about"], :about);

        var gpsToggle;
        if ($.config.recordGps) {
            gpsToggle = "GPS [On]";
        } else {
            gpsToggle = "GPS [Off]";
        }
        settingsMenu.addItem(gpsToggle, :recordgps);

        var darkToggle;
        if ($.config.darkMode) {
            darkToggle = $.config.langText["dark"] + " [On]";
        } else {
            darkToggle = $.config.langText["dark"] + " [Off]";
        }
        settingsMenu.addItem(darkToggle, :darkmode);

        var darkMenuToggle;
        if ($.config.darkMenuMode) {
            darkMenuToggle = $.config.langText["darkmenu"] + " [On]";
        } else {
            darkMenuToggle = $.config.langText["darkmenu"] + " [Off]";
        }
        settingsMenu.addItem(darkMenuToggle, :darkmenumode);

        var leftToggle;
        if ($.config.leftHanded) {
            leftToggle = $.config.langText["left"] + " [On]";
        } else {
            leftToggle = $.config.langText["left"] + " [Off]";
        }
        settingsMenu.addItem(leftToggle, :lefthanded);

        settingsMenu.addItem($.config.langText["sensitivity"], :sensitivity);

        var recordToggle;
        if ($.config.recordAccel) {
            recordToggle = $.config.langText["dev_mode"] + " [On]";
        } else {
            recordToggle = $.config.langText["dev_mode"] + " [Off]";
        }
        settingsMenu.addItem(recordToggle, :recordaccel);

        settingsMenu.addItem($.config.langText["trainings"], :trainings);

        settingsMenu.addItem($.config.langText["back"], :back);
        WatchUi.pushView(settingsMenu, settingsMenuDelegate, WatchUi.SLIDE_IMMEDIATE);

        self._statsView.noAction = false;
        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent){
        // System.println(clickEvent.getCoordinates()); // e.g. [36, 40]
        // System.println(clickEvent.getType().toString());        // CLICK_TYPE_TAP = 0
        if (clickEvent.getCoordinates()[0] < $.config.screenWidth/6) {
            onMenu();
        }
        
        self._statsView.noAction = false;
        return true;
    }

    function onShow(dc) as Void {   
        return;
    }

}