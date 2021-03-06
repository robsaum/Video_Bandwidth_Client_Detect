//--------------------------------------------------------------------------
// initial variables that might be useful to change
//--------------------------------------------------------------------------

// toggle for which file to play if none was set in html
// you can change the 'test.flv' in your filename
if(!_root.file) { file = 'video.flv' } else { file = _root.file; }

// toggle for autostarting the video
// you can change the 'true' in 'false'
if(_root.autoStart == 'true') {
	autoStart = true;
} else {
	autoStart = false;
}
if(_root.clicktext) {
	playText.text = _root.clicktext;
}


// toggle for the width and height of the video
// you can change them to the width and height you want
w = Stage.width;
h = Stage.height;

//--------------------------------------------------------------------------
// stream setup and functions
//--------------------------------------------------------------------------

// create and set netstream
nc = new NetConnection();
nc.connect("rtmp://vc1.dbcc.edu/MUL1010/video");
ns = new NetStream(nc);

// create and set sound object
this.createEmptyMovieClip("snd", 0);
snd.attachAudio(ns);
audio = new Sound(snd);
audio.setVolume(80);

//attach videodisplay
videoDisplay.smoothing = true;
videoDisplay.attachVideo(ns);

// Retrieve duration meta data from netstream
ns.onMetaData = function(obj) {
	this.totalTime = obj.duration;
	// these three lines were used for automatically sizing
	// it is now done by sizing the video to stage dimensions
	// if(obj.height > 0 && obj.height < Stage.height-20) {
	// setDims(obj.width, obj.height);
	// }
};

// retrieve status messages from netstream
ns.onStatus = function(object) {
	if(object.code == "NetStream.Play.Stop") {
		// rewind and pause on when movie is finished
		ns.seek(0);
		if(_root.repeat == 'true') { return; } 
		ns.pause();
		playBut._visible = true;
		pauseBut._visible = false;
		videoDisplay._visible = false;
		playText.txt.text = "click to play";
	}
};


//--------------------------------------------------------------------------
// controlbar functionality
//--------------------------------------------------------------------------

// play the movie and hide playbutton
function playMovie() {
	if(!isStarted) {
		ns.play(file);
		playText.txt.text = "loading ..";
		isStarted = true;
	} else {
		ns.pause();
	}
	pauseBut._visible = true;
	playBut._visible = false;
	videoDisplay._visible = true;
	this._quality = "BEST";
}

// pause the movie and hide pausebutton
function pauseMovie() {
	ns.pause();
	playBut._visible = true;
	pauseBut._visible = false;
};

// video click action
videoBg.onPress = function() {
	trace(_quality);
	if(pauseBut._visible == false) {
		playMovie();
	} else {
		pauseMovie();
	}
};

// pause button action
pauseBut.onPress = function() {
	pauseMovie();
};

// play button action
playBut.onPress = function() {
	playMovie();
};

// file load progress
progressBar.onEnterFrame = function() {
	loaded = this._parent.ns.bytesLoaded;
	total = this._parent.ns.bytesTotal;
	if (loaded == total && loaded > 1000) {
		this.loa._xscale = 100;
		delete this.onEnterFrame;
	} else {
		this.loa._xscale = int(loaded/total*100);
	}
};

// play progress function
progressBar.tme.onEnterFrame = function() {
	this._xscale = ns.time/ns.totalTime*100;
};

// start playhead scrubbing
progressBar.loa.onPress = function() {
	this.onEnterFrame = function() {
		scl = (this._xmouse/this._width)*(this._xscale/100)*(this._xscale/100);
		if(scl < 0.02) { scl = 0; }
		ns.seek(scl*ns.totalTime);
	};
};

// stop playhead scrubbing
progressBar.loa.onRelease = progressBar.loa.onReleaseOutside = function () { 
	delete this.onEnterFrame;
	pauseBut._visible == false ? videoDisplay.pause() : null;
};

// volume scrubbing
volumeBar.back.onPress = function() {
	this.onEnterFrame = function() {
		var xm = this._xmouse;
		if(xm>=0 && xm <= 20) {
			this._parent.mask._width = this._xmouse;
			this._parent._parent.audio.setVolume(this._xmouse*5);
		}
	};
}
volumeBar.back.onRelease = volumeBar.back.onReleaseOutside = function() {
	delete this.onEnterFrame;
}

//--------------------------------------------------------------------------
// resize and position all items
//--------------------------------------------------------------------------
function setDims(w,h) {
	// set videodisplay dimensions
	videoDisplay._width = videoBg._width = w;
	videoDisplay._height = videoBg._height = h-20;
	playText._x = w/2-120;
	playText._y = h/2-20;
		
	// resize the items on the left .. 
	playBut._y = pauseBut._y = progressBar._y = volumeBar._y = h-20;
	progressBar._width = w-56;
	volumeBar._x = w-38;
}

// here you can ovverride the dimensions of the video
setDims(w,h);



//--------------------------------------------------------------------------
// all done ? start the movie !
//--------------------------------------------------------------------------

// start playing the movie
// if no autoStart it searches for a placeholder jpg
// and hides the pauseBut

pauseBut._visible = false;
if(_root.image) { 
	imageStr = _root.image;
} else {
	imageStr = substring(file,0,file.length-3)+"jpg";
}
imageClip.loadMovie(imageStr);
if (autoStart == true) { playMovie(); }