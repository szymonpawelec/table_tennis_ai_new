import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
using Toybox.Graphics;
using Toybox.ActivityRecording;
import Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;

class StrokeMonitorView extends WatchUi.View {
    
    private var _color;
    private var _rad;
    private var _timerTick = 0;
    private var _timerUpdateScreen;
    function initialize() {
        _color = $.config.getColorPalette($.config.darkMode);

        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc)); // TODO: not needed?
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        self._timerUpdateScreen = new Timer.Timer();
		self._timerUpdateScreen.start( method(:onTimer), 1000, true );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        self._timerUpdateScreen.stop();
        self._timerUpdateScreen = null;
    }

    function onTimer() as Void {
        if($.strokesHistory.register.size() != 0){
            $.strokesHistory.updateStrokeTimeRegister();
            }
        $.dataFields.setGraphData();
        self._timerTick = 0;
        
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLACK, _color["colBgd"]);
        dc.clear();
        
        _rad = dc.getWidth()/2;


        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var posXtotalCount = 2*_rad - _rad*1/5 - _rad/10;
        var widthTotalCount = drawTotalCount(dc, $.config.fontLarge, posXtotalCount, _rad);

        var widthStrokeHistory = _rad*1/5;
        drawStrokeHistory(dc, widthStrokeHistory, dc.getHeight()/2, 20, -20);

        
        var widthPower = drawPower(dc, $.config.fontMedium, 2*_rad - _rad*1/5 - _rad/10, _rad - _rad/3);

        drawTimer(dc, $.config.fontLarge, _rad, 0);
        drawCurrentTime(dc, $.config.fontLarge, _rad - _rad/10, _rad/3);
        var widthStepsCount = drawStepsCount(dc, $.config.fontLarge, _rad + _rad/10, _rad/3);

        var widthMenuIcon = .1*self._rad;
        // drawMenuIcon(dc,widthMenuIcon, self._rad/7);

        drawHeartRateZones(dc, -115, -65);
        
        var widthHr = drawheartRate(dc, $.config.fontLarge, _rad - _rad/10, _rad*17/12 + dc.getFontHeight($.config.fontSmall)/2);
        var widthCalories = drawCaloryCount(dc, $.config.fontLarge, _rad + _rad/10, _rad*17/12 + dc.getFontHeight($.config.fontSmall)/2);



        drawStrokeStats(dc,
                        widthMenuIcon,
                        _rad*2/3,
                        $.config.fontSmall,
                        widthTotalCount + 2*_rad - posXtotalCount
                        );

        drawButtonPrompt(dc, _rad, "DOWN", Graphics.COLOR_DK_GREEN, $.config.fontSmall, $.config.langText["score"].toUpper(), Graphics.COLOR_WHITE, _rad*4/3);
        drawButtonPrompt(dc, _rad, "BACK", Graphics.COLOR_DK_RED, $.config.fontSmall, $.config.langText["fault"].toUpper(), Graphics.COLOR_WHITE, _rad*4/3);
        // drawButtonPrompt(dc, _rad, "START", Graphics.COLOR_DK_GRAY, $.config.fontSmall, "UNDO", Graphics.COLOR_WHITE, _rad*2/3);

        // draw separation lines
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth($.config.penThin);
        dc.drawLine(0, _rad*2/3, _rad*2, _rad*2/3);  
        dc.drawLine(_rad, _rad*5/12, _rad, _rad*2/3);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth($.config.penThin);
        dc.drawLine(0, _rad*4/3, _rad*2, _rad*4/3);
        dc.drawLine(_rad, _rad*4/3, _rad, _rad*11/6);  

        // draw pause red brim
        if ((session != null) && !session.isRecording()) {
            dc.setColor(Graphics.COLOR_RED, -1);
            dc.setPenWidth(_rad/7);
            dc.drawArc(_rad, _rad, _rad, Graphics.ARC_CLOCKWISE, 0, 360);
        }

    }

    function drawStrokeStats(dc, posX, posY, font, widthRight) as Void{

        // get max length of stroke type/count text
        var maxTextLengthName = 0;
        var maxTextLengthCount = 0;
        var maxCount = 0;
        for(var i=0; i < $.config.strokeTypesView.size(); i++){
            var strokeType = $.config.strokeTypesView[i];
            var strokeName = $.config.langText[strokeType].toUpper();
            var currentCount = $.strokesHistory.currentCount[strokeType];
            var currentNameLength =dc.getTextWidthInPixels(strokeName, font);
            var currentCountLength =dc.getTextWidthInPixels(currentCount.toString(), font);
            
            if(currentNameLength > maxTextLengthName) { maxTextLengthName = currentNameLength;}
            if(currentCountLength > maxTextLengthCount) { maxTextLengthCount = currentCountLength;}
            if(currentCount > maxCount) { maxCount = currentCount;}

        }

        var marginLength = dc.getTextWidthInPixels(" ", font);
        var offset = 3;
        // Draw stroke names and bars
        for(var i=0; i < $.config.strokeTypesView.size(); i++){
            var strokeType = $.config.strokeTypesView[i];
            var strokeName = $.config.langText[strokeType];
            var fontHeight = dc.getFontHeight(font);
            
            dc.setColor(_color["colText"], -1);

            // draw name
            var namePosX = posX + maxTextLengthName + marginLength;
            var namePosY = posY + (fontHeight*1.5 - offset)*i + fontHeight/2;
            dc.drawText(
                namePosX,
                namePosY,
                font,
                strokeName.toUpper(),
                Graphics.TEXT_JUSTIFY_RIGHT);

            // draw color strip
            var stripPosX = namePosX + marginLength;
            var stripPosY = namePosY + marginLength;
            var stripWidth = marginLength; 
            var stripHeight = fontHeight - marginLength*4/3; 
            dc.setColor($.config.colStroke[strokeType], -1);
            dc.fillRectangle(stripPosX, stripPosY, stripWidth, stripHeight);

            // draw count bar
            var barPosX = stripPosX + stripWidth;
            var maxBarWidth = 2*_rad - barPosX - widthRight - maxTextLengthCount - 2*marginLength;

            var strokeCount = $.strokesHistory.currentCount[strokeType];
            // establish bar lengths
            var barWidth = marginLength*(i+1);
            if(strokeCount == 0){
                barWidth=0;
            } else {
                barWidth = maxBarWidth*strokeCount.toFloat()/maxCount;
            }

            dc.setColor($.config.colStroke[strokeType], -1);
            dc.fillRoundedRectangle(barPosX, stripPosY, barWidth, stripHeight, stripHeight/3);
            dc.fillRectangle(barPosX, stripPosY, barWidth/2, stripHeight);

            // draw name
            dc.setColor(_color["colText"], -1);
            var countPosX = barPosX + barWidth + marginLength;
            dc.drawText(
                countPosX,
                namePosY,
                font,
                strokeCount,
                Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawTotalCount(dc as Dc, font, posX, posY) as Number {
        var totalCount = $.strokesHistory.totalCount;
        var leadingZerosSplit = addLeadingZeros(totalCount, 3);
        var text = leadingZerosSplit[0] + leadingZerosSplit[1];
        var colorBcgr = -1;
        var colorText = _color["colText"];
        if($.strokesHistory.register.size() != 0){ 
            // Draw circle with foul info
            var lastFoul = $.strokesHistory.register[6];
            if (lastFoul) {
                colorBcgr = Graphics.COLOR_RED;
                colorText = Graphics.COLOR_WHITE;
            }

            // Draw circle with winner info
            var lastWinner = $.strokesHistory.register[7];
            if (lastWinner) {
                colorBcgr = Graphics.COLOR_GREEN;
                colorText = Graphics.COLOR_BLACK;
            }
        }

        dc.setColor(_color["colLeadZeros"], colorBcgr);
        dc.drawText(
            posX - dc.getTextWidthInPixels(leadingZerosSplit[1], font),
            posY,
            font,
            leadingZerosSplit[0],
            Graphics.TEXT_JUSTIFY_RIGHT);
            
        dc.setColor(colorText, colorBcgr);
        dc.drawText(
            posX,
            posY,
            font,
            leadingZerosSplit[1],
            Graphics.TEXT_JUSTIFY_RIGHT);

        return dc.getTextWidthInPixels(text, font);
    }    

    function drawheartRate(dc as Dc, font, posX, posY) as Number {
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        if (heartRate == null){heartRate = 0;}
        var leadingZerosSplit = addLeadingZeros(heartRate, 3);
        var text = leadingZerosSplit[0] + leadingZerosSplit[1];
        var fontHeight = dc.getFontHeight(font);
        var textLength = dc.getTextWidthInPixels(text, font);
        
        dc.setColor(_color["colLeadZeros"], -1);
        dc.drawText(
            posX - dc.getTextWidthInPixels(leadingZerosSplit[1], font),
            posY,
            font,
            leadingZerosSplit[0],
            Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(_color["colText"], -1);
        dc.drawText(
            posX,
            posY,
            font,
            leadingZerosSplit[1],
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.setColor(Graphics.COLOR_DK_RED, -1);
        dc.drawText(
            posX - textLength,
            posY,
            $.config.fontIcons,
            "K",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        

        return textLength + dc.getTextWidthInPixels("K", $.config.fontIcons);
    }

    function drawCaloryCount(dc as Dc, font, posX, posY) as Number {
        var calories = Activity.getActivityInfo().calories;

        if (calories == null){calories = 0;}

        var leadingZerosSplit = addLeadingZeros(calories, 3);
        var text = leadingZerosSplit[0] + leadingZerosSplit[1];
        
        dc.setColor(_color["colLeadZeros"], -1);
        dc.drawText(
            posX,
            posY,
            font,
            leadingZerosSplit[0],
            Graphics.TEXT_JUSTIFY_LEFT);
            
        dc.setColor(_color["colText"], -1);
        dc.drawText(
            posX + dc.getTextWidthInPixels(leadingZerosSplit[0], font),
            posY,
            font,
            leadingZerosSplit[1],
            Graphics.TEXT_JUSTIFY_LEFT);

        var widthCalories = dc.getTextWidthInPixels(text, font);

        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
        dc.drawText(
            posX + widthCalories,
            posY,
            $.config.fontIcons,
            "H",
            Graphics.TEXT_JUSTIFY_LEFT);

        return widthCalories + dc.getTextWidthInPixels("H", $.config.fontIcons);
    }
        
    function drawStepsCount(dc as Dc, font, posX, posY) as Number {
        // Get steps / cadence
        var stepsCount = ActivityMonitor.getInfo().steps - $.strokesMonitor.trainingInitialSteps;
        var leadingZerosSplit = addLeadingZeros(stepsCount, 4);
        var text = leadingZerosSplit[0] + leadingZerosSplit[1];
        
        dc.setColor(_color["colLeadZeros"], -1);
        dc.drawText(
            posX,
            posY,
            font,
            leadingZerosSplit[0],
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(_color["colText"], -1);
        dc.drawText(
            posX + dc.getTextWidthInPixels(leadingZerosSplit[0], font),
            posY,
            font,
            leadingZerosSplit[1],
            Graphics.TEXT_JUSTIFY_LEFT);

        var stepsWidth = dc.getTextWidthInPixels(text, font);

        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
        dc.drawText(
            posX + stepsWidth,
            posY,
            $.config.fontIcons,
            "F",
            Graphics.TEXT_JUSTIFY_LEFT);


        return stepsWidth + dc.getTextWidthInPixels("F", $.config.fontIcons);
    }

    function addLeadingZeros(value as Number, digits as Number) as Array<String> {
        var valueSplit = ["",value.toString()];

        for(var i=1; i < digits; i++){
            if((value/Math.pow(10,i)).toNumber() == 0){
                valueSplit[0] += "0";
            }
        }

        return valueSplit;
    }

    function drawHeartRateZones(dc as Dc, startAng, endAng) as Void {
        var heartRateZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        var hrZonesCumulated = $.strokesMonitor.hrZonesCumulated;
        var color = [
            Graphics.COLOR_LT_GRAY,
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_RED,
        ];
        var widthAng = (startAng - endAng)/5;
        var gap = 0.2;
        var maxValHr = 1;
        for(var i=0; i < hrZonesCumulated.size(); i++){
            if(hrZonesCumulated[i] > maxValHr){
                maxValHr = hrZonesCumulated[i];
            }
        }

        for(var i=0; i < 5; i++){
            dc.setPenWidth(_rad/20+_rad/10*hrZonesCumulated[i]/maxValHr);
            dc.setColor(color[i], -1);
            dc.drawArc(_rad,_rad,_rad,Graphics.ARC_COUNTER_CLOCKWISE, startAng - widthAng*i + gap, startAng - widthAng*(i+1) - gap);
        }

        // draw current HR
        var heartRate = Activity.getActivityInfo().currentHeartRate;
        if(heartRate == null){heartRate = 0;}

        var minHr = heartRateZones[0];
        var maxHr = heartRateZones[5];
        var hrAngle = startAng + (endAng - startAng).toFloat()/(maxHr-minHr+1)*(heartRate - minHr);

        if (heartRate > maxHr){
            hrAngle = endAng;
        } else if (heartRate < minHr){
            hrAngle = startAng;
        }
        drawRadialLine(dc as Dc, _rad, _rad*45/48, hrAngle, _color["colText"], $.config.penThick);

    }

    function drawMenuIcon(dc as Dc, width, height) as Void {

        dc.setColor(_color["colBgd"], -1);
        dc.fillRectangle(0, _rad - height/2, width, height);

        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
        var gap = (height/7).toNumber();
        
        dc.setPenWidth(gap);
        dc.drawLine(0, _rad - gap*2, width, _rad - gap*2);
        dc.drawLine(0, _rad, width, _rad);
        dc.drawLine(0, _rad + gap*2, width, _rad + gap*2);
        
        dc.drawLine(width, _rad - height/2, gap, _rad - height/2);
        dc.drawLine(gap, _rad - height/2, width/2 + gap, _rad - height/2 - (width - gap)*Math.pow(3,0.5)/2);
        dc.drawLine(width/2 + gap, _rad - height/2 - (width - gap)*Math.pow(3,0.5)/2, width, _rad - height/2);
        // dc.fillPolygon([
        //     [width, _rad - height/2],
        //     [gap, _rad - height/2],
        //     [width/2 + gap, _rad - height/2 - (width - gap)*Math.pow(3,0.5)/2]
        //     ]);
        
        dc.drawLine(width, _rad + height/2, gap, _rad + height/2);
        dc.drawLine(gap, _rad + height/2, width/2 + gap, _rad + height/2 + (width - gap)*Math.pow(3,0.5)/2);
        dc.drawLine(width/2 + gap, _rad + height/2 + (width - gap)*Math.pow(3,0.5)/2, width, _rad + height/2);
        dc.fillPolygon([
            [width, _rad + height/2],
            [gap, _rad + height/2],
            [width/2 + gap, _rad + height/2 + (width - gap)*Math.pow(3,0.5)/2]
            ]);

    }

    function drawButtonHighlight(dc as Dc, text, font, color, angle) as Void {
        var offset = dc.getFontHeight(font);
        var size = offset*1.1;
        var x = _rad;
        var y = _rad;
        var shape = [[-0.5, -2],
                    [0.5, -2],
                    [0.5, 0.5],
                    [0.354, 0.854],
                    [0, 1],
                    [-0.354, 0.854],
                    [-0.5, 0.5],
                    [0,0.5]];

        var angleRad = Math.toRadians(angle);
        var sin = Math.sin(angleRad);
        var cos = Math.cos(angleRad);

        for(var i=0; i < shape.size(); i++){
            var xc = shape[i][0];
            var yc = shape[i][1];
            shape[i][0] = (xc*cos - yc*sin)*size + _rad*(1 + sin);
            shape[i][1] = (xc*sin + yc*cos)*size + _rad*(1 - cos);
        }

        dc.setColor(color, -1);
        dc.fillPolygon(shape.slice(0,shape.size()-1));
        dc.setColor(Graphics.COLOR_WHITE, -1);
        dc.drawText(shape[shape.size()-1][0], shape[shape.size()-1][1]-size/2, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawTotalStrokes(dc as Dc, posy, radius) as Void {

        if($.strokesHistory.register.size() != 0){ 
            // Draw circle with foul info
            var lastFoul = $.strokesHistory.register[6];
            if (lastFoul) {
                dc.setColor(Graphics.COLOR_RED, -1);
                dc.fillCircle(_rad, dc.getHeight()/2, radius);
            }

            // Draw circle with winner info
            var lastWinner = $.strokesHistory.register[7];
            if (lastWinner) {
                dc.setColor(Graphics.COLOR_GREEN, -1);
                dc.fillCircle(_rad, dc.getHeight()/2, radius);
            }
        }

        //cover top half of the screen
        dc.setColor(_color["colBgd"], -1);
        dc.fillRectangle(0, 0, _rad*2, _rad);

        // Draw total stroke count
        var font = $.config.fontStrokeTotal;
        var fontOffset = dc.getFontHeight(font)*1/4;
        dc.setColor(_color["colText"], -1);
        dc.drawText(
            _rad,
            posy + fontOffset,
            font,
            $.strokesHistory.totalCount,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawTimer(dc as Dc, font, posX, posY) as Void {
        var time = System.getClockTime(); // ClockTime object
        var timeElapsed = (Activity.getActivityInfo().timerTime/1000).toNumber();

        // Draw stoper
        var curr = Toybox.Time.now();
        if ((session != null) && session.isRecording()) {
            var elapsedTime = curr.value() - $.strokesHistory.activityStartTime.value();

            dc.setColor(_color["colTextActive"], -1);
            dc.drawText(
                posX,
                posY,
                font,
                toHMS(timeElapsed),
                Graphics.TEXT_JUSTIFY_CENTER
                        );
        } else{
            dc.setColor(_color["colText"], -1);
            dc.drawText(
                posX,
                posY,
                font,
                toHMS(timeElapsed),
                Graphics.TEXT_JUSTIFY_CENTER
                        );
        }
        
    }
    
    function drawCurrentTime(dc as Dc, font, posX, posY) as Void {
        // Draw current time
        var time = System.getClockTime(); // ClockTime object
        dc.setColor(_color["colText"], -1);
        
        var is24clock = System.getDeviceSettings().is24Hour;
        var hrs = time.hour;

        if(!is24clock) {
            hrs = (hrs - (hrs/12).toNumber()*12).format("%01d");
        } else {
            hrs = hrs.format("%02d");
        }
        
        var txtTime = hrs + ":" + time.min.format("%02d");
        dc.drawText(
            posX,
            posY,
            font,
            txtTime,
            Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_DK_GRAY, -1);
        dc.drawText(
            posX - dc.getTextWidthInPixels(txtTime, font),
            posY,
            $.config.fontIcons,
            "E",
            Graphics.TEXT_JUSTIFY_RIGHT);
    }

        
    function drawPower(dc as Dc, font, posX, posY) as Number {

        var txtPower = "0%";

        if($.strokesHistory.register.size() != 0){ 
            var lastType = $.strokesHistory.register[1];
            var lastTypeColor = $.config.colStroke[lastType];
            var power = $.strokesHistory.register[3];
            txtPower = power.toNumber()+"%";

            dc.setColor(lastTypeColor, -1);
            dc.drawText(
                posX,
                posY,
                font,
                txtPower,
                Graphics.TEXT_JUSTIFY_RIGHT);
        }
        
        return dc.getTextWidthInPixels(txtPower, font);
    }

    function drawStrokeHistory(dc as Dc, width, outRadius, startDeg, endDeg) as Void {
        // dc.setColor(_color["colBgdGrid"], -1);
        // dc.setPenWidth($.config.penThin);
        // dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (outRadius-inRadius)/4 + inRadius, Graphics.ARC_CLOCKWISE, startDeg+10, endDeg-10);
        // dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (outRadius-inRadius)/2 + inRadius, Graphics.ARC_CLOCKWISE, startDeg+10, endDeg-10);
        // dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (outRadius-inRadius)*3/4 + inRadius, Graphics.ARC_CLOCKWISE, startDeg+10, endDeg-10);
        var inRadius = _rad - width;
        dc.setColor(_color["colBgdLines"], -1);
        dc.setPenWidth($.config.penMed);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, inRadius, Graphics.ARC_CLOCKWISE, startDeg+10, endDeg-10);

        var timeRegister = $.strokesHistory.timeRegister;

        for(var i = 0; i < timeRegister.size(); i += 1 ) {
            var k = timeRegister.size() - 1 - i;
            var type = timeRegister[k][1];
            var angleOffset = (endDeg - startDeg)/timeRegister.size();
            var angleStart =(startDeg+angleOffset*i);
            if ((type != null) & ($.strokesHistory.register.size() != 0)){
                var power = timeRegister[k][2];
                if(power < 15) {power = 15;}
                dc.setColor($.config.colStroke[type], -1);
                dc.setPenWidth(2*(outRadius-inRadius)*power.toFloat()/100);
                dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2, Graphics.ARC_CLOCKWISE, angleStart, angleStart-3);
            }
        }

        // cover the bottom of lines for sq screens
        dc.setColor(_color["colBgd"], -1);
        dc.setPenWidth(dc.getHeight());
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight(), Graphics.ARC_CLOCKWISE, 0, 180);
        
        dc.fillRectangle(0,0,dc.getWidth(),dc.getHeight()/3);
        dc.fillRectangle(0,dc.getHeight()*2/3,dc.getWidth(),dc.getHeight()/3);

    }
    
    function toHMS(secs) {
            var hr = secs/3600;
            var min = (secs-(hr*3600))/60;
            var sec = secs%60;
            if(secs < 3600) {
                return min.format("%02d")+":"+sec.format("%02d");
                } else {
                return hr.format("%02d")+":"+min.format("%02d");
                }
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

    function drawHeart(dc as Dc, x, y, scl) as Void {
        dc.setColor(Graphics.COLOR_RED, -1);
        dc.fillPolygon([
            [x + scl*0, 0.5*scl + y],
            [x + scl*0.3, 0.1*scl + y],
            [x + scl*0.4, -0.25*scl + y],
            [x + scl*0.25, -0.5*scl + y],
            [x + scl*0.1, -0.5*scl + y],
            [x + scl*0, -0.3*scl + y],
            [x + scl*-0.1, -0.5*scl + y],
            [x + scl*-0.25, -0.5*scl + y],
            [x + scl*-0.4, -0.25*scl + y],
            [x + scl*-0.3, 0.1*scl + y],
            [x + scl*0, 0.5*scl + y],
            ]);
    }

}
