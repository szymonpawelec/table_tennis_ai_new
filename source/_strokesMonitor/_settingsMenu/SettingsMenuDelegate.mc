import Toybox.WatchUi;

class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {
    const _symbols = [
    :symbol0,
    :symbol1,
    :symbol2,
    :symbol3,
    :symbol4,
    :symbol5,
    :symbol6,
    :symbol7,
    :symbol8,
    :symbol9,
    :symbol10,
    :symbol11,
    :symbol12,
    :symbol13,
    :symbol14,
    :symbol15,
    :symbol16,
    :symbol17,
    :symbol18,
    :symbol19,
    :symbol20,
    :symbol21,
    :symbol22,
    :symbol23,
    :symbol24,
    :symbol25,
    :symbol26,
    :symbol27,
    :symbol28,
    :symbol29
    ];

    function onMenuItem(item) {
        if ( item == :recordaccel ) {
            $.config.toggleAccelRecord();
        } else if ( item == :recordgps ) {
            $.config.toggleGpsRecord();
        } else if ( item == :darkmode ) {
            $.config.toggleDarkMode();
        } else if ( item == :darkmenumode ) {
            $.config.toggleDarkMenuMode();
        } else if ( item == :lefthanded ) {
            $.config.toggleLeftHand();
        } else if ( item == :sensitivity ) {
            var sensitivityMenu = new WatchUi.Menu();
            var sensitivityMenuDelegate = new SensitivityMenuDelegate();
            sensitivityMenu.setTitle($.config.langText["sensitivity"] + ": " + $.config.sensitivity + "/15");
            sensitivityMenu.addItem($.config.langText["increase"] + " +", :increase);
            sensitivityMenu.addItem($.config.langText["decrease"] + " -", :decrease);

            WatchUi.pushView(sensitivityMenu, sensitivityMenuDelegate, WatchUi.SLIDE_UP);
        }  else if ( item == :trainings ) {
            var trainingsMenu = new WatchUi.Menu();
            var trainingsMenuDelegate = new TrainingsMenuDelegate(self._symbols);

            trainingsMenu.setTitle($.config.langText["trainings"]);
            for( var i = 0; i < $.config.trainingHistoryLength; i += 1 ) {
                var label = $.trainingStats.trainingDates[$.config.trainingHistoryLength - 1 - i];
                if(label != null){
                    trainingsMenu.addItem(label,self._symbols[i]);
                }
            }
            WatchUi.pushView(trainingsMenu, trainingsMenuDelegate, WatchUi.SLIDE_UP);
            
        } else if ( item == :about ) {
            var trainingsMenu = new WatchUi.Menu();
            var trainingsMenuDelegate = new TrainingsMenuDelegate(self._symbols);
            WatchUi.pushView(new AboutView(), new AboutViewDelegate(), WatchUi.SLIDE_UP);
            
        } else if ( item == :back ) {
        }
    }
}
