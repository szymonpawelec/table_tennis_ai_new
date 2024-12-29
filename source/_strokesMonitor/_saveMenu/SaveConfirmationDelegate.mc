using Toybox.WatchUi;
using Toybox.System;


class SaveConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    private var _saveCheck = true;

    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            return false;
        } else {
            if(_saveCheck){
                _saveCheck = false;
                session.save();
                session = null;

                // Store training statistics in memory
                $.trainingStats.saveTrainingStatistics();

                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

                // Play tone and vibrate for discarding activity
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_RESET);
                }
                var vibeData = null;
                if (Attention has :vibrate) {
                    vibeData =
                    [
                        new Attention.VibeProfile(50, 1000), // On for two seconds
                    ];
                    Attention.vibrate(vibeData);
                }
            }
            return true;
        }
    }
}