package;

import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {

    public static macro function getFileContent(path:String) {
        var content = sys.io.File.getContent(path);
        return macro $v {content};
    }
}
