import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
using Toybox.Graphics;
using Toybox.ActivityRecording;
import Toybox.Lang;
using Toybox.Math;

class StatsView extends WatchUi.View {

    public var displayIndex = 0;
    public var noAction = true;
    private var _color;
    private var _rad;
    private var _statsNumber = 0;
    private var _statsActiveNumber = 20;

    function initialize() {
        _color = $.config.getColorPalette($.config.darkMenuMode);

        View.initialize();
        
    }

    function skipToNextTraining() as Void {
        if(_statsActiveNumber > 20 - _statsNumber) {
            _statsActiveNumber--;
        }
    }

    function checkTrainings() as Void {
        // Check how many trainings are already recorded
        self._statsNumber = 0;
        for( var i = 0; i < 20; i += 1 ) {
            if($.trainingStats.trainingDates[i] != null){
                self._statsNumber += 1;
            }
        }
        self._statsActiveNumber -= 1; // reset training stats indicator
        if(self._statsActiveNumber < 20 - self._statsNumber){
            self._statsActiveNumber = 20 - self._statsNumber;
        }
    }

    function nextType() as Void {
        self.displayIndex++;
        self.checkTrainings();

        if (self.displayIndex > $.config.strokeTypesView.size() + 1) {
            self.displayIndex = 0;
        }
        // if  there are no trainings recorded
        if(self._statsNumber == 0){
            self.displayIndex = 0;
        }
    }

    function previousType() as Void {
        self.displayIndex--;
        self.checkTrainings();

        if (self.displayIndex < 0) {
            self.displayIndex = $.config.strokeTypesView.size() + 1;
        }
        // if  there are no trainings recorded
        if(self._statsNumber == 0){
            self.displayIndex = 0;
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _color = $.config.getColorPalette($.config.darkMenuMode);

        if ((($.config.trialDaysRemaining < $.config.trialDaysWarning + 1) &
                    ($.config.trialDaysRemaining > 0) &
                    !$.config.isUnlocked) | ($.config.trialExpired & !$.config.isUnlocked)) {
            // Warning when free trial is about to expire
            if(!$.config.wasPayLinkDisplayed) {
                $.dataConnection.goToPayment();
                $.config.wasPayLinkDisplayed = true;
            }
        }
    }

    function onHide() as Void {
        self.displayIndex = 0;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLACK, _color["colBgd"]);
        dc.clear();
        
        self._rad = dc.getWidth()/2;
        $.config.screenWidth = self._rad*2;
        
        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        // select stats screen
        if(self.displayIndex == 0) {
            self._statsActiveNumber = 20; // reset training stats indicator
            self.drawMainScreen(dc);
        } else if (
            (self.displayIndex == $.config.strokeTypesView.size() + 1) &
            (self._statsNumber > 0)) {
    
            self.drawTrainingStatsScreen(dc as Dc);
        }
        else {
            self._statsActiveNumber = 20; // reset training stats indicator
            var type = $.config.strokeTypesView[self.displayIndex-1];
            self.drawStrokeStatsScreen(dc, type);
        }

        if(self.displayIndex != $.config.strokeTypesView.size() + 1){
            self.drawMenuHightlight(dc, .2*self._rad, self._rad/7);
        }

        // draw START training indicator
        if(!($.config.appFirstRun & ($.config.trainingStats.totalCount == 0)) & (displayIndex != 3)){
            dc.setColor(Graphics.COLOR_GREEN, -1);
            dc.setPenWidth(self._rad/5);
            dc.drawArc(self._rad, self._rad, self._rad, Graphics.ARC_CLOCKWISE, 40, 20);
        }

        // draw training toggle
        if(!($.config.appFirstRun & ($.config.trainingStats.totalCount == 0)) & (displayIndex == 3)){
            dc.setColor(Graphics.COLOR_DK_GRAY, -1);
            dc.setPenWidth(self._rad/10);
            dc.drawArc(self._rad, self._rad, self._rad, Graphics.ARC_CLOCKWISE, 39, 35);
            dc.drawArc(self._rad, self._rad, self._rad, Graphics.ARC_CLOCKWISE, 32, 28);
            dc.drawArc(self._rad, self._rad, self._rad, Graphics.ARC_CLOCKWISE, 25, 21);
        }

        // cover for sq devices
        dc.setColor(Graphics.COLOR_BLACK, -1);
        dc.setPenWidth(_rad*2);
        dc.drawArc(_rad, _rad, _rad*2, Graphics.ARC_CLOCKWISE, 0, 360);

    }

