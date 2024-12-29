using Toybox.WatchUi;
using Toybox.System;

class DiscardConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            return false;
        } else {
            session.discard();
            session = null;
            
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

            // Play tone and vibrate for saving activity
            if (Attention has :playTone) {
                Attention.playTone(Attention.TONE_START);
            }
            var vibeData = null;
            if (Attention has :vibrate) {
                vibeData =
                [
                    new Attention.VibeProfile(50, 1000), // On for two seconds
                ];
                Attention.vibrate(vibeData);
            }
            return true;
        }
    }
}