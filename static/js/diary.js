var PageManager = new Ten.Class({
	/* コンストラクタ*/
	initialize : function (page) {
		this.page = page; //現在表示しているページ
		this.default_page = page; //URIから読み出したページ
	},
},{
	/* エントリの追加 */
	add : function () {
		/* 表示数が3エントリ以上であれば、次のページのエントリを表示(その場編集機能への対応) */
		var sections = entry_list.getElementsByTagName('section');
		if ( sections.length > 3 ) { this.page++; }
		
		var self = this;
		new Ten.XHR('/API/?page=' + this.page, {}, function (res) {
			var entry_list = document.getElementById('entry_list');
			var data = eval("(" + res.responseText + ")");
			
			/* 現在表示されているエントリのIDを取得 */
			var sections = entry_list.getElementsByTagName('section');
			var section_ids = {};
			for ( var i = 0; i < sections.length ; i++ ) {
				section_ids[sections[i].id] = 1;
			}
			
			/* エントリの追加 */
			for ( var id in data.entries ) {
				var entry = data.entries[id];
				/* 既に表示されていれば、追加しない */
				if ( section_ids[id] == 1) { continue; }				
				entry_list.appendChild(self.createEntry(entry, id));
			}
			/* ページャの更新 */
			self.updatePager(data.has_pre);
			
			/* その場編集機能用 */
			createEditButton();
		});
	},
	/* エントリの生成 */
	createEntry : function (entry, id) {
		var section = document.createElement('section');
		section.className = 'entry_item';
		section.id = id;
		
		section.appendChild(this.createEntryHeader(entry, id));
		section.appendChild(this.createEntryBody(entry));
		section.appendChild(this.createEntryFooter(entry));
		
		return section;
	},
	/* エントリのヘッダを生成 */
	createEntryHeader : function (entry, id) {
		var header = document.createElement('header');
		var link = document.createElement('a');
		link.href = "/diary?id=" + id;
		link.appendChild(document.createTextNode(entry.title));
		header.appendChild(link);
		header.appendChild(document.createTextNode(" [ "));
		/* カテゴリの追加 */
		for ( cid in entry.categories ) {
			var category = document.createElement('a');
			category.href = "/category?id=" + cid;
			category.id = cid;
			category.appendChild(document.createTextNode(entry.categories[cid].name));
			header.appendChild(category);
			header.appendChild(document.createTextNode(" "));
		}
		header.appendChild(document.createTextNode("] "));
		
		return header;
	},
	/* エントリの本文を生成 */
	createEntryBody : function (entry) {
		var body = document.createElement('p');
		body.appendChild(document.createTextNode(entry.body));
		
		return body;
	},
	/* エントリのフッタを生成 */
	createEntryFooter : function (entry) {
		var footer = document.createElement('footer');
		footer.appendChild(document.createTextNode(entry.created_on));
		
		return footer;
	},
	/* エントリを削除 */
	remove : function () {
		this.page--;
		var entry_list = document.getElementById('entry_list');
		var entries = entry_list.getElementsByTagName('section');
		
		var limit = 3;
		/* 3(表示数)の倍数になるまでエントリを削除 */
		for (var i = entries.length-1;; i-- ) {
			var entry = entries[i];
			entry_list.removeChild(entries[i]);
			if ( i % limit == 1) { break; }
		}
		/* ページャの更新 */
		this.updatePager(1);
	},
	/* ページャを更新 */
	updatePager : function (has_pre) {
		this.updatePreLink(has_pre);
		
		var center = document.getElementById('center');
		this.updateUpArrow(center);
		this.updateDownArrow(center, has_pre);
	},
	/* 前のエントリへのリンクを更新 */
	updatePreLink : function (has_pre) {
		var pre_link = document.getElementById('pre_link');
		/* 既にリンクが存在しているか */
		if ( pre_link ) {
			/* 読み込み対象のエントリが存在する場合，ページ数の更新 */
			if ( has_pre == 1 ) {
				pre_link.href = "/?page=" + (this.page+1);
			}
			/* 存在しない場合、リンクを削除 */
			else {
				var pre = document.getElementById('pre');
				pre.removeChild(pre_link);
			}
		}
		/* リンクが存在しない場合 */
		else {
			/* 読み込み対象のエントリが存在すれば、リンクを追加 */
			if ( has_pre == 1 ) {
				pre_link = document.createElement('a');
				pre_link.id = 'pre_link';
				pre_link.href = "/?page=" + (this.page+1);
				pre_link.appendChild(document.createTextNode('前'));
				var pre = document.getElementById('pre');
				pre.appendChild(pre_link);
			}
		}
	},
	/* 前のエントリへのリンク(AJAX)を更新 */
	updateUpArrow : function (center) {
		var arrow_up = document.getElementById('arrow_up');
		/* 矢印が存在し、初期の表示に戻る場合は矢印を削除 */
		if ( arrow_up && this.page <= this.default_page ) {
			center.removeChild(arrow_up);
		}
		/* 矢印がなく、初期表示のページ番号より現在のページ番号が大きい場合、矢印を追加 */
		else if ( !arrow_up && this.page > this.default_page ) {
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
	updateDownArrow : function (center, has_pre) {
		var arrow_down = document.getElementById('arrow_down');
		/* 前のエントリがなければ、矢印を削除 */
		if ( arrow_down && has_pre != 1) {
			center.removeChild(arrow_down);
		}
		/* 前のエントリがあれば、矢印を追加 */
		else if ( !arrow_down && has_pre == 1) {
			var self = this;
			arrow_down = document.createElement('img');
			arrow_down.id = 'arrow_down';
			arrow_down.src = "images/arrow_down.png";
			arrow_down.addEventListener('click', function () { self.add(); });
			center.appendChild(arrow_down);
		}
	}
});