    function drawMenuHightlight(dc as Dc, height, width) as Void {
        dc.setColor(_color["colBgd"], -1);
        dc.fillRectangle(0, self._rad - height/2, width, height);

        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
        var gap = (height/7).toNumber();
        
        dc.setPenWidth(gap);
        dc.drawLine(0, self._rad - gap*2, width, self._rad - gap*2);
        dc.drawLine(0, self._rad, width, self._rad);
        dc.drawLine(0, self._rad + gap*2, width, self._rad + gap*2);
        
        dc.fillPolygon([
            [width, self._rad - height/2],
            [width - 2*gap, self._rad - height/2],
            [width - gap, self._rad - height/2 - gap*Math.pow(3,0.5)]
            ]);
        dc.fillPolygon([
            [width, self._rad + height/2],
            [width - 2*gap, self._rad + height/2],
            [width - gap, self._rad + height/2 + gap*Math.pow(3,0.5)]
            ]);
        
    }

    function drawMainScreen(dc as Dc) as Void {
        // main screen header
        var font = $.config.fontSmall;
        var fontOffsetVersion = dc.getFontHeight(font)/2;

        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
        dc.drawText(
            self._rad,
            self._rad/8 - fontOffsetVersion,
            font,
            $.config.appVersion,
            Graphics.TEXT_JUSTIFY_CENTER);


        font = $.config.fontMedium;
        var fontOffsetTitle = dc.getFontHeight(font)/2;
        dc.setColor(_color["colText"], -1);
        dc.drawText(
            self._rad,
            self._rad/3 - fontOffsetTitle + fontOffsetVersion/2,
            font,
            $.config.langText["app_name"],
            Graphics.TEXT_JUSTIFY_CENTER);

        // Update / welcome / expiration screen
        var fontMsg = $.config.fontSmall;
        var offsetMsg = dc.getFontHeight(fontMsg);
        if($.config.appFirstRun & ($.config.trainingStats.totalCount == 0)){
            // First use of the app
            dc.setColor(_color["colText"], -1);
            var appNamePos = self._rad/3 + fontOffsetTitle + offsetMsg/2;
            dc.drawText(
                self._rad,
                appNamePos,
                $.config.fontMedium,
                $.config.langText["welcome"],
                Graphics.TEXT_JUSTIFY_CENTER);
            for( var i = 0; i < $.config.welcomeMsg.size(); i += 1 ) {
                dc.drawText(
                    self._rad,
                    self._rad/3 + fontOffsetTitle/2 +(i+3)*offsetMsg,
                    fontMsg,
                    $.config.welcomeMsg[i],
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
            drawButtonPrompt(dc, _rad, "START", Graphics.COLOR_DK_GREEN, $.config.fontSmall, "START", Graphics.COLOR_WHITE, appNamePos + dc.getFontHeight($.config.fontSmall)/2);


        } else if (($.config.trialDaysRemaining < $.config.trialDaysWarning + 1) &
                    ($.config.trialDaysRemaining > 0) &
                    !$.config.isUnlocked) {
            // Warning when free trial is about to expire
            dc.setColor(_color["colText"], -1);
            dc.drawText(
                self._rad,
                self._rad - 3*offsetMsg,
                fontMsg,
                $.config.langText["exp_trial"],
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad - 2*offsetMsg,
                fontMsg,
                $.config.langText["exp_trial_in"] + ": " + $.config.trialDaysRemaining + " " + $.config.langText["days"],
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad - offsetMsg,
                fontMsg,
                $.config.langText["get_full"] + ":",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad,
                fontMsg,
                "www.sport-ai.net",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad + offsetMsg,
                fontMsg,
                $.config.langText["your_code"] + ": " + $.config.verificationCode + $.config.appType,
                Graphics.TEXT_JUSTIFY_CENTER);
        } else if ($.config.trialExpired & !$.config.isUnlocked) {
            // Warning when free trial has expired
            dc.setColor(Graphics.COLOR_RED, -1);
            dc.drawText(
                self._rad,
                self._rad - 2*offsetMsg,
                fontMsg,
                $.config.langText["expired"] + ".",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad - offsetMsg,
                fontMsg,
                $.config.langText["get_full"] + ":",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad,
                fontMsg,
                "www.sport-ai.net",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad + offsetMsg,
                fontMsg,
                $.config.langText["your_code"] + ": " + $.config.verificationCode + $.config.appType,
                Graphics.TEXT_JUSTIFY_CENTER);
        } else if ($.config.appVersionChange & self.noAction) {
            // App update info 
            dc.setColor(_color["colText"], -1);
            dc.drawText(
                self._rad,
                self._rad/3 + fontOffsetTitle/2 + offsetMsg/2,
                $.config.fontSmall,
                $.config.langText["changelog"] + ": ",
                Graphics.TEXT_JUSTIFY_CENTER);
            for( var i = 0; i < $.config.updateMsg.size(); i += 1 ) {
                dc.drawText(
                    self._rad/4,
                    self._rad/3 + fontOffsetTitle/2 +(i+1.8)*offsetMsg,
                    fontMsg,
                    $.config.updateMsg[i],
                    Graphics.TEXT_JUSTIFY_LEFT);
            }
        } else {
            self.drawMainStats(dc, self._rad*1/3, self._rad*2/3, self._rad*4/3, self._rad*2/3);

        }
        
        // bottom total count
        drawTotalCount(dc, $.trainingStats.totalCount, _color, _rad);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, -1);
        dc.setPenWidth(self._rad/10);
        dc.drawArc(self._rad, self._rad, self._rad, Graphics.ARC_CLOCKWISE, 0, 360);

    }

    function drawMainStats(dc as Dc, x_coor, y_coor, width, height) as Void{
        var scalePower = [0.25, 0.50, 0.75];
        var scaleData = $.trainingStats.historyLength;
        var totalCount = new[$.trainingStats.historyLength];

        for( var i = 0; i < $.trainingStats.historyLength; i += 1 ) {
            totalCount[i] = 0;
            for( var j = 0; j < $.config.strokeTypes.size(); j += 1 ) {
                var type = $.config.strokeTypes[j];
                totalCount[i] += $.trainingStats.trainingStats[type]["countHist"][i];
            }
        }

        // draw gridlines
        dc.setColor(_color["colStatsGrid"], -1);
        for( var i = 0; i < scalePower.size(); i += 1 ) {
            dc.setPenWidth(1);
            dc.drawLine(x_coor,
                        y_coor + scalePower[i]*height,
                        x_coor + width,
                        y_coor + scalePower[i]*height);
        }

        // stroke count bars
        var countScale = 0;
        for( var i = 0; i < $.trainingStats.historyLength; i += 1 ) {
            var count = totalCount[i];
            if(count > countScale) {
                countScale = count;
            }
        }
        var countMinor = 50;
        countScale = countMinor*(countScale/countMinor + 1).toNumber();

        var barThickness = width/$.trainingStats.historyLength/2 + 1;
        for( var i = 0; i < $.trainingStats.historyLength; i += 1 ) {
            var count = totalCount[i];
            if(count != 0){
                dc.setColor(_color["colStatsCountBar"], -1);
                dc.fillRectangle(x_coor + i*width/scaleData, y_coor + height - count*height/countScale, barThickness, count*height/countScale);
            }
        }

        // draw avg power graph
        var avgPowScale = 100;
        for( var i = 1; i < $.trainingStats.historyLength; i += 1 ) {
            var power0 = 0;
            var prevCountTotal = 0;
            var power1 = 0;
            var currCountTotal = 0;

            // calculate total average power
            for( var j = 0; j < $.config.strokeTypes.size()-1; j += 1 ) {
                var type = $.config.strokeTypes[j];

                // previous training stats
                var prevAvg = $.trainingStats.trainingStats[type]["avg"][i-1];
                var prevCount = $.trainingStats.trainingStats[type]["countHist"][i-1];
                power0 += prevAvg*prevCount;
                prevCountTotal += prevCount;

                // current training stats
                var currAvg = $.trainingStats.trainingStats[type]["avg"][i];
                var currCount = $.trainingStats.trainingStats[type]["countHist"][i];
                power1 += currAvg*currCount;
                currCountTotal += currCount;
            }

            // calculate final avg total strokes power
            if(prevCountTotal != 0){power0 = power0/prevCountTotal;}
            if(currCountTotal != 0){power1 = power1/currCountTotal;}

            if (power1 != 0){
                dc.setColor(_color["colAvgTotalGraph"], -1);
                dc.setPenWidth(4);
                var x0 = x_coor + (i-1)*width/scaleData;
                if(power0 == 0) {
                    x0 = x_coor + (i-0.5)*width/scaleData;
                    power0 = power1;
                }
                var y0 = (y_coor + height) - power0*height/avgPowScale;
                var x1 = x_coor + i*width/scaleData;
                var y1 = (y_coor + height) - power1*height/avgPowScale;
                dc.drawLine(x0, y0, x1, y1);
            }

        }

        // Draw last training power histogram
        var totalHisto = new[10];
        for( var i = 0; i < 10; i += 1 ) {
            totalHisto[i] = 0;
            for( var j = 0; j < $.config.strokeTypes.size()-1; j += 1 ) {
                var type = $.config.strokeTypes[j];
                totalHisto[i] += $.trainingStats.trainingStats[type]["lastTrainingGauss"][i];
            }
        }

        var histoWidth = self._rad/6;
        var histoScale = 0;
        for( var i = 0; i < 10; i += 1 ) {
            if(totalHisto[i] > histoScale){
                histoScale = totalHisto[i];
            }
        }

        for( var i = 0; i < 10; i += 1 ) {
            var power = totalHisto[i];
            if (power > 0 ) {
                dc.setColor(_color["colAvgTotalGraph"], -1);
                dc.fillRectangle(x_coor + width, y_coor + (9-i)*height/10, histoWidth*power/histoScale, height/10+1);
            }
        } 

        dc.setColor(_color["colStatsGrid"], -1);
        dc.setPenWidth(2);
        dc.drawRectangle(x_coor, y_coor, width, height);

        dc.setColor(_color["colText"], -1);
        var font = $.config.fontSmall;
        var fontOffset = dc.getFontHeight(font)/2;
        dc.drawText(
            x_coor,
            y_coor - 2*fontOffset,
            font,
            countScale,
            Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(
            x_coor,
            y_coor + height,
            font,
            $.config.langText["shots"],
            Graphics.TEXT_JUSTIFY_LEFT);

        var powerScaleLabel;
        if(!$.config.isUnlocked) {        
            dc.setColor(Graphics.COLOR_RED, -1);
            powerScaleLabel = "Code: " + $.config.verificationCode + $.config.appType;
        } else {        
            dc.setColor(_color["colAvgTotalGraph"], -1);
            powerScaleLabel = avgPowScale + "%";
        }
        dc.drawText(
            x_coor + width,
            y_coor - 2*fontOffset,
            font,
            powerScaleLabel,
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(_color["colAvgTotalGraph"], -1);
        dc.drawText(
            x_coor + width,
            y_coor + height,
            font,
            $.config.langText["power"],
            Graphics.TEXT_JUSTIFY_RIGHT);

    }
    
    function drawStrokeStats(dc as Dc, type as String, x_coor, y_coor, width, height) as Void{
        var scalePower = [0.25, 0.50, 0.75];
        var scaleData = $.trainingStats.historyLength;

        // draw gridlines
        dc.setColor(_color["colStatsGrid"], -1);
        for( var i = 0; i < scalePower.size(); i += 1 ) {
            dc.setPenWidth(1);
            dc.drawLine(x_coor,
                        y_coor + scalePower[i]*height,
                        x_coor + width,
                        y_coor + scalePower[i]*height);
        }

        // stroke count bars
        var countScale = 0;
        for( var i = 0; i < $.trainingStats.historyLength; i += 1 ) {
            var count = $.trainingStats.trainingStats[type]["countHist"][i];
            if(count > countScale) {
                countScale = count;
            }
        }
        var countMinor = 50;
        countScale = countMinor*(countScale/countMinor + 1).toNumber();
        var barThickness = width/$.trainingStats.historyLength/2 + 1;

        for( var i = 0; i < $.trainingStats.historyLength; i += 1 ) {
            var count = $.trainingStats.trainingStats[type]["countHist"][i];
            var win = $.trainingStats.trainingStats[type]["winHist"][i];
            var faul = $.trainingStats.trainingStats[type]["faulHist"][i];

            if(count != 0){
                dc.setColor(_color["colStatsCountBar"], -1);
                dc.fillRectangle(x_coor + i*width/scaleData, y_coor + height - count*height/countScale, barThickness, count*height/countScale);
            }

            if(win != 0){
                dc.setColor(Graphics.COLOR_GREEN, -1);
                dc.fillRectangle(x_coor + i*width/scaleData, y_coor + height - count*height/countScale, barThickness, win*height/countScale);
            }

            if(faul != 0){
                dc.setColor(Graphics.COLOR_RED, -1);
                dc.fillRectangle(x_coor + i*width/scaleData, y_coor + height - faul*height/countScale, barThickness, faul*height/countScale);
            }

        }
        
        // draw avg power graph
        var avgPowScale = 100;
        for( var i = 1; i < $.trainingStats.historyLength; i += 1 ) {
            var power0 = $.trainingStats.trainingStats[type]["avg"][i-1];
            var power1 = $.trainingStats.trainingStats[type]["avg"][i];

            if (power1 != 0){
                dc.setColor($.config.strokeColor[type], -1);
                dc.setPenWidth(4);
                var x0 = x_coor + (i-1)*width/scaleData;
                if(power0 == 0) {
                    power0 = power1;
                    x0 = x_coor + (i-0.5)*width/scaleData;
                }
                var y0 = (y_coor + height) - power0*height/avgPowScale;
                var x1 = x_coor + i*width/scaleData;
                var y1 = (y_coor + height) - power1*height/avgPowScale;
                dc.drawLine(x0, y0, x1, y1);
            }

        }
        
        // Draw last training power histogram
        var gaussWidth = self._rad/6;
        var gaussScale = 0;
        for( var i = 0; i < 10; i += 1 ) {
            if($.trainingStats.trainingStats[type]["lastTrainingGauss"][i] > gaussScale){
                gaussScale = $.trainingStats.trainingStats[type]["lastTrainingGauss"][i];
            }
        }

        for( var i = 0; i < 10; i += 1 ) {
            var power = $.trainingStats.trainingStats[type]["lastTrainingGauss"][i];
            if (power > 0 ) {
                dc.setColor($.config.strokeColor[type], -1);
                dc.fillRectangle(x_coor + width, y_coor + (9-i)*height/10, gaussWidth*power/gaussScale, height/10+1);
            }
        } 

        dc.setColor(_color["colStatsGrid"], -1);
        dc.setPenWidth(2);
        dc.drawRectangle(x_coor, y_coor, width, height);

        dc.setColor(_color["colText"], -1);
        var font = $.config.fontSmall;
        var fontOffset = dc.getFontHeight(font)/2;
        dc.drawText(
            x_coor,
            y_coor - 2*fontOffset,
            font,
            countScale,
            Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(
            x_coor,
            y_coor + height,
            font,
            $.config.langText["shots"],
            Graphics.TEXT_JUSTIFY_LEFT);
        
        dc.setColor($.config.strokeColor[type], -1);
        dc.drawText(
            x_coor + width,
            y_coor - 2*fontOffset,
            font,
            avgPowScale + "%",
            Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(
            x_coor + width,
            y_coor + height,
            font,
            $.config.langText["power"],
            Graphics.TEXT_JUSTIFY_RIGHT);

    }

    function drawStrokeStatsScreen(dc as Dc, type as String) as Void {

        self.drawStrokeStats(dc, type, self._rad*1/3, self._rad*2/3, self._rad*4/3, self._rad*2/3);

        var font = $.config.fontMedium;
        var fontOffset = dc.getFontHeight(font)/2;
        dc.setColor(_color["colText"], -1);
        dc.drawText(
            self._rad,
            self._rad/3 - fontOffset,
            font,
            $.config.langText[type],
            Graphics.TEXT_JUSTIFY_CENTER);

        drawTotalCount(dc, $.trainingStats.trainingStats[type]["totalcount"], _color, _rad);

        dc.setColor($.config.strokeColor[type], -1);
        dc.setPenWidth(self._rad/10);
        dc.drawArc(self._rad, self._rad, self._rad, Graphics.ARC_CLOCKWISE, 0, 360);
        
    }

    function drawButtonHighlight(dc as Dc, angle as Number, length as Number, color as Number, text as String, width as Number) as Void{
        
        dc.setColor(color, -1);
        drawRadialLine(dc, dc.getWidth()/2, dc.getWidth()/2 - length, angle, color, width);

        dc.setColor( Graphics.COLOR_WHITE, -1);
        var angleRad = Math.toRadians(angle);
        var offsetX = Math.cos(angleRad)*dc.getFontHeight(Graphics.FONT_TINY)/2;
        var offsetY = -(Math.sin(angleRad) - 1)*dc.getFontHeight(Graphics.FONT_TINY)/2;
        dc.drawText(
            dc.getWidth()/2*(1 + Math.cos(angleRad)) - offsetX,
            dc.getHeight()/2*(1 - Math.sin(angleRad)) - offsetY,
            Graphics.FONT_TINY,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
            );

    }

    function drawRadialLine(dc as Dc, outRadius as Number, inRadius as Number, angle as Number, color as Number, width as Number) as Void {

        dc.setColor(color, -1);
        dc.setPenWidth(width);
        
        var angleRad = Math.toRadians(angle);
        dc.drawLine(
                dc.getWidth()/2 + inRadius*Math.cos(angleRad),
                dc.getHeight()/2 - inRadius*Math.sin(angleRad),
                dc.getWidth()/2 + outRadius*Math.cos(angleRad),
                dc.getHeight()/2 - outRadius*Math.sin(angleRad)
                );

    }

    function drawTrainingStatsScreen(dc as Dc) as Void {
        var font = $.config.fontMedium;
        var fontOffset = dc.getFontHeight(font)/2;
        dc.setColor(_color["colText"], -1);

        // Title
        dc.drawText(
            self._rad,
            self._rad/3 - fontOffset,
            font,
            $.config.langText["trainings"],
            Graphics.TEXT_JUSTIFY_CENTER);

        // Date
        font = $.config.fontSmall;
        var fontOffsetTiny = dc.getFontHeight(font)/2;
        dc.setColor(_color["colText"], -1);
        dc.drawText(
            self._rad,
            self._rad/3 + fontOffset,
            font,
            $.trainingStats.trainingDates[self._statsActiveNumber].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        var trainingCount = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};
        var trainingCountMax = $.trainingStats.getMaxTotalCount();
        var avgPower = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};
        var maxPower = {"fh" => 0, "bh" => 0, "sv" => 0, "bs" => 0, "fs" => 0};
        var totalCount = 0;
        for(var i = 0; i < $.config.strokeTypesView.size(); i += 1 ) {
            var type = $.config.strokeTypesView[i];
            trainingCount[type] = $.trainingStats.trainingStats[type]["countHist"][self._statsActiveNumber];
            totalCount += trainingCount[type];
            avgPower[type] = $.trainingStats.trainingStats[type]["avg"][self._statsActiveNumber];

            // draw lines between power numbers
            var barWidth = _rad*2/($.config.strokeTypesView.size());
            var bottom = _rad*3/2 + dc.getFontHeight(font)/4;
            dc.setColor(_color["colBgdLines"], -1);
            dc.setPenWidth($.config.penMed);
            dc.drawLine(i*barWidth, bottom, i*barWidth, _rad/3 + fontOffset + fontOffsetTiny*3);

            // draw power
            var fontHeight = dc.getFontHeight($.config.fontSmall);
            dc.setColor(_color["colBgdLines"], -1);
            dc.drawText(
                (i + 0.5)*barWidth,
                bottom - fontHeight*3/2,
                $.config.fontSmall,
                avgPower[type] + "%",
                Graphics.TEXT_JUSTIFY_CENTER);
            }
            
        
        drawStrokeBar(
            dc,
            _rad/3 + fontOffset + fontOffsetTiny*3, // top
            _rad*3/2, //bottom
            _rad/15,
            _rad, //screen radius
            _color, //dictionary with color theme
            trainingCount, //current count
            trainingCountMax, //max count
            [avgPower, maxPower] //avg / max count
        );


        // draw bottom line
        font = Graphics.FONT_XTINY;
        fontOffset = dc.getFontHeight(font)/2;
        dc.setColor(_color["colText"], -1);
        dc.setPenWidth($.config.penMed);
        dc.drawLine(
        0,
        _rad*3/2 + fontOffset/2,
        _rad*2,
        _rad*3/2 + fontOffset/2);

        drawTotalCount(dc, totalCount, _color, _rad);

    }

}
