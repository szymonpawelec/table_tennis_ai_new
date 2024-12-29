using Toybox.System;

class Crypto  {

    private var _translate = {
        "a" => '4',
        "b" => '7',
        "c" => '2',
        "d" => '8',
        "e" => '6',
        "f" => '1',
        "g" => '5',
        "h" => '9',
        "i" => '0',
        "j" => '3',
        "k" => 'm',
        "l" => 'n',
        "m" => 'o',
        "n" => 'p',
        "o" => 'q',
        "p" => 'r',
        "q" => 's',
        "r" => 't',
        "s" => 'u',
        "t" => 'v',
        "u" => 'w',
        "v" => 'x',
        "w" => 'y',
        "x" => 'z',
        "y" => 'a',
        "z" => 'b',
        "0" => 'c',
        "1" => 'd',
        "2" => 'e',
        "3" => 'f',
        "4" => 'g',
        "5" => 'h',
        "6" => 'i',
        "7" => 'j',
        "8" => 'k',
        "9" => 'l'
    };

    function initialize() {
    }

    public function generateUnlockMaster(verificationCode) {
        var code = verificationCode;
        // code = ("6d0a65").toCharArray();
        for( var i = 0; i < code.size(); i += 1 ) {
            if(self._translate[code[i].toString()] == null){
                code[i] = 'a';
            } else {
                code[i] = self._translate[code[i].toString()];
            }
        }
        return code;
    }
}
