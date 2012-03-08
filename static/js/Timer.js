var Timer = function (time, id) {
	this.startTime = 0; //開始時間
	this.elapsedTime = 0; //経過時間
	this.endTime = time; //終了時間
	this.timerID = undefined; //TimerID
	this.id = id; //時間表示のオブジェクトID
	this.callbacks = new Array();
}
Timer.prototype = {
	/* タイマーの開始 */
	start : function () {
		/* 既にタイマーが動いている場合は終了 */
		if ( this.timerID ) {
			return;
		}
		/* 終了時間を越えた場合は初期化 */
		if ( this.elapsedTime > this.endTime ) {
			this.elapsedTime = 0;
		}
		
		this.startTime = new Date().getTime();
		var self = this;
		self.timerID = setInterval(function () {self.display(self);}, 100);
		//self.timerID = setTimeout(function () { self.callback(); }, self.endTime );
	},
	/* 経過時間の表示 */
	display : function (self) {
		var currentTime = new Date().getTime();
		self.elapsedTime += (currentTime - self.startTime);
		/* 現在の時間の更新 */
		self.startTime = currentTime;
		/* 終了時間を越えた場合、timerIDを初期化し、コールバック */
		if ( self.elapsedTime > self.endTime ) {
			clearInterval(self.timerID);
			self.timerID = undefined;
			self.callback();
			self.elapsedTime = self.endTime;
		}
		document.getElementById(self.id).innerHTML = self.elapsedTime;
	},
	/* タイマーの停止 */
	stop : function () {
		/* タイマーが動いている場合 */
		if ( this.timerID ) {
			//clearInterval(this.timerID);
			/* timerIDのクリア */
			clearTimeout(this.timerID);
			this.timerID = undefined;
			/* 経過時間の更新 */
			var currentTime = new Date().getTime();
			this.elapsedTime += (currentTime - this.startTime);
			document.getElementById(this.id).innerHTML = this.elapsedTime;
		}
	},
	/* タイマーのクリア */
	clear : function () {
		clearInterval(this.timerID);
		this.timerID = undefined;
		this.elapsedTime = 0;
		document.getElementById(this.id).innerHTML = "0";
	},
	/* コールバック */
	callback : function () {
		for ( var i = 0; i < this.callbacks.length; i++ ) {
			this.callbacks[i]();
		}
	},
	/* コールバックの追加 */
	addListener : function ( callback ) {
		this.callbacks.push(callback);
	},
	/* コールバックの削除 */
	removeListener : function ( callback ) {
		for ( var i = 0; i < this.callbacks.length; i++ ) {
			if ( this.callbacks[i] === callback ) {
				this.callbacks.splice(i,1);
				break;
			}
		}
	},
};


var SampleTimer = new Timer(1000, "time");
/* タイマーの作成 */
var timer = document.createElement('div');
timer.style.position = "absolute";
timer.style.top = "80px";
timer.style.right = "200px";
timer.id = 'timer';
/* 経過時間の表示部分 */
var time = document.createElement('p');
time.id = "time";
time.innerHTML = "0";
timer.appendChild(time);

/* スタートボタンの作成 */
var startButton = document.createElement('img');
startButton.src = "images/start.png";
startButton.className = "timerbutton";
startButton.addEventListener('click', function () { SampleTimer.start();}, false);
timer.appendChild(startButton);

/* ストップボタンの作成 */
var stopButton = document.createElement('img');
stopButton.src = "images/stop.png";
stopButton.className = "timerbutton";
stopButton.addEventListener('click', function () { SampleTimer.stop();}, false);
timer.appendChild(stopButton);

/* クリアボタンの作成 */
var clearButton = document.createElement('img');
clearButton.src = "images/clear.png";
clearButton.className = "timerbutton";
clearButton.addEventListener('click', function () { SampleTimer.clear(); }, false);
timer.appendChild(clearButton);


document.body.appendChild(timer);

function test () {
	alert("callback");
}

SampleTimer.addListener(function(){ alert("callback1"); });
SampleTimer.addListener(function(){ alert("callback2"); });

SampleTimer.addListener(test);
SampleTimer.removeListener(test);