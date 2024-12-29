import Toybox.WatchUi;
using Toybox.Position;

class SaveMenuDelegate extends WatchUi.MenuInputDelegate {
    
    public var discard = false;
    
    function onLocationEvent(_oInfo as Position.Info) as Void {
    }
    function onMenuItem(item) {
        if ( item == :save ) {
            WatchUi.pushView(
                new WatchUi.Confirmation($.config.langText["save"] + "?"),
                new SaveConfirmationDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
        } else if ( item == :resume ) {
            // Enable Activity recording
            session.start();
            // Enable Strokes Monitor
            $.strokesMonitor.enableAccel();
            // Enable position events
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocationEvent));
            
            // Play tone and virate for activity start
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

        } else if ( item == :discard ) {
            
            WatchUi.pushView(
                new WatchUi.Confirmation($.config.langText["discard"] + "?"),
                new DiscardConfirmationDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );
        }
    }
}