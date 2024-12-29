import Toybox.WatchUi;

class TrainingsMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _symbols;

    
    function initialize(symbols) {
        self._symbols = symbols;
    }

    function onMenuItem(item) {
        
        for( var i = 0; i < self._symbols.size(); i += 1 ) {

            if ( item == self._symbols[i] ) {
                
            
                WatchUi.pushView(
                    new WatchUi.Confirmation($.config.langText["delete_train"]),
                    new DeleteConfirmationDelegate(i),
                    WatchUi.SLIDE_IMMEDIATE
                );
            }
        }
    }
}
