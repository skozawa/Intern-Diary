(function($) {
	
	$.editEntry = function (id) {
		this.id = id; //エントリID
		this.getEntryItem(); 
		this.tempData = undefined; //一時保存用
	}
	
	$.extend ( $.editEntry.prototype, {
		/* HTMLをパースし、エントリのタイトル、カテゴリ、本文、作成日時を取得 */
		getEntryItem : function () {
			var $section = $("#entry_list").find("section#" + this.id);
			var $header = $section.find('header');
			var $children = $header.children('a');
			var category = {};
			for ( var i = 1; i < $children.size(); i++ ) {
				category[$($children[i]).attr('id')] = $($children[i]).text();
			}
			
			this.title = $($children[0]).text();
			this.categories = category;
			this.body = $section.find('p').text();
			this.created_on = $section.find('footer').text();
			
		},
		/* 編集フォームを開く */
		openForm : function () {
			var edit = this;
			var $section = $("#entry_list").find("section#" + this.id);
			/* 編集用フォームの作成 */
			$section.html(this.createForm());
			
			var $buttons = $section.find('button');
			/* 「閉じる」ボタンにイベントを割り当てる */
			$($buttons[0]).click( function () {	edit.closeForm(); });
			/* 「保存」ボタンにイベントを割り当てる */
			$($buttons[1]).click( function () { edit.postEntry(); });
			
			/* フォームに変更があった場合、データを一時的に保存する */
			$section.find("input,textarea").change(function() { edit.tempStore(); });
			
			/* 前回のデータが残っている場合はリンクを追加 */
			if ( this.tempData ) {
				var $div = $("<span/>");
				$div.attr("id", "temp_link");
				$div.text("前回の状態に戻す");
				$div.click(function () { edit.restoreData(); });
				$section.find("#title").before($div);
			}
		},
		/* 編集用のフォームの作成 */
		createForm : function () {
			/* 連想配列からカテゴリ名を取得し、配列に保存 */
			var category_texts = [];
			for (var id in this.categories) {
				category_texts.push(this.categories[id]);
			}
			
			var html = ""
			+ "<p>タイトル<input type='text' name='title' id='title' value='" + this.title + "'></p>"
			+ "<p>カテゴリ(コンマ区切り)<input type='text' name='category' id='category' value='" + category_texts + "'></p>"
			+ "<p>本文<textarea name='body' id='body'>" + this.body + "</textarea></p>"
			+ "<p class='submit_button'>"
			+ "<button type='button'>閉じる</button>"
			+ "<button type='button'>保存</button>"
			+ "</p>";
			
			return html;
		},
		/* 編集用フォームを閉じる */
		closeForm : function () {
			var edit = this;
			var $section = $("#entry_list").find("section#" + this.id);
			/* 表示用HTMLの作成 */
			$section.html(this.createEntry());
			
			/* 「編集」ボタンにイベントを割り当てる */
			$section.find('button').click(function () {	edit.openForm(); });
		},
		/* 表示用のHTMLを作成 */
		createEntry : function () {
			var html = ""
			+ "<header><a href='/diary?id=" + this.id + "'>" + this.title + "</a>"
			+ " [ ";
			for (var id in this.categories) {
				html += "<a href='/category?id=" + id + "' id='" + id + "'>" + this.categories[id] +"</a> ";
			}
			html += "] "
			+ "<button type='button'>編集</button>"
			+ "</header>"
			+ "<p>" + this.body + "</p>"
			+ "<footer>" + this.created_on + "</footer>";
			
			return html;
		},
		/* 編集内容をAjaxで /API/index.editに送信 */
		postEntry : function () {
			var edit = this;
			var data = this.makePostData();
			
			$.ajax ({
				url : "/API/index.edit",
				type : "POST",
				data : data,
				datatype : "json",
				success : function (res) { edit.successAjax(res); },
				error : edit.errorAjax,
				complete : function () {edit.completeAjax();},
			});
		},
		/* Postするデータを作成 */
		makePostData : function () {
			var $section = $("#entry_list").find("section#" + this.id);
			var title = $section.find('#title').attr('value');
			var category = $section.find('#category').attr('value');
			var body = $section.find('#body').attr('value');
			
			return {
				id : this.id,
				title : title,
				category : category,
				body : body,
			};
		},
		/* XHRに成功した場合、タイトルなどの値を更新し、編集用フォームを閉じる */
		/* XHRが完了するまでは、「編集」ボタンにイベントを追加しない */
		successAjax : function (res) {
			//alert("success");
			var data = eval("(" + res + ")");
			this.title = data.title;
			this.categories = data.categories;
			this.body = data.body;
			
			var edit = this;
			var $section = $("#entry_list").find("section#" + this.id);
			$section.html(this.createEntry());
			
			/* 一時データは削除 */
			this.tempData = undefined;
		},
		/* XHRに失敗した場合、編集用フォームを閉じる */
		errorAjax : function () {
			alert("error");
			this.closeForm();
		},
		/* XHRが完了したら、「編集」ボタンにイベントを追加 */
		completeAjax : function () {
			var edit = this;
			var $section = $("#entry_list").find("section#" + this.id);
			$section.find('button').click(function () {	edit.openForm(); });
		},
		/* フォームに変更があった場合、データを一時的に保存しておく */
		tempStore : function () {
			var $section = $("#entry_list").find("section#" + this.id);
			var title = $section.find('#title').attr('value');
			var category = $section.find('#category').attr('value');
			var body = $section.find('#body').attr('value');
			
			this.tempData = { title: title, category: category, body: body,};
		},
		/* 前回のデータを復元 */
		restoreData : function () {
			var $section = $("#entry_list").find("section#" + this.id);
			/* フォームの値を復元 */
			var title = $section.find('#title').attr('value', this.tempData.title);
			var category = $section.find('#category').attr('value', this.tempData.category);
			var body = $section.find('#body').attr('value', this.tempData.body);
			/* 一時データを破棄し、リンクを削除 */
			this.tempData = undefined;
			$section.find("#temp_link").empty();
		},
	});
	
	$.fn.editEntry = function () {
		return this.each(function () {
			(new $.editEntry(this));
		});
	}

})(jQuery);


$(function() {
	$("section").each( function () {
		var $button = $("<button/>");
		$button.attr("type", "button");
		$button.text("編集");
		var $edit = this;
		$button.click(function () {
			new $.editEntry($edit.id).openForm();
		});
		$(this).find("header").append($button);
	});
});