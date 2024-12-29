
using Toybox.System;
import Toybox.Graphics;
using Toybox.Math;

function drawStrokeBar(dc as Dc, top, bot, powHeight, rad, colorTheme, count, maxCount, powerAvgMax) as Void {
    // height of last stroke info bar
    var strokeHeight = dc.getFontHeight($.config.fontLastStroke);

    // heigh of stroke bar if power bar exists:
    var barHeight= bot - top - powHeight - strokeHeight;

    // draw stroke bar background
    dc.setColor(colorTheme["colBarBgd"], -1);
    dc.fillRectangle(-10, bot - strokeHeight - barHeight, rad*2+10, barHeight);

    //  draw stroke bars stats
    var strokeList = $.config.strokeTypesView.size();
    for(var i = 0; i < strokeList; i += 1 ) {
        var type = $.config.strokeTypesView[i];
        var color = $.config.colStroke[type];
        var bottom = bot - strokeHeight;
        var barWidth = rad*2/(strokeList);

        // draw stroke count bars
        var max = $.config.scaleIncrement*( 1 + maxCount/$.config.scaleIncrement);
        var scaledValue = barHeight*count[type]/max;
        dc.setColor(color, -1);
        dc.fillRectangle(i*barWidth, bottom - scaledValue, barWidth, scaledValue);

        // draw stroke count text
        var fontHeight = dc.getFontHeight($.config.fontMedium);
        dc.setColor(colorTheme["colTextStrokeBar"], -1);
        dc.drawText(
            (i + 0.5)*barWidth,
            bottom - barHeight/2 - fontHeight/2,
            $.config.fontMedium,
            count[type],
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // draw power bar
        // background 
        dc.setColor(colorTheme["colPowerBgd"], -1);
        dc.fillRectangle(i*barWidth, top, barWidth, powHeight);

        // Draw AVG power 
        dc.setColor(colorTheme["colPowerBar"], -1);
        dc.fillRectangle(i*barWidth, top, barWidth*powerAvgMax[0][type]/100, powHeight);

        // Draw MAX power 
        dc.setColor(colorTheme["colMaxPowerLine"], -1);
        dc.setPenWidth($.config.penMed);
        dc.drawLine(i*barWidth + powerAvgMax[1][type]*barWidth/100, top, i*barWidth + powerAvgMax[1][type]*barWidth/100, top + powHeight);


    }


    // lines between bars
    for(var i = 1; i < strokeList; i += 1 ) {
        var barWidth = rad*2/(strokeList);
        var bottom = bot - strokeHeight;
        // lines between count bars
        dc.setColor(colorTheme["colBgdLines"], -1);
        dc.setPenWidth($.config.penMed);
        dc.drawLine(i*barWidth, bottom, i*barWidth, top);

    }


    dc.setColor(colorTheme["colBgdLines"], -1);
    dc.setPenWidth($.config.penMed);
    dc.drawLine(0, top, rad*2, top);

    // draw power bar line
    dc.setColor(colorTheme["colBgdLines"], -1);
    dc.setPenWidth($.config.penMed);
    dc.drawLine(0, top + powHeight, rad*2, top + powHeight);

}

function drawLastStrokeInfo(dc as Dc, top, bot, powHeight, rad, colorTheme) as Void {
    // height of last stroke info bar
    var strokeHeight = dc.getFontHeight($.config.fontLastStroke);
   // Draw last stroke info
    if($.strokesHistory.register.size() != 0){ 
        var lastType = $.strokesHistory.register[1];
        var lastTypeColor = $.config.colStroke[lastType];
        var power = $.strokesHistory.register[3];

        dc.setColor(lastTypeColor, -1);
        dc.fillRectangle(0, bot - strokeHeight, rad*2, strokeHeight);

        dc.setColor(colorTheme["colTextStrokeLast"], -1);
        dc.drawText(
            rad,
            bot - strokeHeight,
            $.config.fontLastStroke,
            $.config.langText[lastType] + " " + power.toNumber()+"%",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // bottom bar line except current stroke
        for(var i = 0; i < $.config.strokeTypesView.size(); i += 1 ) {
            if(!lastType.equals($.config.strokeTypesView[i])) {
                var bottom = bot - strokeHeight;
                var barWidth = rad*2/($.config.strokeTypesView.size());
                dc.setColor(colorTheme["colBgdLines"], -1);
                dc.setPenWidth($.config.penMed);
                dc.drawLine(i*barWidth, bottom, (i+1)*barWidth, bottom);
            }
        }
                    
    } else{
        // default text before strokes
        dc.setColor(colorTheme["colBgd"], -1);
        dc.fillRectangle(0, bot - strokeHeight, rad*2, strokeHeight);

        dc.setColor(colorTheme["colText"], -1);
        dc.drawText(
            rad,
            bot - strokeHeight,
            $.config.fontLastStroke,
            $.config.langText["hit_prompt"],
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // line below bars 
        dc.setColor(colorTheme["colBgdLines"], -1);
        dc.setPenWidth($.config.penMed);
        dc.drawLine(0, bot - strokeHeight, rad*2, bot - strokeHeight);

    }
    dc.drawLine(0, bot, rad*2, bot);

}


function drawTotalCount(dc as Dc, count, colorTheme, rad) as Void {
        // bottom total count
    var fontCount = $.config.fontMedium;
    var fontTotal = $.config.fontSmall;
    var fontOffset = dc.getFontHeight(fontCount)/2;
    var stringTotal = $.config.langText["stcount"] + ": ";
    var stringCount = count.toString();
    
    var txtWidthTotal = dc.getTextWidthInPixels(stringTotal, fontTotal);
    var txtWidth = txtWidthTotal + dc.getTextWidthInPixels(stringCount, fontCount);

    dc.setColor(colorTheme["colText"], -1);
    dc.setPenWidth($.config.penThin);
    dc.drawLine(
        0,
        rad*3/2 + fontOffset/4,
        rad*2,
        rad*3/2 + fontOffset/4);

    dc.drawText(
        rad - txtWidth/2,
        rad*3/2 + fontOffset*3/4,
        $.config.fontSmall,
        stringTotal,
        Graphics.TEXT_JUSTIFY_LEFT);

    dc.drawText(
        rad - txtWidth/2 + txtWidthTotal,
        rad*3/2 + fontOffset/2,
        fontCount,
        stringCount,
        Graphics.TEXT_JUSTIFY_LEFT);

}
function drawButtonPrompt(dc, rad, buttonType, buttonColor, font, promptTxt, txtColor, txtPosY) as Void{
    var buttonAngle = null;
    var buttonAngleRad = null;
    var tan = null;
    var sin = null;
    var cos = null;
    var txtPosYcentered = null;
    var txtPosXcentered = null;
    var posX = txtPosXcentered;
    var posY = txtPosY + dc.getTextWidthInPixels(" ", font)*4/5;
    var widthRound = dc.getTextWidthInPixels(promptTxt, font) + dc.getTextWidthInPixels(" ", font);
    var height = dc.getFontHeight(font) - dc.getTextWidthInPixels(" ", font)*4/5;
    var rectCoord = null;

    switch (buttonType) {
        case "DOWN":
            buttonAngle = -150;

            buttonAngleRad = Math.toRadians(buttonAngle);
            tan = Math.tan(buttonAngleRad);
            sin = Math.sin(-buttonAngleRad);
            cos = Math.cos(-buttonAngleRad);
            txtPosYcentered = txtPosY+dc.getFontHeight(font)/2;
            txtPosXcentered = rad - (txtPosYcentered - rad)/tan;

            // draw background
            posX = txtPosXcentered;
            posY = txtPosY + dc.getTextWidthInPixels(" ", font)*4/5;
            widthRound = dc.getTextWidthInPixels(promptTxt, font) + dc.getTextWidthInPixels(" ", font);
            height = dc.getFontHeight(font) - dc.getTextWidthInPixels(" ", font)*4/5;
            dc.setColor(buttonColor, -1);
            dc.fillRoundedRectangle(
                posX,
                posY,
                widthRound,
                height,
                dc.getFontHeight(font)/3);

            dc.fillRectangle(
                posX,
                posY,
                widthRound/2,
                height);
            // draw arm to button
            rectCoord = [
                [0, 0],
                [rad, 0],
                [rad, -height],
                [0, -height]
                ];
            for (var i = 0; i < rectCoord.size(); ++i) {
                // rotate
                var x2 = (rectCoord[i][0] * cos) - (rectCoord[i][1] * sin);
                var y2 = (rectCoord[i][1] * cos) + (rectCoord[i][0] * sin);
                
                // move
                rectCoord[i][0] = x2 + posX;
                rectCoord[i][1] = y2 + posY;
            }
            

            dc.fillPolygon(rectCoord);

            // draw name
            dc.setColor(txtColor, -1);
            dc.drawText(
                posX,
                txtPosY,
                font,
                promptTxt,
                Graphics.TEXT_JUSTIFY_LEFT);

            break;
        case "BACK":
            buttonAngle = -30;

            buttonAngleRad = Math.toRadians(buttonAngle);
            tan = Math.tan(buttonAngleRad);
            sin = Math.sin(-buttonAngleRad);
            cos = Math.cos(-buttonAngleRad);
            txtPosYcentered = txtPosY+dc.getFontHeight(font)/2;
            txtPosXcentered = rad - (txtPosYcentered - rad)/tan;

            // draw background
            posX = txtPosXcentered;
            posY = txtPosY + dc.getTextWidthInPixels(" ", font)*4/5;
            widthRound = dc.getTextWidthInPixels(promptTxt, font) + dc.getTextWidthInPixels(" ", font);
            height = dc.getFontHeight(font) - dc.getTextWidthInPixels(" ", font)*4/5;
            dc.setColor(buttonColor, -1);
            dc.fillRoundedRectangle(
                posX - dc.getTextWidthInPixels(promptTxt+" ", font),
                posY,
                widthRound,
                height,
                dc.getFontHeight(font)/3);

            dc.fillRectangle(
                posX-widthRound/2,
                posY,
                widthRound/2,
                height);

            // draw arm to button
            rectCoord = [
                [0, 0],
                [rad, 0],
                [rad, height],
                [0, height]
                ];
            for (var i = 0; i < rectCoord.size(); ++i) {
                // rotate
                var x2 = (rectCoord[i][0] * cos) - (rectCoord[i][1] * sin);
                var y2 = (rectCoord[i][1] * cos) + (rectCoord[i][0] * sin);
                
                // move
                rectCoord[i][0] = x2 + posX;
                rectCoord[i][1] = y2 + posY;
            }
            
            dc.fillPolygon(rectCoord);

            // draw name
            dc.setColor(txtColor, -1);
            dc.drawText(
                posX,
                txtPosY,
                font,
                promptTxt,
                Graphics.TEXT_JUSTIFY_RIGHT);                  
                

            break;
        case "START":
            buttonAngle = 30;

            buttonAngleRad = Math.toRadians(buttonAngle);
            tan = Math.tan(buttonAngleRad);
            sin = Math.sin(-buttonAngleRad);
            cos = Math.cos(-buttonAngleRad);
            txtPosYcentered = txtPosY-dc.getFontHeight(font)/2;
            txtPosXcentered = rad - (txtPosYcentered - rad)/tan;

            // draw background
            posX = txtPosXcentered;
            posY = txtPosY;
            widthRound = dc.getTextWidthInPixels(promptTxt, font) + dc.getTextWidthInPixels(" ", font);
            height = dc.getFontHeight(font) - dc.getTextWidthInPixels(" ", font)*4/5;
            dc.setColor(buttonColor, -1);
            dc.fillRoundedRectangle(
                posX - dc.getTextWidthInPixels(promptTxt+" ", font),
                posY - dc.getFontHeight(font),
                widthRound,
                height,
                dc.getFontHeight(font)/3);

            dc.fillRectangle(
                posX-widthRound/2,
                posY - dc.getFontHeight(font),
                widthRound/2,
                height);

            // draw arm to button
            rectCoord = [
                [0, 0],
                [rad, 0],
                [rad, -height],
                [0, -height]
                ];
            for (var i = 0; i < rectCoord.size(); ++i) {
                // rotate
                var x2 = (rectCoord[i][0] * cos) - (rectCoord[i][1] * sin);
                var y2 = (rectCoord[i][1] * cos) + (rectCoord[i][0] * sin);
                
                // move
                rectCoord[i][0] = x2 + posX;
                rectCoord[i][1] = y2 + posY - dc.getFontHeight(font) + height;
            }
            
            dc.fillPolygon(rectCoord);

            // draw name
            dc.setColor(txtColor, -1);
            dc.drawText(
                posX,
                txtPosY - dc.getFontHeight(font) - dc.getTextWidthInPixels(" ", font),
                font,
                promptTxt,
                Graphics.TEXT_JUSTIFY_RIGHT);                  
                
            // drawRadialLine(dc as Dc, rad, 0, buttonAngle, buttonColor, 2);
            // dc.setColor(buttonColor, -1);
            // dc.setPenWidth(2);
            // dc.drawLine(0, txtPosYcentered,2*rad, txtPosYcentered);
            // dc.drawLine(txtPosXcentered, 0, txtPosXcentered, 2*rad);

            break;
        default:
            // System.println("No known button prompt displayed!");
    }
}