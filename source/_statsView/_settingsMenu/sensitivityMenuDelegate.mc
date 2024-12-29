import Toybox.WatchUi;

class SensitivityMenuDelegate extends WatchUi.MenuInputDelegate {

    function onMenuItem(item) {
        if ( item == :increase ) {
            if($.config.sensitivity < 15){
                $.config.sensitivity += 1;
            } else {
                $.config.sensitivity = 15;
            }
        } else if ( item == :decrease ) {
            if($.config.sensitivity > 1){
                $.config.sensitivity -= 1;
            } else {
                $.config.sensitivity = 1;
            }
        }
        
        $.config.updateSensitivity();
    }
}
