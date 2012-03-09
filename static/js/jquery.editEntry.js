(function($) {
	
	$.editEntry = function (id) {
		this.id = id;
		this.getEntryItem();
	}
	
	$.extend ( $.editEntry.prototype, {
		getEntryItem : function () {
			var $section = $("#entry_list").find("section#" + this.id);
			var $header = $section.find('header');
			var $children = $header.children('a');
			
			this.title = $($children[0]).text();
			var category = {};
			for ( var i = 1; i < $children.size(); i++ ) {
				category[$($children[i]).attr('id')] = $($children[i]).text();
			}
			this.categories = category;
			this.body = $section.find('p').text();
			this.created_on = $section.find('footer').text();
		},
		
		openForm : function () {
			var edit = this;
			var $section = $("#entry_list").find("section#" + this.id);
			$section.html(this.createForm());

			var $buttons = $section.find('button');
			$($buttons[0]).click( function () {	edit.closeForm();	});
			$($buttons[1]).click( function () { edit.postEntry(); });
		},
		
		createForm : function () {
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
		
		closeForm : function () {
			var edit = this;
			var $section = $("#entry_list").find("section#" + this.id);
			$section.html(this.createEntry());
			
			$section.find('button').click(function () {	edit.openForm(); });
		},
		
		createEntry : function () {
			var html = ""
			+ "<header><a href='/diary?id=" + this.id + "'>" + this.title + "</a>"
			+ " [ ";
			for (var id in this.categories) {
				html += "<a href='/category?id=" + id + "' id='" + id + "'>" + this.categories[id] +"</a> ";
			}
			//+ $section.find('#category').attr('value')
			html += "] "
			+ "<button type='button'>編集</button>"
			+ "</header>"
			+ "<p>" + this.body + "</p>"
			+ "<footer>" + this.created_on + "</footer>";
			
			return html;
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