using Toybox.System;
import Toybox.Application;
using Toybox.Time.Gregorian;

class Config  {

    public var appVerMajor = 2;
    public var appVerMinor = 0;
    public var appVerPatch = 0;
    public var appVerStage = "";
    public var appType = "H";

    public var welcomeMsg = ["  Put watch on hand", "which holds the paddle"];
    public var updateMsg = ["- New interface implemented"];

    public var trialDays = 20;
    public var trialDaysWarning = 10;
    public var trialDaysRemaining;
    public var trialExpired = false;
    public var trialEndYear;
    public var trialEndMonth;
    public var trialEndDay;

    public var langText = null;

    public var isUnlocked = false;
    public var verificationCode;
    public var masterCode;
    public var unlockCode;
    public var licenseToken;
    public var licenseExpired = false;
    public var licenseDuration = 183;

    public var appVersion = "v" + appVerMajor.toString() + "." + appVerMinor.toString() + "." + appVerPatch.toString() + appVerStage.toString();
    public var appFirstRun;
    public var appVersionChange = false;
    public var lastAppVerMajor;
    public var lastAppVerMinor;
    public var lastAppVerPatch;
    public var wasPayLinkDisplayed = false;

    public var recordAccel = false;
    public var recordGps = false;
    public var darkMode = true;
    public var darkMenuMode = false;
    public var leftHanded = false;
    public var sensitivity;

    public var strokeThreshold = 1.2e+8;
    public var signalThreshold = 1900;
    public var defaultSensitivity = 11;

    public var strokeSignalMaxScale = 10800;

    public var trainingHistoryLength = 20;

    public var screenWidth = 240;

    // time the stroke is retained on the graph
    public var graphDataRetention = 4;

    public var strokeMaxScale = {
        "fh" => 3.3e+8,
        "bh" => 2.1e+8,
        "sv" => 2.3e+8,
        "bs" => 2.5e+8,
        "fs" => 1.5e+8};

    public var strokeName = {
        "fh" => "Forehand",
        "bh" => "Backhand",
        "sv" => "Serve",
        "bs" => "Slice",
        "fs" => "F Slice"};

    public var strokeTypes = ["fh", "bh"];
    public var strokeTypesView = ["fh", "bh"];


    public var strokeFilterTypes = [
        "fh",
        "bh",
        "bhj",
        "bhk",
        "sv",
        "sv_stv",
        "sv_stv_shft",
        "sv_paw",
        "sv_krsh",
        "sv_matgo",
        "sv_flat_self",
        "sv_flat_self_shift",
        "bs",
        "bsj",
        "fs",
        "ob",
        "obj"
        ];

    public var strokeTypesAssign = {
        "fh" => "fh",
        "bh" => "bh",
        "bhj" => "bh",
        "bhk" => "bh",
        "sv" => "fh",
        "sv_stv" => "fh",
        "sv_stv_shft" => "fh",
        "sv_paw" => "fh",
        "sv_krsh" => "fh",
        "sv_matgo" => "fh",
        "sv_flat_self" => "fh",
        "sv_flat_self_shift" => "fh",
        "bs" => "bh",
        "bsj" => "bh",
        "fs" => "fh",
        "ob" => "bh",
        "obj" => "bh"};

    public var strokeTypeLoop = {
        "fh" => "bh",
        "bh" => "sv",
        // "sv" => "bs",
        // "bs" => "fs",
        // "fs" => "fh"
        };

    public var strokeColor = {
        "fh" => Graphics.COLOR_RED,
        "bh" => Graphics.COLOR_DK_BLUE,
        "sv" => Graphics.COLOR_DK_GREEN,
        "bs" => Graphics.COLOR_YELLOW,
        "fs" => Graphics.COLOR_PINK};
    
    public var colStroke = {
        "fh" => Graphics.COLOR_RED,
        "bh" => Graphics.COLOR_DK_BLUE,
        "sv" => Graphics.COLOR_DK_GREEN,
        "bs" => Graphics.COLOR_YELLOW,
        "fs" => Graphics.COLOR_PINK};
    
