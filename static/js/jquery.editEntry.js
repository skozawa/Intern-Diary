(function($) {
    
    $.editEntry = function (id) {
        this.id = id; //エントリID
        this.getEntryItem(); 
        this.tempData = undefined; //一時保存用
    }
    
    $.extend ( $.editEntry.prototype, {
        /* HTMLをパースし、エントリのタイトル、カテゴリ、本文、作成日時を取得 */
        getEntryItem : function () {
            /* 新規作成の場合はHTMLをパースしない */
            if ( this.id == "new_entry" ) {
                this.title = "";
                this.body = "";
                return;
            }
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
            this.createdOn = $section.find('footer').text();
            
        },
        
        /* フォームを開く */
        openForm : function () {
            var edit = this;
            var $section = $("#entry_list").find("section#" + this.id);
            /* フォームの作成 */
            //$section.html(this.createForm());
            this.createForm($section);
            
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
        /* フォームの作成 */
        createForm : function ($section) {
            /* 要素をクリア */
            $section.empty();
            
            /* 連想配列からカテゴリ名を取得し、配列に保存 */
            var categoryTexts = [];
            for (var id in this.categories) {
                categoryTexts.push(this.categories[id]);
            }
            
            /* タイトルの作成 */
            var $inputTitle = $('<input type="text">');
            $inputTitle.attr({ name : 'title', id : "title"});
            $inputTitle.val(this.title);
            $section.append($('<p>タイトル</p>').append($inputTitle));
            
            /* カテゴリの作成 */
            var $inputCategory = $('<input type="text">');
            $inputCategory.attr({ name : 'category', id : "category" });
            $inputCategory.val(categoryTexts);
            $section.append($('<p>カテゴリ</p>').append($inputCategory));
            
            /* 本文の作成 */
            var $textareaBody = $('<textarea>');
            $textareaBody.attr({ name : "body", id : "body"});
            $textareaBody.val(this.body);
            $section.append($('<p>本文</p>').append($textareaBody));
            
            /* ボタンの作成 */
            var $buttons = $('<p>');
            $buttons.attr("class", "submit_button");
            
            var $closeButton = $('<button type="button">閉じる</button>');
            $buttons.append($closeButton);
            var $saveButton = $('<button type="button">保存</button>');
            $buttons.append($saveButton);
            
            /* ボタンへのイベント追加 */
            var edit = this;
            /* 新規作成の場合 */
            if ( this.id == "new_entry" ) {
                $closeButton.click( function () { edit.closeAddForm(); });
                $saveButton.click( function () { edit.postEntry(); });
            }
            /* 編集の場合 */
            else {
                $closeButton.click( function () { edit.closeModifyForm(); });
                $saveButton.click( function () { edit.postEntry(); });
            }
            if ( this.id != "new_entry" ) {
                var $deleteButton = $('<button type="button">削除</button>');
                $buttons.append($deleteButton);
                $deleteButton.click( function () { edit.deleteEntry(); });
            }
            $section.append($buttons);
        },
        
        /* 作成用フォームを閉じる */
        closeAddForm : function () {
            var edit = this;
            var $section = $("#entry_list").find("section#new_entry");
            /* 「作成」ボタン */
            $section.html("<button type='button'>作成</button>");
            
            /* 「作成」ボタンにイベントを割り当てる */
            $section.find('button').click(function () { edit.openForm(); });
        },
        
        /* 編集用フォームを閉じる */
        closeModifyForm : function () {
            var edit = this;
            var $section = $("#entry_list").find("section#" + this.id);
            /* 表示用HTMLの作成 */
            //$section.html(this.createDisplay());
            this.createDisplay($section);
            
            /* 「編集」ボタンにイベントを割り当てる */
            $section.find('button').click(function () { edit.openForm(); });
        },
        /* 表示用のHTMLを作成 */
        createDisplay : function ($section) {
            /* 要素をクリア */
            $section.empty();
                        
            var $header = $('<header>');
            /* タイトル */
            var $aTitle = $('<a>');
            $aTitle.attr('href', '/diary?id=' + this.id);
            $aTitle.text(this.title);
            $header.append($aTitle);
            /* カテゴリ */
            $header.append(" [ ");
            for (var id in this.categories) {
                var $aCategory = $('<a>');
                $aCategory.attr({ href : "/category?id=" + id, id : id });
                $aCategory.text(this.categories[id]);
                $header.append($aCategory);
                $header.append(" ");
            }
            $header.append("] ");
            /* 編集ボタン */
            $header.append($('<button type="button">編集</button>'));
            $section.append($header);
            /* 本文 */
            var $pBody = $('<p>');
            $pBody.text(this.body);
            $section.append($pBody);
            /* フッター */
            var $footer = $('<footer>');
            $footer.text(this.createdOn);
            $section.append($footer);
        },
        
        /* エントリをPostで送信する */
        postEntry : function () {
            var edit = this;
            var data = this.makePostData();
            var url = "/API/index.edit";
            if ( this.id == "new_entry" ) {
                url = "/API/index.add";
            }
            if ( data.title != "" && data.body != "" ) {
                $.ajax ({
                    url : url,
                    type : "POST",
                    data : data,
                    datatype : "json",
                    success : function (res) { edit.successPostEntry(res); },
                    error : edit.errorAjax,
                    complete : function () { edit.completePostEntry();},
                });
            } else {
                alert("タイトル及び本文は必須です");
            }
        },
        /* Postするデータを作成 */
        makePostData : function () {
            var $section = $("#entry_list").find("section#" + this.id);
            var title = $section.find('#title').attr('value');
            var category = $section.find('#category').attr('value');
            var body = $section.find('#body').attr('value');
            
            var data = {
                title : title,
                category : category,
                body : body,
            };
            if ( this.id != "new_entry" ) {
                data.id = this.id;
            }
            return data;
        },
        
        /* XHRに成功した場合、タイトルなどの値を更新し、フォームを閉じる */
        /* XHRが完了するまでは、「編集」ボタンにイベントを追加しない */
        successPostEntry : function (res) {
            var data = res;
            this.title = data.title;
            this.categories = data.categories;
            this.body = data.body;
                        
            var edit = this;
            var $section = $("#entry_list").find("section#" + this.id);
            /* 新規作成の場合 */
            if ( this.id == "new_entry" ) {
                this.id = data.id;
                this.createdOn = data.created_on;
                $section.attr("id", this.id);
                $section.attr("class", "entry_item");
                /* 「作成」ボタンを追加 */
                createAddButton();
            }
            //$section.html(this.createDisplay());
            this.createDisplay($section);
            
            /* 一時データは削除 */
            this.tempData = undefined;
        },
        /* XHRが完了したら、「編集」ボタンにイベントを追加 */
        completePostEntry : function () {
            var edit = this;
            var $section = $("#entry_list").find("section#" + this.id);
            $section.find('button').click(function () { edit.openForm(); });
        },
        
        /* 削除するIDを送信 */
        deleteEntry : function () {
            var edit = this;
            data = { id : this.id };
            
            if ( window.confirm("削除しますか？", "「" + this.title + "」の削除") ) {
                $.ajax ({
                    url : "/API/index.delete",
                    type : "POST",
                    data : data,
                    datatype : "json",
                    success : function (res) { edit.successDelete(); },
                    error : edit.errorAjax,
                    complete : function () { edit.completeDelete(); }
                });
            }
        },
        /* エントリのノードを削除 */
        successDelete : function () {
            $("section#" + this.id).remove();
        },
        completeDelete : function () {
            
        },
        /* XHRに失敗した場合、編集用フォームを閉じる */
        errorAjax : function () {
            alert("error");
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
        }
    });
    
    $.fn.editEntry = function () {
        return this.each(function () {
            (new $.editEntry(this));
        });
    }

})(jQuery);

/* 「作成」ボタンの作成 */
var createAddButton = function () {
    var $section = $("<section/>");
    $section.attr("id","new_entry");
    var $button = $("<button/>");
    $button.attr("type", "button");
    $button.text("作成");
    var $edit = this;
    $button.click(function () {
        new $.editEntry("new_entry").openForm();
    });
    $section.append($button);
    $("#entry_list").prepend($section);
}

/* 「編集」ボタンを作成 */
var createEditButton = function () {
    $("section").each( function () {
        /* エントリにボタンがあるか */
        if ( !$(this).find("button").size() ) {
            var $button = $("<button/>");
            $button.attr("type", "button");
            $button.text("編集");
            var $edit = this;
            $button.click(function () {
                new $.editEntry($edit.id).openForm();
            });
            $(this).find("header").append($button);
        }
    });
}

$(function() {
    createAddButton();
    createEditButton();
});