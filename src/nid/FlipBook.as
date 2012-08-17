package nid
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	import nid.flip.*;
	import nid.flip.events.*;
	import nid.utils.*;
	
	public class FlipBook extends MovieClip
	{
		public static const DEGREE_CONST:Number = Math.PI / 180;
		
		private var page:int;
		private var left_page:MovieClip;
		private var left_page_back:MovieClip;
		private var hard_page_2:MovieClip;
		private var hard_page_3:MovieClip;
		private var right_page:MovieClip;
		private var right_page_back:MovieClip;
		private var maxpage:int;
		private var pageNumber:Array;
		private var pageN:MovieClip;
		private var pageO:MovieClip;
		private var mouse_x:Number;
		private var mouse_y:Number;
		private var tearablePages:Vector.<Boolean>;
		private var pageOrder:Vector.<DisplayObject>;
		private var pageRef:Vector.<BasePage>;
		
		private var hard_cover:Boolean;
		private var clickarea:int;
		private var afa:int;
		private var flip_speed:int;
		private var auto_flip_speed:int;
		private var p_speed:int;
		private var release_speed:int;
		private var flip_enabled:Boolean;
		private var transparency:Boolean;
		private var large_cover:Boolean;
		private var sound_enabled:Boolean;
		private var count:Number;
		private var gpage:Number;
		private var gflip:Boolean;
		private var direction:Number;
		private var skip_pages:Boolean;
		private var gtarget:Number;
		private var auto_flip:Boolean;
		private var flip:Boolean;
		private var flipOff:Boolean;
		private var flipOK:Boolean;
		private var hard_flip:Boolean;
		private var rotz:Number;
		private var pre_flip:Boolean;
		private var tearable:Boolean;
		private var tear:Boolean;
		private var teard:Number;
		private var tlimit:Number;
		private var removedPages:Array;
		private var mp_x:Number;
		private var mp_y:Number;
		private var sx:Number;
		private var sy:Number;
		private var ax:Number;
		private var ay:Number;
		private var acnt:Number;
		private var aadd:Number;
		private var pages:Pages;
		private var ox:Number;
		private var oy:Number;
		private var tox:Number;
		private var toy:Number;
		private var cx:Number;
		private var cy:Number;
		private var ad:Number;
		private var rl:Number;
		private var nx:Number;
		private var ny:Number;
		private var offs:Number;
		private var p0:int;
		private var p5:int;
		private var channel:SoundChannel;
		private var channel2:SoundChannel;
		private var sound_0:Sound;
		private var sound_1:Sound;
		private var sound_2:Sound;
		private var r0:Number;
		private var r1:Number;
		private var pLL_page:DisplayObject;
		private var pLR_page:DisplayObject;
		private var bookmarks:Vector.<BookMark>;
		private var fast_bookmark:Boolean;
		private var p1_index:int;
		private var bm_index:int;
		private var p4_index:int;
		private var intervalID:uint;
		private var mouseDown:Boolean;
		private var loaded:Boolean;
		private var total_pages:int;
		private var loaded_pages:int;
		
		static public var PAGE_WIDTH:Number = 350;
		static public var PAGE_HEIGHT:Number = 460;
		
		public static var width_diff:Number;
		public static var height_diff:Number;
		public static var bookmark_y:Number = 0;
		public static var inner_shadow:Boolean;
		public static var rounded_corner:XML;
		
		public var currentPageIndex:int;
		
		public function FlipBook()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/*
		 *	CONTEXT MENU 
		 */
        private function addCustomMenuItems():void {
			
			var myMenu:ContextMenu = new ContextMenu();
            myMenu.hideBuiltInItems();
            var menu1:ContextMenuItem;
			var menu2:ContextMenuItem;
            menu1 = null;
			menu1 = new ContextMenuItem("About Flip Book v1");
            menu1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, navigateToSite);
			//menu2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, navigateToSite);
            myMenu.customItems.push(menu1);
			//myMenu.customItems.push(menu2);
            this.contextMenu = myMenu;
            return;
        }
		
		private function navigateToSite(e:ContextMenuEvent):void
        {
           	navigateToURL(new URLRequest("http://www.infogroupindia.com/blog/?s=flipbook"), "_blank");
            return;
        }
		
		public function get totalPages():int { return total_pages * 2; }
		public function get loadedPages():int { return loaded_pages; }
		public function get getPages():Vector.<BasePage> { return pageRef; }
		
		public function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			addCustomMenuItems();
			
			pages = new Pages();
			
			pages.x = stage.stageWidth / 2;
			pages.y = stage.stageHeight / 2;
			
			channel = new SoundChannel();
			channel2 = new SoundChannel();
			sound_0 = new PickUpPageSound();
			sound_1 = new TurnPageSound1();
			sound_2 = new TurnPageSound2();
			
			hard_cover = true;		//hard cover on/off

			clickarea = 100;		//pixel width of the click sensitive area at the edges..
			afa = 100;				//width of the autoflip starter square.

			flip_speed 		= 10;	//goto page flip speed
			auto_flip_speed = 2;	//goto page flip speed
			p_speed 	= 5;	//mouse pursuit speed
			release_speed 	= 3;	//flip speed after mouse btn release

			flip_enabled = true;	//page flipping enabled

			transparency = false;	//use transparent pages or not (1 level transparency)

			large_cover = true;		//large_cover on/off
			width_diff = 0;			//width difference
			height_diff = 0;		//height difference on top/bottom
			
			sound_enabled = true;
			
			count = 0;			//counter (used on a page where is an animation)
			gpage = 0;			//gotoPage No
			gflip = false;		//gotoPage flip
			direction = 0;			//goto direction...
			skip_pages = false;		//skip pages	***
			gtarget = 0;		//target when skipping

			auto_flip = false;		//auto flip
			flip = false;		//pageflip
			flipOff = false;	//terminateflip
			flipOK = false;		//good flip
			hard_flip = false;		//hardflip (the cover of the book)
			rotz = -30;			//hardflip max y difference

			pre_flip = false;	//corner flip status
			tearable = false;		//actual page status
			tear = false;
			teard = 0;
			tlimit = 80;
			removedPages = new Array();	//list of removed pages!

			mp_x = mp_y = 0;	//mousepos at click
			sx = sy = 0;		//startpoint when flipping
			mouse_x = 0;		//mouse x,y
			mouse_y = 0;
			ax = ay = 0;		//auto x,y
			acnt = 0;
			aadd = 0;			
			//load(stage.loaderInfo.parameters.book_data == undefined?'book_data.xml':stage.loaderInfo.parameters.book_data);
		}
		
		public function load(url:String):void 
		{
			if (loaded) return;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(new URLRequest(url));
			loaded = true;
		}
		
		private function onIOError(e:IOErrorEvent):void 
		{
			
		}
		
		private function onComplete(e:Event):void 
		{
			bookmarks = new Vector.<BookMark>();
			
			var xml:XML = new XML(e.currentTarget.data);
			
			
			PAGE_WIDTH 		= xml.settings.width;
			PAGE_HEIGHT 	= xml.settings.height;
			width_diff 		= xml.settings.width_diff;
			height_diff 	= xml.settings.height_diff;
			fast_bookmark 	= xml.settings.bookmark.@skip_pages=="true";
			hard_cover 		= xml.settings.hard_cover=="true";
			inner_shadow 	= xml.settings.inner_shadow=="true";
			rounded_corner 	= xml.settings.rounded_corner[0];
			
			playMusic(xml.settings.music[0]);
			
			addPage("start");
			total_pages = xml.page.length();
			loaded_pages = 0;
			var pc:int = 1;
			
			for (var i:int = 0; i < total_pages; i++)
			{
				var left_index:int = pc++;
				var right_index:int = pc++;
				
				if (String(xml.page[i].@bookmark) != "" && xml.settings.bookmark == "true")
				{
					var bookmark:BookMark = new BookMark(xml.page[i].@bookmark);
					bookmark.index = right_index;
					bookmark.addEventListener(MouseEvent.CLICK, onOuterBookMarkClicked);
					bookmark.x = PAGE_WIDTH;
					bookmark.y = (bookmark_y + 5) - (PAGE_HEIGHT / 2);
					bookmarks.push(bookmark);
					pages.bookmarks.addChild(bookmark);
				}
				
				var type:String = i == 0?"font_cover":(i == total_pages - 1?"back_cover":"inner_page");
				var mark:String = xml.settings.bookmark == "true"?xml.page[i].@bookmark:"";
				
				var tp1:BasePage = new BasePage(left_index, PAGE_WIDTH, PAGE_HEIGHT, type, "left" , xml.page[i].@left, mark, rounded_corner);
				var tp2:BasePage = new BasePage(right_index , PAGE_WIDTH, PAGE_HEIGHT, type, "right" , xml.page[i].@right, mark, rounded_corner)
				
				tp1.addEventListener(Event.COMPLETE, load_complete);
				tp2.addEventListener(Event.COMPLETE, load_complete);
				
				addPage(tp1, false);
				addPage(tp2, false);
			}
			addPage("end");
			
			addChild(pages);
			
			p1_index = pages.getChildIndex(pages.p1);
			bm_index = pages.getChildIndex(pages.bookmarks);
			p4_index = pages.getChildIndex(pages.p4);
			
			setup();
			
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function load_complete(e:Event):void 
		{
			loaded_pages++;
		}
		
		private function playMusic(data:XML):void 
		{
			if (data.@enabled == "true")
			{
				var sound:Sound = new Sound();
				sound.load(new URLRequest(data.text()));
				channel2 = sound.play();
				channel2.soundTransform = new SoundTransform(data.@volume / 100)
			}
		}
		
		private function onOuterBookMarkClicked(e:MouseEvent):void 
		{
			gotoPage(e.currentTarget.index, fast_bookmark);
		}
		
		private function setup():void
		{
			page = 0;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, on_mouse_up);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
			stage.addEventListener(Event.ENTER_FRAME, render);
			resetPages();
			reset();
		}
		
		public function addPage(pageobj:Object, tear:Boolean = false):void 
		{
			var _page:DisplayObject;
			
			if (pageobj is String)
			{
				if (pageobj == "start")
				{
					pageOrder = new Vector.<DisplayObject>();
					pageRef = new Vector.<BasePage>();
					tearablePages = new Vector.<Boolean>();
					page=0;
				}
				else if (pageobj == "end")
				{
					maxpage = page-1;
				}
				_page = new MovieClip();
			}
			else
			{
				pageRef.push(pageobj as BasePage);
				_page = pageobj as DisplayObject;
				_page.addEventListener(PageEvent.BOOK_MARK, onBookMarkClick);
			}
			
			pageOrder[page] = _page;
			tearablePages[page] = tear;
			page++
		}
		
		private function onBookMarkClick(e:PageEvent):void 
		{
			gotoPage(e.index, fast_bookmark);
		}
		
		public function reset():void 
		{
			pages.p4.page.x = -PAGE_WIDTH;
			pages.p4.x = PAGE_WIDTH;
			pages.p1.page.x = -PAGE_WIDTH;
			pages.p1.x = 0;

			pages.flip.p2.page.x = -PAGE_WIDTH;
			pages.flip.p2.x = PAGE_WIDTH;
			pages.flip.p3.page.x = -PAGE_WIDTH;
			pages.flip.p3.x = 0;

			pages.p0.page.x = -PAGE_WIDTH;
			pages.p0.x = 0;
			pages.p5.page.x = -PAGE_WIDTH;
			pages.p5.x = PAGE_WIDTH;
			
			pages.pLL.page.x = -PAGE_WIDTH;
			pages.pLL.x = 0;
			pages.pLR.page.x = -PAGE_WIDTH;
			pages.pLR.x = PAGE_WIDTH;

			
			pages.pgrad.visible = pages._mask.visible = pages.flip.visible = false;
			pages.flip.p3mask.width = pages.pgmask.width = PAGE_WIDTH * 2;
			pages.flip.p3mask.height = pages.pgmask.height = PAGE_HEIGHT;
			pages.center.height = PAGE_HEIGHT + (2 * height_diff) - 1;
			//pages.center.y -= 1;
			pages.flip.fmask.page.pf.width = PAGE_WIDTH;
			pages.center.width = 6;
			pages.flip.fmask.page.pf.height = PAGE_HEIGHT;
			
			var m_height:Number = 2 * Math.sqrt(PAGE_HEIGHT * PAGE_HEIGHT + PAGE_WIDTH * PAGE_WIDTH);
			pages._mask.width = m_height;
			pages._mask.height = m_height;
			pages.pgrad.height = m_height;
			pages.flip.p3shadow.height = m_height;
			pages.flip.fgrad.height = m_height;
			
			pageNumber = new Array();
			for (var i:int = 0; i <= (maxpage + 1); i++) pageNumber[i] = i;
		}

		public function on_mouse_down(e:Event):void 
		{
			mouseDown = true;
			if (flip && !auto_flip) 
			{
				flipOK = false;	
				if (sx < 0 && pages.mouseX > 0) flipOK = true;
				if (sx > 0 && pages.mouseX < 0) flipOK = true;
				flipOff = true;
				flip = false;
			} else if((flipOff || auto_flip || !flip_enabled) && !pre_flip) {
				trace("donothing");
			} else if(!pre_flip) {
				var oox:Number = ox;
				var ooy:Number = oy;
				var osx:Number = sx;
				var osy:Number = sy;
				var hit:Number = hittest();		//hittest
				trace('hit:' + hit);
				if(hit) {
					playSound(1);		//Sound
					flip = true;
					flipOff = false;
					tear = false;			//not tearing yet...
					ox = sx = hit * PAGE_WIDTH;
					pages.flip.mask = pages._mask;
					mp_x = pages.mouseX;
					mp_y = pages.mouseY;
					render();
					//_quality = "MEDIUM";	//it is the place to degrade image quality while turning pages if the performance is too low.
				}
			} else {	//if preflipping
				playSound(1);		//Sound
				flip = true;
				flipOff = false;
				tear = false;			//not tearing yet...
				auto_flip = pre_flip = false;
				mp_x = pages.mouseX;
				mp_y = pages.mouseY;
				render();
			}
		}
		public function on_mouse_up(e:Event):void 
		{
			mouseDown = false;
			
			if (flip && !tear) 
			{
				if ((Math.abs(pages.mouseX) > (PAGE_WIDTH - afa) && Math.abs(pages.mouseY) > (PAGE_HEIGHT / 2 - afa) && Math.abs(pages.mouseX - mp_x) < afa) || pre_flip) 
				{
					flip = false;
					pre_flip = false;
					autoflip();
					playSound(2); //sound
				}
				else if (!pre_flip) 
				{
					pre_flip = false;
					flipOK = false;	
					if (sx<0 && pages.mouseX>0) flipOK = true;
					if (sx > 0 && pages.mouseX < 0) flipOK = true;
					flipOff = true;
					flip = false;
					if(flipOK) playSound(2); //sound
				}
			}
		}

		public function hittest():Number 
		{
			//hittest at mouse clicks, if click is over the book -> determining turning direction 
			var _x:Number = pages.mouseX;
			var _y:Number = pages.mouseY;
			var phh:Number = PAGE_HEIGHT/2;
			
			if (_y <= phh && _y >= -phh && _x <= PAGE_WIDTH && _x >= -PAGE_WIDTH) 
			{
				//If you click in the specified interval, then scroll
				var r:Number = Math.sqrt(_x * _x + _y * _y);
				var a:Number = Math.asin(_y / r);
				_y = Math.tan(a) * PAGE_WIDTH;
				if (_y > 0 && _y > PAGE_HEIGHT / 2) _y = PAGE_HEIGHT / 2;
				if (_y < 0 && _y < -PAGE_HEIGHT / 2) _y = - PAGE_HEIGHT / 2;
				oy = sy = _y;
				r0 = Math.sqrt((sy + PAGE_HEIGHT / 2) * (sy + PAGE_HEIGHT / 2) + PAGE_WIDTH * PAGE_WIDTH);
				r1 = Math.sqrt((PAGE_HEIGHT / 2 - sy) * (PAGE_HEIGHT / 2 - sy) + PAGE_WIDTH * PAGE_WIDTH);
				
				pageN = pages.flip.p2.page as MovieClip;
				pageO = pages.flip.p3 as MovieClip;
				offs = -PAGE_WIDTH;
				pages.flip.fmask.x = PAGE_WIDTH;
				
				if (_x < -(PAGE_WIDTH - clickarea) && page > 0) 
				{
					//>----->>> flip backward
					pages.flip.p3.x = 0;
					hard_flip = checkCover(page, -1);
					setPages(page-2, page-1, page, page + 1);
					tearable = tearablePages[page];
					return -1;
				}
				if (_x > (PAGE_WIDTH - clickarea) && page < maxpage)  
				{
					//<<<-----< flip forward
					pages.flip.p3.x = PAGE_WIDTH;
					hard_flip = checkCover(page, 1);
					setPages(page, page + 2, page + 1, page + 3);
					tearable = tearablePages[page+1];
					return 1;
				}
			} else return 0;//wrong click
			return 0;
		}
		public function checkCover(p:int, dir:int):Boolean
		{
			if (hard_cover) 
			{
				if (dir > 0)
				{
					if (p == (maxpage-2) || p == 0) return true;
				} 
				else
				{
					if (p == maxpage || p == 2) return true;
				}
			}
			return false;	
		}
		
		public function corner():Boolean 
		{
			var _x:Number = Math.abs(pages.mouseX);
			var _y:Number = Math.abs(pages.mouseY);
			if (_x > (PAGE_WIDTH - afa) && _x < PAGE_WIDTH && _y > (PAGE_HEIGHT / 2 - afa) && _y < (PAGE_HEIGHT / 2)) 
			{
				return true;
			}
			return false;
		}
		
		public function render(e:Event = null):void 
		{
			count++;
			
			if (!flip && corner())
			{
				pre_flip = true;
				if (!autoflip()) pre_flip = false;
			}
			
			if (pre_flip && !corner())
			{
				pre_flip = false;
				flip 	= false;
				flipOK 	= false;
				flipOff = true;
			}
			
			calc_ref();
			
			if (auto_flip && !pre_flip) 
			{
				mouse_y = (ay += (sy - ay) / (gflip? flip_speed: p_speed ));
				acnt += aadd;
				ax -= aadd;
				
				if (Math.abs(acnt) > PAGE_WIDTH) 
				{
					flipOK = true;
					flipOff = true;
					flip = false;
					auto_flip = false;
				}
			}
			
			if (flip) 
			{				
				//page turning is in progress...
				if(tear) {
					mouse_x = tox;
					mouse_y = (toy += teard);
					teard *= 1.2;
					if(Math.abs(teard)>1200) {
						flipOff = true;
						flip = false;
					}
				} else {
					mouse_x = (ox += (mouse_x - ox) / (gflip? flip_speed: p_speed ));
					mouse_y = (oy += (mouse_y - oy) / (gflip? flip_speed: p_speed ));
				}
				calc(mouse_x, mouse_y);	//positioning pages and shadows
			}
			
			if (flipOff) 
			{
				//terminating page turning effect... (comlplete turning... dropped on the other side)
				if (flipOK || tear) 
				{
					mouse_x = (ox += ( -sx - ox) / (gflip? auto_flip_speed: release_speed ));
					mouse_y = (oy += (sy - oy) / (gflip? auto_flip_speed: release_speed ));
					calc(mouse_x, mouse_y);
					if (mouse_x / -sx > 0.99 || tear) 
					{
						//we are done with turning, so stop all turning issue...
						flip = false;
						flipOK = flipOff = false;
						pages.pgrad.visible = pages.flip.visible = false;

						if (tear) 
						{				
							//if tear: remove page!!!
							removePage((sx < 0)? page: page + 1);
							page += (sx < 0)? -2: 0;
						} 
						else 
						{
							page += (sx < 0)? -2: 2;	//and tourning pages at pagenumber level...
						}
						
						if (skip_pages) page = gtarget;
						
						setPages(page, 0, 0, page + 1);
						tear = false;
						
						if (gpage > 0 && !skip_pages) 
						{
							//gotoflip active -> is there another flipping left?
							gpage--;
							autoflip();
							playSound(0);	//sound
						} 
						else 
						{
							gflip = skip_pages = false;
						}
					}
				} else 
				{				
					//terminating page turning effect... (incomlplete turning... dropped on the dragged side)
					mouse_x = (ox += (sx - ox) / 3);
					mouse_y = (oy += (sy - oy) / 3);
					calc(mouse_x, mouse_y);
					if (mouse_x / sx > 0.99) //we are done with turning, so stop all turning issue..
					{
						flip = false;
						flipOff = false;
						auto_flip = false;
						pages.pgrad.visible = pages.flip.visible = false;
						setPages(page, 0, 0, page + 1);	//no change at pagenumbers..
					}
				}
			}
		}

		public function calc(ref_x:Number, ref_y:Number):void 
		{
			if (hard_flip) 
			{
				var xp:Number = (sx<0)? -ref_x: ref_x;
				if (xp > 0) 
				{
					hard_page_2.visible = false;
					hard_page_3.visible = true;
					h_calc(hard_page_3,ref_x);
				} else {
					hard_page_3.visible = false;
					hard_page_2.visible = true;
					h_calc(hard_page_2,ref_x);
				}
				pages.flip.mask = null;
				pages.flip.visible = true;
				pages.flip.fgrad.visible = false;
				pages.flip.p2.visible = pages.flip.p3.visible = false;
				return;
			} else pages.flip.fgrad.visible = true;
			
			var rr0:Number = Math.sqrt((ref_y + PAGE_HEIGHT / 2) * (ref_y + PAGE_HEIGHT / 2) + ref_x * ref_x);
			var rr1:Number = Math.sqrt((PAGE_HEIGHT / 2 - ref_y) * (PAGE_HEIGHT / 2 - ref_y) + ref_x * ref_x);
			var a:Number;
			var r:Number;
			
			if ((rr0 > r0 || rr1 > r1) && !tear) 
			{
				if (ref_y < sy)
				{
					a = Math.asin((PAGE_HEIGHT / 2 - ref_y) / rr1);
					ref_y = (PAGE_HEIGHT / 2 - Math.sin(a) * r1);
					ref_x = (ref_x < 0)? -Math.cos(a) * r1: Math.cos(a) * r1;
					if (ref_y > sy) {
						if ((sx * ref_x) > 0) {
							ref_y = sy;
							ref_x = sx;
						}
						else 
						{
							ref_y = sy;
							ref_x = -sx;
						}
					}
					if ((rr1 - r1) > tlimit && tearable) {
						teard = -5;
						tear = true;
						tox = ox = ref_x;
						toy = oy = ref_y;
					}
				} else 
				{
					a = Math.asin((ref_y + PAGE_HEIGHT / 2) / rr0);
					ref_y = Math.sin(a) * r0 - PAGE_HEIGHT / 2;
					ref_x = (ref_x < 0)? -Math.cos(a) * r0: Math.cos(a) * r0;
					if (ref_y < sy) { 
						if ((sx * ref_x) > 0)
						{
							ref_y = sy;
							ref_x = sx;
						}
						else {
							ref_y = sy;
							ref_x = -sx;
						}
					}
					if ((rr0 - r0) > tlimit && tearable) { 
						teard = 5;
						tear = true;
						tox = ox = ref_x;
						toy = oy = ref_y;
					}
				}
			}
			if ((sx < 0 && (ref_x - sx) < 10) || (sx > 0 && (sx - ref_x) < 10)) {
				if (sx < 0) ref_x = -PAGE_WIDTH + 10;
				if (sx > 0) ref_x = PAGE_WIDTH - 10;
			} 
			
			pages.flip.visible = true;
			pages.flip.p3shadow.visible = pages.pgrad.visible = !tear;
			pages.flip.p2.visible = pages.flip.p3.visible = true;
			
			var vx:Number = ref_x - sx;
			var vy:Number = ref_y - sy;
			var a1:Number = vy / vx;
			var a2:Number = -vy / vx;
			
			cx = sx + (vx / 2);
			cy = sy + (vy / 2);
			
			r = Math.sqrt((sx - ref_x) * (sx - ref_x) + (sy - ref_y) * (sy - ref_y));
			a = Math.asin((sy - ref_y) / r);
			if (sx < 0) a = -a;
			ad = a / DEGREE_CONST; 	//in degree
			pageN.rotation = ad * 2;
			r = Math.sqrt((sx - ref_x) * (sx - ref_x) + (sy - ref_y) * (sy - ref_y));
			rl = (PAGE_WIDTH * 2);
			if (sx > 0) 
			{ 			
				//flip forward
				pages._mask.scaleX = 1;
				nx = cx - Math.tan(a) * (PAGE_HEIGHT / 2 - cy);
				ny = PAGE_HEIGHT / 2;
				if (nx > PAGE_WIDTH) 
				{ 
					nx = PAGE_WIDTH;
					ny = cy + Math.tan(Math.PI / 2 + a) * (PAGE_WIDTH - cx);
				}
				pageN.pf.x = -(PAGE_WIDTH - nx);
				pages.flip.fgrad.scaleX = ((r / rl / 2) * PAGE_WIDTH) / 100;
				pages.pgrad.scaleX = ( -(r / rl / 2) * PAGE_WIDTH) / 100;
				pages.flip.p3shadow.scaleX = ((r / rl / 2) * PAGE_WIDTH) / 100;
			} else 
			{ 				
				//flip backward
				pages._mask.scaleX = -1;
				nx = cx - Math.tan(a) * (PAGE_HEIGHT / 2 - cy);
				ny = PAGE_HEIGHT / 2;
				if (nx < -PAGE_WIDTH) 
				{
					nx = -PAGE_WIDTH;
					ny = cy + Math.tan(Math.PI / 2 + a) * ( -PAGE_WIDTH - cx);
				}
				pageN.pf.x = -(PAGE_WIDTH - (PAGE_WIDTH + nx));
				pages.flip.fgrad.scaleX = (-(r / rl / 2) * PAGE_WIDTH)/100;
				pages.pgrad.scaleX = ((r / rl / 2) * PAGE_WIDTH)/100;
				pages.flip.p3shadow.scaleX = ( -(r / rl / 2) * PAGE_WIDTH) / 100;
			}
			pages._mask.x = cx;
			pages._mask.y = cy;
			pages._mask.rotation = ad;
			pageN.pf.y = -ny;
			pageN.x = nx + offs;
			pageN.y = ny;
			pages.flip.fgrad.x = cx;
			pages.flip.fgrad.y = cy;
			pages.flip.fgrad.rotation = ad;
			pages.flip.fgrad.alpha = ((r > (rl - 50))? 100 - (r - (rl - 50)) * 2: 100)/100;
			pages.flip.p3shadow.x = cx;
			pages.flip.p3shadow.y = cy;
			pages.flip.p3shadow.rotation = ad;
			pages.flip.p3shadow.alpha = ((r > (rl - 50))? 100 - (r - (rl - 50)) * 2: 100)/100;
			pages.pgrad.x = cx;
			pages.pgrad.y = cy;
			pages.pgrad.rotation = ad + 180;
			pages.pgrad.alpha = ((r > (rl - 100))? 100 - (r - (rl - 100)): 100)/100;
			pages.flip.fmask.page.x = pageN.x;
			pages.flip.fmask.page.y = pageN.y;
			pages.flip.fmask.page.pf.x = pageN.pf.x;
			pages.flip.fmask.page.pf.y = pageN.pf.y;
			pages.flip.fmask.page.rotation = pageN.rotation;
		}

		public function h_calc(obj:MovieClip, ref_x:Number):void 
		{
			/**
			 * Hard flip calculations
			 */
			if (ref_x < -PAGE_WIDTH) ref_x = -PAGE_WIDTH;
			if (ref_x > PAGE_WIDTH) ref_x = PAGE_WIDTH;
			var a:Number = Math.asin( ref_x / PAGE_WIDTH );
			var rot:Number = a / DEGREE_CONST / 2;
			var xs:Number = 100;
			var ss:Number = 100 * Math.sin( rotz * DEGREE_CONST );
			ref_x = ref_x/2;
			var ref_y:Number = Math.cos(a)*(PAGE_WIDTH/2)*(ss/100);
			placeImage(obj, rot, ss, ref_x, ref_y)
			pages.pgrad.visible = pages.flip.visible = true;
			pages.pgrad.scaleX = ref_x/100;
			pages.pgrad.alpha = pages.flip.p3shadow.alpha = 1;
			pages.flip.p3shadow.scaleX = -ref_x/100;
			pages.flip.p3shadow.x = 0;
			pages.flip.p3shadow.y = 0;
			pages.flip.p3shadow.rotation = 0;
			pages.pgrad.x = 0;
			pages.pgrad.y = 0;
			pages.pgrad.rotation = 0;
		}

		public function placeImage(j:MovieClip, rot:Number, ss:Number, ref_x:Number, ref_y:Number ):void {
			var m:Number = Math.tan( rot * DEGREE_CONST );
			var f:Number = Math.SQRT2 / Math.sqrt(m * m + 1);
			var phxs:Number = 100 * m;
			var phRot:Number = -rot;
			var xs:Number = 100 * f;
			var ys:Number = 100 * f;
			j.ph.pic.rotation = 45;
			j.ph.pic.scaleX = ((phxs < 0)? - xs: xs)/100;
			j.ph.pic.scaleY = (ys * (100 / ss))/100;
			j.ph.rotation = phRot;
			j.ph.scaleX = phxs/100;
			j.scaleY = ss/100;
			j.x = ref_x;
			j.y = ref_y;
			j.visible = true;
		}

		public function setPages(p1:int, p2:int, p3:int, p4:int):void	
		{
			p0 = p1 - 2;
			p5 = p4 + 2;
			if (p0 < 0) p0 = 0;
			if (p5 > maxpage) p5 = 0;
			
			if (p1 < 0) p1 = 0;
			if (p2 < 0) p2 = 0;
			if (p3 < 0) p3 = 0;
			if (p4 < 0) p4 = 0;
			
			trace("setpages ->" + p1 + "," + p2 + "," + p3 + "," + p4);
			
			if (left_page != null && pages.p1.page.pf.ph.contains(left_page)) pages.p1.page.pf.ph.removeChild(left_page);
			
			left_page = pages.p1.page.pf.ph.addChild(pageOrder[p1]);
			left_page.x = 0;
			left_page.y = 0;
			pages.p1.page.pf.ph.y = -PAGE_HEIGHT/2;
			
			if (transparency) 
			{
				if (left_page_back != null && pages.p0.page.pf.ph.contains(left_page_back)) pages.p0.page.pf.ph.removeChild(left_page_back);
				left_page_back = pages.p0.page.pf.ph.addChild(pageOrder[p0]);
				pages.p0.page.pf.ph.y = -PAGE_HEIGHT / 2;
			} 
			else 
			{
				pages.p0.visible = false;
			}
			
			if (hard_flip) 
			{
				if (hard_page_2 != null && pages.flip.p2.page.pf.ph.contains(hard_page_2)) pages.flip.p2.page.pf.ph.removeChild(hard_page_2);
				if (hard_page_3 != null && pages.flip.p3.page.pf.ph.contains(hard_page_3)) pages.flip.p3.page.pf.ph.removeChild(hard_page_3);
				if (hard_page_2 != null && pages.flip.hfliph.contains(hard_page_2)) pages.flip.hfliph.removeChild(hard_page_2);
				if (hard_page_3 != null && pages.flip.hfliph.contains(hard_page_3)) pages.flip.hfliph.removeChild(hard_page_3);
				
				/**
				 * Hard page
				 */
				hard_page_2 = new HardPage();
				pages.flip.hfliph.addChild(hard_page_2);
				hard_page_2.ph.pic.addChild(pageOrder[p2]);
				pageOrder[p2].y = -PAGE_HEIGHT / 2;
				pageOrder[p2].x = -PAGE_WIDTH / 2;
				
				hard_page_3 = new HardPage();
				pages.flip.hfliph.addChild(hard_page_3);
				hard_page_3.ph.pic.addChild(pageOrder[p3]);
				pageOrder[p3].y = -PAGE_HEIGHT / 2;
				pageOrder[p3].x = -PAGE_WIDTH / 2;
				
			}
			else 
			{
				if (hard_page_2 != null && pages.flip.hfliph.contains(hard_page_2)) pages.flip.hfliph.removeChild(hard_page_2);
				if (hard_page_3 != null && pages.flip.hfliph.contains(hard_page_3)) pages.flip.hfliph.removeChild(hard_page_3);
				if (hard_page_2 != null && pages.flip.p2.page.pf.ph.contains(hard_page_2)) pages.flip.p2.page.pf.ph.removeChild(hard_page_2);
				if (hard_page_3 != null && pages.flip.p3.page.pf.ph.contains(hard_page_3)) pages.flip.p3.page.pf.ph.removeChild(hard_page_3);
				
				hard_page_2 = pages.flip.p2.page.pf.ph.addChild(pageOrder[p2]);
				hard_page_3 = pages.flip.p3.page.pf.ph.addChild(pageOrder[p3]);
				pages.flip.p2.page.pf.ph.y = -PAGE_HEIGHT / 2;
				pages.flip.p3.page.pf.ph.y = -PAGE_HEIGHT / 2;
				
			}
			
			if (right_page != null && pages.p4.page.pf.ph.contains(right_page)) pages.p4.page.pf.ph.removeChild(right_page);
			
			right_page = pages.p4.page.pf.ph.addChild(pageOrder[p4]);
			right_page.x = 0;
			right_page.y = 0;
			pages.p4.page.pf.ph.y = -PAGE_HEIGHT / 2;
			
			if (transparency) 
			{
				if (right_page_back != null && pages.p5.page.pf.ph.contains(right_page_back)) pages.p5.page.pf.ph.removeChild(right_page_back);
				
				right_page_back = pages.p5.page.pf.ph.addChild(pageOrder[p5]);
				pages.p5.page.pf.ph.y = -PAGE_HEIGHT / 2;
			} 
			else 
			{
				pages.p5.visible = false;
			}
			
			if (large_cover) 
			{
				var lpl:Number = transparency? p1 - 4: p1 - 2;
				var lpr:Number = transparency? p4 + 4: p4 + 2;
				var limit:Number = transparency? 0: -2;
				
				if (lpl > limit) 
				{
					if (pLL_page != null && pages.pLL.page.pf.ph.contains(pLL_page)) pages.pLL.page.pf.ph.removeChild(pLL_page);
					pLL_page = pages.pLL.page.pf.ph.addChild(pageOrder[2]);
					pages.pLL.page.pf.ph.y = -PAGE_HEIGHT/2;
					pages.pLL.visible = true;
					pageOrder[2].x = 0;
					pageOrder[2].y = 0;
				}
				else 
				{
					pages.pLL.visible = false;
				}
				
				if (lpr < (maxpage-limit)) 
				{
					if (pLR_page != null && pages.pLR.page.pf.ph.contains(pLR_page)) pages.pLR.page.pf.ph.removeChild(pLR_page);
					pLR_page = pages.pLR.page.pf.ph.addChild(pageOrder[maxpage-1]);
					pages.pLR.page.pf.ph.y = -PAGE_HEIGHT/2;
					pages.pLR.visible = true;
					pageOrder[maxpage-1].x = 0;
					pageOrder[maxpage-1].y = 0;
				}
				else 
				{
					pages.pLR.visible = false;
				}
			}
			/**
			 * Bookmark handler
			 */
			if (p4 == 1)
			{
				pages.setChildIndex(pages.bookmarks, bm_index);
			}
			for (var i:int = 0; i < bookmarks.length; i++)
			{
				if ( bookmarks[i].index == p3 + 1 || bookmarks[i].index == p3)
				{
					bookmarks[i].visible = false;
				}
				else
				{
					if (p2 > p3 && p4 != 1 && !mouseDown && (bookmarks[i].index == p2 || p1 == 0) )
					{
						if (p2 >= bookmarks[i].index)
						bookmarks[i].visible = false;
					}
					else
					{
						bookmarks[i].visible = true;
					}
				}
				
				if ( bookmarks[i].index < p4)
				{
					if (p4 < pageOrder.length - 1 ) pages.setChildIndex(pages.bookmarks, p1_index + 1);
					else pages.setChildIndex(pages.p1, pages.getChildIndex(pages.bookmarks) + 1);
					bookmarks[i].direction = "left";
					bookmarks[i].x = -(PAGE_WIDTH + bookmarks[i].width);
				}
				else
				{
					pages.setChildIndex(pages.p1, p1_index);
					bookmarks[i].direction = "right";
					bookmarks[i].x = PAGE_WIDTH;
				}
			}
		}

		public function resetPages():void 
		{
			setPages(page, 0, 0, page + 1);
		}
			
		public function autoflip():Boolean 
		{
			if (!auto_flip && !flip && !flipOff && flip_enabled) 
			{
				acnt = 0
				
				var phh:Number = PAGE_HEIGHT/2;
				var _x:Number = gflip? (direction * PAGE_WIDTH) / 2: ((pages.mouseX < 0)? -PAGE_WIDTH / 2: PAGE_WIDTH / 2);
				var _y:Number = pages.mouseY;
				
				if (_y > 0 && _y > phh) _y = phh;
				if (_y < 0 && _y < -phh) _y = - phh;
				
				oy = sy = _y;
				ax = (pages.mouseX < 0)? -phh: phh;
				ay = _y * Math.random();

				offs = -PAGE_WIDTH;
				var hit:int = 0;
				if (_x < 0 && page > 0) 
				{
					pages.flip.p3.x = 0;
					hard_flip = (hard_cover && skip_pages)? (page == maxpage || gtarget == 0): checkCover(page, -1);
					tearable = tearablePages[page];
					if (!(pre_flip && hard_flip))
					{
						if (skip_pages) setPages(gtarget, gtarget + 1, page, page + 1);
						else setPages(page-2, page-1, page, page + 1);
					}
					hit = -1;
				}
				if (_x > 0 && page < maxpage) 
				{
					pages.flip.p3.x = PAGE_WIDTH;
					hard_flip = (hard_cover && skip_pages)? (page == 0 || gtarget == maxpage): checkCover(page, 1);
					tearable = tearablePages[page + 1];
					if (!(pre_flip && hard_flip)) 
					{
						if (skip_pages) 
						{
							setPages(page, gtarget, page + 1, gtarget + 1);
						}
						else 
						{
							setPages(page, page + 2, page + 1, page + 3);
						}
					}
					hit = 1;
				}
				if (hard_flip && pre_flip) 
				{
					hit = 0;
					pre_flip = false;
					return false;
				}
				if (hit) 
				{
					flip = true;
					flipOff = false;
					ox = sx = hit * PAGE_WIDTH;
					pages.flip.mask = pages._mask;
					aadd = hit * (PAGE_WIDTH / (gflip? 5:10 ));
					auto_flip = true;
					pages.flip.fmask.x = PAGE_WIDTH;
					if(pre_flip) {
						oy = sy = (pages.mouseY < 0)? -(PAGE_HEIGHT / 2): (PAGE_HEIGHT / 2);
					}
					r0 = Math.sqrt((sy + PAGE_HEIGHT / 2) * (sy + PAGE_HEIGHT / 2) + PAGE_WIDTH * PAGE_WIDTH);
					r1 = Math.sqrt((PAGE_HEIGHT / 2 - sy) * (PAGE_HEIGHT / 2 - sy) + PAGE_WIDTH * PAGE_WIDTH);
					
					pageN = pages.flip.p2.page;
					pageO = pages.flip.p3;
					
					render();
					return true;
				}
			} else return false;
			return false;
		}

		public function calc_ref():void 
		{
			if (auto_flip && !pre_flip) 
			{
				mouse_x = ax;
				mouse_y = ay;
			}else
			{
				mouse_x = pages.mouseX;
				mouse_y = pages.mouseY;
			}
		}
		public function get currentPage():Vector.<BasePage>
		{
			var cp_tmp:Vector.<BasePage> = new Vector.<BasePage>();
			if (currentPageIndex > 0) cp_tmp.push(pageRef[currentPageIndex - 1]);
			if (currentPageIndex < pageRef.length) cp_tmp.push(pageRef[currentPageIndex]);
			return cp_tmp;
		}
		public function gotoPage(i:int, skip:Boolean = false):Boolean 
		{
			currentPageIndex = i;
			
			i = getPN(i);
			skip_pages = skip
			
			if (i < 0) return false;
			
			var p:int = int(page/2);
			var d:int = int(i/2);
			
			if (p != d && flip_enabled && !gflip) 
			{
				//target!=current page
				if(p<d) 
				{
					//go forward
					direction = 1;
					gpage = d - p - 1;
				} 
				else 
				{
					//go backward
					direction = -1
					gpage = p - d - 1;
				}
				
				gflip = true;
				if (skip_pages) gtarget = d * 2, gpage = 0;
				autoflip();
				playSound(0);
			} else skip_pages = false;
			return false;
		}
		public function getPN(i:int):Number 
		{
			if(i==0) return 0;
			var find:Boolean = false;
			for (var j:int = 1; j <= maxpage; j++) 
			{
				if (i == pageNumber[j]) 
				{
					i = j;
					find = true;
					break;
				}
			}
			if (find) return i;
			else return -1;
		}
		public function removePage(i:int):void 
		{
			trace("remove page "+i);
			i = (Math.floor((i - 1) / 2) * 2) + 1;
			removedPages.push(pageNumber[i], pageNumber[i + 1]);
			
			for (var j:int = (i + 2); j <= (maxpage + 1); j++) 
			{
				pageOrder[j - 2] = pageOrder[j];
				tearablePages[j - 2] = tearablePages[j];
				pageNumber[j - 2] = pageNumber[j];
			}
			trace("removed pages " + i + "," + (i + 1));
			trace(removedPages.join(", "));
			maxpage -= 2;
		}
		
		public function playSound(i:int):void 
		{
			if(sound_enabled) {
				if (i == 0) 
				{
					channel = sound_0.play();
					channel.soundTransform = new SoundTransform();
					sound_0.addEventListener(Event.COMPLETE, function (e:Event):void {
						channel.stop();
						playSound(2);
					});
				} else {
					i--;
					channel = this["sound_" + i].play();
					channel.soundTransform = new SoundTransform();
				}
			}
		}
		
		public function startAutoFlip(sec:Number):void {
			if(isNaN(sec)) sec = 2;
			intervalID = setInterval(nextPage, sec * 1000);
		}
		public function stopAutoFlip ():void {
			clearInterval(intervalID);
		}
		public function prevPage():void {
			gotoPage(page - 2);
		}
		public function nextPage():void {
			gotoPage(page + 2);
		}
	}
}