    private var _whiteTheme = {
        "colBgd" => Graphics.COLOR_WHITE,
        "colBgdLines" => Graphics.COLOR_BLACK,
        "colBgdGrid" => Graphics.COLOR_LT_GRAY,
        "colBarBgd" => Graphics.COLOR_DK_GRAY,
        "colPowerBgd" => Graphics.COLOR_LT_GRAY,
        "colPowerBar" => Graphics.COLOR_DK_RED,
        "colMaxPowerLine" => Graphics.COLOR_BLACK,
        "colStatsGrid" => Graphics.COLOR_BLACK,
        "colStatsCountBar" => Graphics.COLOR_DK_GRAY,
        "colText" => Graphics.COLOR_BLACK,
        "colTextStrokeBar" => Graphics.COLOR_WHITE,
        "colTextStrokeLast" => Graphics.COLOR_WHITE,
        "colTextActive" => Graphics.COLOR_RED,
        "colAvgTotalGraph" => Graphics.COLOR_BLACK,
        "colLeadZeros" => Graphics.COLOR_LT_GRAY
    };

    private var _blackTheme = {
        "colBgd" => Graphics.COLOR_BLACK,
        "colBgdLines" => Graphics.COLOR_WHITE,
        "colBgdGrid" => Graphics.COLOR_DK_GRAY,
        "colBarBgd" => Graphics.COLOR_BLACK,
        "colPowerBgd" => Graphics.COLOR_LT_GRAY,
        "colPowerBar" => Graphics.COLOR_DK_RED,
        "colMaxPowerLine" => Graphics.COLOR_BLACK,
        "colStatsGrid" => Graphics.COLOR_WHITE,
        "colStatsCountBar" => Graphics.COLOR_LT_GRAY,
        "colText" => Graphics.COLOR_WHITE,
        "colTextStrokeBar" => Graphics.COLOR_WHITE,
        "colTextStrokeLast" => Graphics.COLOR_WHITE,
        "colTextActive" => Graphics.COLOR_RED,
        "colAvgTotalGraph" => Graphics.COLOR_DK_BLUE,
        "colLeadZeros" => Graphics.COLOR_DK_GRAY
    };

    public var penThin = 1;
    public var penMed = 2;
    public var penThick = 3;

    public var scaleIncrement = 10;

    public var fontLarge = Application.loadResource(Rez.Fonts.large);
    public var fontMedium = Application.loadResource(Rez.Fonts.medium);
    public var fontSmall = Application.loadResource(Rez.Fonts.small);
    public var fontIcons = Application.loadResource(Rez.Fonts.icons);

    public var fontLastStroke = Graphics.FONT_TINY;
    public var fontStrokeCount = Graphics.FONT_TINY;
    public var fontStrokeTotal = Graphics.FONT_TINY;
    public var fontStoper = Graphics.FONT_LARGE;
    public var fontTime = Graphics.FONT_TINY;
    public var fontStatsTitle = Graphics.FONT_LARGE;

