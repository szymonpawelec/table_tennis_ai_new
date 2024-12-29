import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
using Toybox.Graphics;
using Toybox.ActivityRecording;
import Toybox.Lang;
using Toybox.Math;

class AboutView extends WatchUi.View {

    private var _rad;
    private var _color;

    function initialize() {
        _color = $.config.getColorPalette($.config.darkMenuMode);

        View.initialize();
        
    }


    // Load your resources here
    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _color = $.config.getColorPalette($.config.darkMenuMode);

        if(!$.config.isUnlocked & !$.config.wasPayLinkDisplayed) {
            $.dataConnection.goToPayment();
            $.config.wasPayLinkDisplayed = true;
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLACK, _color["colBgd"]);
        dc.clear();
        
        self._rad = dc.getWidth()/2;

        self.drawAboutScreen(dc);
    }

    function drawAboutScreen(dc as Dc) as Void {
        // main screen header
        var font = $.config.fontMedium;
        var fontOffset = dc.getFontHeight(font)/2;
        dc.setColor(_color["colText"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            self._rad,
            self._rad/3 - fontOffset,
            font,
            $.config.langText["app_name"],
            Graphics.TEXT_JUSTIFY_CENTER);

        font = $.config.fontSmall;

        dc.setColor(_color["colText"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            self._rad,
            self._rad/3 + fontOffset,
            font,
            $.config.langText["version"] + ": " + $.config.appVersion,
            Graphics.TEXT_JUSTIFY_CENTER);

        fontOffset = dc.getFontHeight(font)/2;

        var locked;
        var color;
        if($.config.isUnlocked) {
            locked = $.config.langText["unlocked"];
            color = Graphics.COLOR_DK_GREEN;
        } else {
            locked = $.config.langText["locked"];
            color = Graphics.COLOR_RED;
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            self._rad,
            self._rad/3 + fontOffset*4,
            font,
            locked,
            Graphics.TEXT_JUSTIFY_CENTER);

        if(!$.config.isUnlocked) {
            dc.setColor(_color["colText"], Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                self._rad,
                self._rad/3 + fontOffset*6,
                font,
                $.config.langText["to_unlock"] + ": ",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad/3 + fontOffset*8,
                font,
                "www.sport-ai.net",
                Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                self._rad,
                self._rad/3 + fontOffset*10,
                font,
                $.config.langText["your_code"] + ": " + $.config.verificationCode + $.config.appType,
                Graphics.TEXT_JUSTIFY_CENTER);

        }

        dc.drawText(
            self._rad,
            self._rad*2 - fontOffset*4,
            font,
            "Status:",
            Graphics.TEXT_JUSTIFY_CENTER);

        var txtStatus = $.dataConnection.status;

        if(txtStatus == 200) {
            txtStatus = "OK";
            dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
        }
        
        dc.drawText(
            self._rad,
            self._rad*2 - fontOffset*2,
            font,
            txtStatus,
            Graphics.TEXT_JUSTIFY_CENTER);

    }

}
