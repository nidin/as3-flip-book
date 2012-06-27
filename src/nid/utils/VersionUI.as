package nid.utils
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
     /**
      * ...
      * @author Nidin.P.Vinayak
      */
  public  class VersionUI extends Sprite
     {
         private var ver:TextField;
         public function VersionUI() 
         {
             configUI();
         }
         public function set(v:String):void {
             ver.text = v;
         }
         private function configUI():void
         {
             ver = new TextField();
             ver.autoSize = TextFieldAutoSize.LEFT;
             ver.defaultTextFormat = new TextFormat('Tahoma', 10, 0xffffff);
             ver.text = 'build:' + Version.Build;
             addChild(ver);
         }
     }
 }