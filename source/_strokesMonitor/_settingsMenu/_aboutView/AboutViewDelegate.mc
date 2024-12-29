import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Position;


class AboutViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
        $.dataConnection.getLicense();
    }

    function onShow(dc) as Void {   
        return;
    }

}