    function initialize() {
        var dev = System.getDeviceSettings();
        if (dev has :systemLanguage) {
            if (System.LANGUAGE_POL == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.polJson);
            } else if (System.LANGUAGE_DEU == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.deuJson);
            } else if (System.LANGUAGE_FRE == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.freJson);
            } else if (System.LANGUAGE_ITA == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.itaJson);
            } else if (System.LANGUAGE_POR == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.porJson);
            } else if (System.LANGUAGE_SPA == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.spaJson);
            } else if (System.LANGUAGE_DUT == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.dutJson);
            } else if (System.LANGUAGE_GRE == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.greJson);
            } else if (System.LANGUAGE_CES == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.cesJson);
            } else if (System.LANGUAGE_HUN == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.hunJson);
            } else if (System.LANGUAGE_RON == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.ronJson);
            } else if (System.LANGUAGE_DAN == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.danJson);
            } else if (System.LANGUAGE_SWE == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.sweJson);
            } else if (System.LANGUAGE_NOB == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.nobJson);
            } else if (System.LANGUAGE_FIN == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.finJson);
            } else if (System.LANGUAGE_IND == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.indJson);
            } else if (System.LANGUAGE_CHS == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.engJson);
            } else if (System.LANGUAGE_VIE == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.vieJson);
            } else if (System.LANGUAGE_JPN == dev.systemLanguage) {
                self.langText = Application.loadResource(Rez.JsonData.engJson);
            } else {
                self.langText = Application.loadResource(Rez.JsonData.engJson);
            }
        }
        self.welcomeMsg = [
            self.langText["put_watch"],
            self.langText["hold_racket"]
           ];

        // read default settings for recording accelerometer data
        if (Application.Storage.getValue("recordAcceleration") == null) {
            self.recordAccel = false;
        } else {
            self.recordAccel = Application.Storage.getValue("recordAcceleration");
        }

        // read default settings for dark mode
        if (Application.Storage.getValue("darkMode") == null) {
            self.darkMode = Properties.getValue("propDark");
        } else {
            // decomissioning old settings based on storage
            self.darkMode = Application.Storage.getValue("darkMode");
            Application.Storage.setValue("darkMode", null);
            Properties.setValue("propDark", self.darkMode);
        }
        
        // read default settings for dark MENU mode
        self.darkMenuMode = Properties.getValue("propDarkMenu");

        // read default settings for left hand
        if (Application.Storage.getValue("leftHanded") == null) {
            self.leftHanded = Properties.getValue("propLeft");
        } else {
            // decomissioning old settings based on storage
            self.leftHanded = Application.Storage.getValue("leftHanded");
            Application.Storage.setValue("leftHanded", null);
            Properties.setValue("propLeft", self.leftHanded);
        }

        // read default settings for sensitivity
        if (Application.Storage.getValue("sensitivity") == null) {
            self.sensitivity = Properties.getValue("propSensitivity");
        } else {
            // decomissioning old settings based on storage
            self.sensitivity = Application.Storage.getValue("sensitivity");
            Application.Storage.setValue("sensitivity", null);
            Properties.setValue("propSensitivity", self.sensitivity);
        }
        
        // read default settings for license
        if (Application.Storage.getValue("licenseToken") == null) {
            self.licenseToken = {
                "dev_reg_status" => -1,
                "unlocked" => self.isUnlocked,
                "validity" => {
                    "year" => 2024,
                    "month" => 1,
                    "day" => 1
                }};
            Storage.setValue("licenseToken", self.licenseToken);
        } else {
            self.licenseToken = Application.Storage.getValue("licenseToken");
        }
        // code tied to device
        var id = System.getDeviceSettings().uniqueIdentifier.toLower().toCharArray();
        self.verificationCode = id[0] + id[2] + id[4] + id[6] + id[8] + id[10];
        // unlock code master generated based on device code
        var crypto = new Crypto();
        self.masterCode = crypto.generateUnlockMaster((self.verificationCode).toCharArray());

        // unlock code entered by user
        self.unlockCode = Properties.getValue("unlockCode").toLower().toCharArray();
        // replace string if user entered too short code
        if((self.unlockCode.size() != 0) & (self.unlockCode.size() < 6)){
            self.unlockCode = ("000000").toCharArray();
        }

        // if Forerunner55 is used replace color for main screen stats:
        var verPartNumber = dev.partNumber;
        if ( verPartNumber.equals("006-B3869-00") ) {
            var col = Graphics.COLOR_PINK;
            _whiteTheme["colAvgTotalGraph"] = col;
            _blackTheme["colAvgTotalGraph"] = col;
            self.strokeColor["bs"] = col;
            self.colStroke["bs"] = col;
        }

        // if Venu2sq is used replace font size:
        if (verPartNumber.equals("006-B4115-00") | verPartNumber.equals("006-B4116-00")) {
            self.fontStoper = Graphics.FONT_SMALL;
            self.fontTime = Graphics.FONT_XTINY;
            self.fontStatsTitle = Graphics.FONT_SMALL;
        }
        
    }

    public function getColorPalette(darkmode) as Toybox.Lang.Dictionary {
        var colorPalette;
        if(darkmode) {
            colorPalette = self._blackTheme;
        } else {
            colorPalette = self._whiteTheme;
        }
        return colorPalette;
    }

    public function checkCode() as Toybox.Lang.Boolean {
        // check if manually entered license code is correct
        if(self.unlockCode.size() == 6){
            if(
                ((self.unlockCode[0] == self.masterCode[0]) & 
                (self.unlockCode[1] == self.masterCode[1]) & 
                (self.unlockCode[2] == self.masterCode[2]) & 
                (self.unlockCode[3] == self.masterCode[3]) & 
                (self.unlockCode[4] == self.masterCode[4]) & 
                (self.unlockCode[5] == self.masterCode[5]))
                ) { 
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    public function checkUnlock() as Void {

        if ($.config.licenseToken["dev_reg_status"] == -2) {
            // -2 - License already created based on manually entered code
            // System.println("License already created based on manually entered code");
            if (self.checkCode()){
                // System.println("Code correct");
                self.licenseToken["unlocked"] = true;
            } else {
                // System.println("Code incorrect");
                self.licenseToken["unlocked"] = false;
            }
            Storage.setValue("licenseToken", self.licenseToken);
        } else if ($.config.licenseToken["dev_reg_status"] == -1) {
            // -1 - License was not created on device yet
            // System.println("License was not created on device yet");
            if (self.checkCode()){
                // System.println("Code correct");
                
                // set up trial start / expiration dates and store it
                var start = new Time.Moment(Time.today().value());
                var trialDuration = new Time.Duration(Gregorian.SECONDS_PER_DAY*self.licenseDuration);
                var end = start.add(trialDuration);
                var endGreg = Toybox.Time.Gregorian.info(end, Time.FORMAT_SHORT);

                self.licenseToken["unlocked"] = true;
                self.licenseToken["validity"] = {
                    "year" => endGreg.year,
                    "month" => endGreg.month,
                    "day" => endGreg.day,
                    };
                self.licenseToken["dev_reg_status"] = -2;
                Storage.setValue("licenseToken", self.licenseToken);
            }
        }

        // System.println("License check:");
        // System.println(self.licenseToken);
        
        // // check if license expired
        var options = {
            :year   => self.licenseToken["validity"]["year"],
            :month  => self.licenseToken["validity"]["month"],
            :day    => self.licenseToken["validity"]["day"],
        };
        var expire = Gregorian.moment(options);

        var comparison = (expire.compare(new Time.Moment(Time.today().value()))/Gregorian.SECONDS_PER_DAY).toNumber();
        if (comparison > 0) {
            self.licenseExpired = false;
            // System.println("LICENSE NOT EXPIRED");
        } else {
            self.licenseExpired = true;
            // System.println("LICENSE EXPIRED");
        }

        if(self.licenseToken["unlocked"] & !self.licenseExpired){
            self.isUnlocked = true;
        } else {
            self.isUnlocked = false;
        }

    }

    public function checkVersion() as Void {
        // check if it is a first use of application
        if (Application.Storage.getValue("appFirstRun") == null) {
            // setup first app use
            self.appFirstRun = true;
            Storage.setValue("appFirstRun", false);

            // set up trial start / expiration dates and store it
            var start = new Time.Moment(Time.today().value());
            var trialDuration = new Time.Duration(Gregorian.SECONDS_PER_DAY*$.config.trialDays);
            var end = start.add(trialDuration);
            var endGreg = Toybox.Time.Gregorian.info(end, Time.FORMAT_SHORT);
            var endStr = endGreg.year + "/" + endGreg.month + "/" + endGreg.day;
            self.trialDaysRemaining = self.trialDays;

            self.trialEndYear = endGreg.year;
            self.trialEndMonth = endGreg.month;
            self.trialEndDay = endGreg.day;
            Storage.setValue("trialEndYear", self.trialEndYear);
            Storage.setValue("trialEndMonth", self.trialEndMonth);
            Storage.setValue("trialEndDay", self.trialEndDay);


            // initialize app versioning control
            self.lastAppVerMajor = self.appVerMajor;
            self.lastAppVerMinor = self.appVerMinor;
            self.lastAppVerPatch = self.appVerPatch;
            Storage.setValue("lastAppVerMajor", self.lastAppVerMajor);
            Storage.setValue("lastAppVerMinor", self.lastAppVerMinor);
            Storage.setValue("lastAppVerPatch", self.lastAppVerPatch);
        } else {
            // setup not first time use
            self.appFirstRun = false;
            
            self.trialEndYear = Application.Storage.getValue("trialEndYear");
            self.trialEndMonth = Application.Storage.getValue("trialEndMonth");
            self.trialEndDay = Application.Storage.getValue("trialEndDay");

            var options = {
                :year   => self.trialEndYear,
                :month  => self.trialEndMonth,
                :day    => self.trialEndDay,
            };
            var expire = Gregorian.moment(options);
            var expireGreg = Toybox.Time.Gregorian.info(expire, Time.FORMAT_SHORT);
            var endStr = expireGreg.year + "/" + expireGreg.month + "/" + expireGreg.day;

            // compare expiration with tooday
            var oneDay = Gregorian.SECONDS_PER_DAY;
            var comparison = (expire.compare(new Time.Moment(Time.today().value()))/oneDay).toNumber();
            self.trialDaysRemaining = comparison;
            if (self.trialDaysRemaining < 1) {
                self.trialExpired = true;
            }

            self.lastAppVerMajor = Application.Storage.getValue("lastAppVerMajor");
            self.lastAppVerMinor = Application.Storage.getValue("lastAppVerMinor");
            self.lastAppVerPatch = Application.Storage.getValue("lastAppVerPatch");

            // update last version in storage
            Storage.setValue("lastAppVerMajor", self.appVerMajor);
            Storage.setValue("lastAppVerMinor", self.appVerMinor);
            Storage.setValue("lastAppVerPatch", self.appVerPatch);

            // check if version changed
            if((self.lastAppVerMajor != self.appVerMajor) |
               (self.lastAppVerMinor != self.appVerMinor) |
               (self.lastAppVerPatch != self.appVerPatch)) {
                self.appVersionChange = true;
                } else {
                self.appVersionChange = false;
            }
        }

        return;
    }

    public function toggleAccelRecord() as Void {
        if(self.recordAccel){
            self.recordAccel = false;
            } else {
                self.recordAccel = true;
            }
        Storage.setValue("recordAcceleration", self.recordAccel);
    }

    public function toggleDarkMode() as Void {
        if(self.darkMode){
            self.darkMode = false;
            } else {
                self.darkMode = true;
            }
        System.println("toggle: " + self.darkMode);
        Properties.setValue("propDark", self.darkMode);
        // Storage.setValue("darkMode", self.darkMode);
    }
    
    public function toggleDarkMenuMode() as Void {
        if(self.darkMenuMode){
            self.darkMenuMode = false;
            } else {
                self.darkMenuMode = true;
            }
        Properties.setValue("propDarkMenu", self.darkMenuMode);
    }

    public function toggleLeftHand() as Void {
        if(self.leftHanded){
            self.leftHanded = false;
            } else {
                self.leftHanded = true;
            }
        Properties.setValue("propLeft", self.leftHanded);
        // Storage.setValue("leftHanded", self.leftHanded);
    }
    
    public function updateSensitivity() as Void {
            Properties.setValue("propSensitivity", self.sensitivity);
    }
        
}