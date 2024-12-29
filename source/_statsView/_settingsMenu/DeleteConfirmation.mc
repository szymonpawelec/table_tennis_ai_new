using Toybox.WatchUi;
using Toybox.System;

class DeleteConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var id;
    function initialize(i) {
        self.id = i;
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            return false;
        } else {
            $.trainingStats.removeTraining(self.id);
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
            return true;
        }
    }
}