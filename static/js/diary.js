var PageManager = Class.create();
PageManager.prototype = {
	/* コンストラクタ*/
	initialize: function (page) {
		this.page = page;
		this.default_page = page;
	},
	/* エントリの追加 */
	add: function () {
		this.page++;
		var self = this;
		var xhr = new XMLHttpRequest();
		xhr.open('GET', '/API/?page=' + this.page, true);
		xhr.onreadystatechange = function (e) { 
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					var entry_list = document.getElementById('entry_list');
					var data = eval("(" + xhr.responseText + ")");
					
					for ( var id in data.entries ) {
						var entry = data.entries[id];
						var section = self.createEntry(entry, id);
						entry_list.appendChild(section);
					}
					self.updatePager(data.has_pre);
				} else {
					alert('error');
				}
			}
		};
		xhr.send(null);
	},
	/* エントリの生成 */
	createEntry: function (entry, id) {
		var section = document.createElement('section');
		section.className = 'entry_item';
		
		section.appendChild(this.createEntryHeader(entry, id));
		section.appendChild(this.createEntryBody(entry));
		section.appendChild(this.createEntryFooter(entry));
		
		return section;
	},
	/* エントリのヘッダを生成 */
	createEntryHeader: function (entry, id) {
		var header = document.createElement('header');
		var link = document.createElement('a');
		link.href = "/diary?id=" + id;
		link.innerHTML = entry.title;
		header.appendChild(link);
		header.appendChild(document.createTextNode(" [ "));
		for ( cid in entry.categories ) {
			var category = document.createElement('a');
			category.href = "/category?id=" + cid;
			category.innerHTML = entry.categories[cid].name;
			header.appendChild(category);
		}
		header.appendChild(document.createTextNode(" ] "));
		
		return header;
	},
	/* エントリの本文を生成 */
	createEntryBody: function (entry) {
		var body = document.createElement('p');
		body.innerHTML = entry.body;
		
		return body;
	},
	/* エントリのフッタを生成 */
	createEntryFooter: function (entry) {
		var footer = document.createElement('footer');
		footer.innerHTML = entry.created_on;
		
		return footer;
	},
	/* エントリを削除 */
	remove: function () {
		this.page--;
		var entry_list = document.getElementById('entry_list');
		var entries = entry_list.getElementsByTagName('section');

		var limit = 3;
		for (var i = entries.length-1;; i-- ) {
			var entry = entries[i];
			entry_list.removeChild(entries[i]);
			if ( i % limit == 0 ) { break; }
		}
		
		this.updatePager(1);
	},
	/* ページャを更新 */
	updatePager: function (has_pre) {
		this.updatePreLink(has_pre);
		
		var center = document.getElementById('center');
		this.updateUpArrow(center);
		this.updateDownArrow(center, has_pre);
	},
	/* 前のエントリへのリンクを更新 */
	updatePreLink: function (has_pre) {
		var pre_link = document.getElementById('pre_link');
		if ( pre_link ) {
			if ( has_pre == 1 ) {
				pre_link.href = "/?page=" + (this.page+1);
			} else {
				var pre = document.getElementById('pre');
				pre.removeChild(pre_link);
			}
		} else {
			if ( has_pre == 1 ) {
				pre_link = document.createElement('a');
				pre_link.id = 'pre_link';
				pre_link.href = "/?page=" + (this.page+1);
				pre_link.innerHTML = "前"
				var pre = document.getElementById('pre');
				pre.appendChild(pre_link);
			}
		}
	},
	/* 前のエントリへのリンク(AJAX)を更新 */
	updateUpArrow: function (center) {
		var arrow_up = document.getElementById('arrow_up');
		if ( arrow_up && this.page <= this.default_page ) {
			center.removeChild(arrow_up);
		} else if ( !arrow_up && this.page > this.default_page ) {
			var self = this;
			arrow_up = document.createElement('img');
			arrow_up.id = 'arrow_up';
			arrow_up.src = 'images/arrow_up.png';
			arrow_up.addEventListener('click', function() {
				self.remove();
			});
			center.insertBefore(arrow_up, center.firstChild);
		}
	},
	/* 次のエントリへのリンク(AJAX)を更新 */
	updateDownArrow: function (center, has_pre) {
		var arrow_down = document.getElementById('arrow_down');
		if ( arrow_down && has_pre != 1) {
			center.removeChild(arrow_down);
		} else if ( !arrow_down && has_pre == 1) {
			var self = this;
			arrow_down = document.createElement('img');
			arrow_down.id = 'arrow_down';
			arrow_down.src = "images/arrow_down.png";
			arrow_down.addEventListener('click', function () { self.add(); });
			center.appendChild(arrow_down);
		}
	},
	
};

