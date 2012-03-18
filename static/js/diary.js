var PageManager = new Ten.Class({
    /* コンストラクタ*/
    initialize : function (page) {
        this.page = page; //現在表示しているページ
        this.defaultPage = page; //URIから読み出したページ
    },
},{
    /* エントリの追加 */
    add : function () {
        /* 表示数が3エントリ以上であれば、次のページのエントリを表示(その場編集機能への対応) */
        var entryList = document.getElementById('entry_list');
        var sections = entryList.getElementsByTagName('section');
        if ( sections.length > 3 ) { this.page++; }
        
        var self = this;
        new Ten.XHR('/API/?page=' + this.page, {}, function (res) {
            var entryList = document.getElementById('entry_list');
            var data = eval("(" + res.responseText + ")");
            
            /* 現在表示されているエントリのIDを取得 */
            var sections = entryList.getElementsByTagName('section');
            var sectionIds = {};
            for ( var i = 0; i < sections.length ; i++ ) {
                sectionIds[sections[i].id] = 1;
            }
            
            /* エントリの追加 */
            for ( var id in data.entries ) {
                var entry = data.entries[id];
                /* 既に表示されていれば、追加しない */
                if ( sectionIds[id] == 1) { continue; }                
                entryList.appendChild(self.createEntry(entry, id));
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
        var entryList = document.getElementById('entry_list');
        var entries = entryList.getElementsByTagName('section');
        
        var limit = 3;
        /* 3(表示数)の倍数になるまでエントリを削除 */
        for (var i = entries.length-1;; i-- ) {
            var entry = entries[i];
            entryList.removeChild(entries[i]);
            if ( i % limit == 1) { break; }
        }
        /* ページャの更新 */
        this.updatePager(1);
    },
    /* ページャを更新 */
    updatePager : function (hasPre) {
        this.updatePreLink(hasPre);
        
        var center = document.getElementById('center');
        this.updateUpArrow(center);
        this.updateDownArrow(center, hasPre);
    },
    /* 前のエントリへのリンクを更新 */
    updatePreLink : function (hasPre) {
        var preLink = document.getElementById('pre_link');
        /* 既にリンクが存在しているか */
        if ( preLink ) {
            /* 読み込み対象のエントリが存在する場合，ページ数の更新 */
            if ( hasPre ) {
                preLink.href = "/?page=" + (this.page+1);
            }
            /* 存在しない場合、リンクを削除 */
            else {
                var pre = document.getElementById('pre');
                pre.removeChild(preLink);
            }
        }
        /* リンクが存在しない場合 */
        else {
            /* 読み込み対象のエントリが存在すれば、リンクを追加 */
            if ( hasPre ) {
                preLink = document.createElement('a');
                preLink.id = 'pre_link';
                preLink.href = "/?page=" + (this.page+1);
                preLink.appendChild(document.createTextNode('前'));
                var pre = document.getElementById('pre');
                pre.appendChild(preLink);
            }
        }
    },
    /* 前のエントリへのリンク(AJAX)を更新 */
    updateUpArrow : function (center) {
        var arrowUp = document.getElementById('arrow_up');
        /* 矢印が存在し、初期の表示に戻る場合は矢印を削除 */
        if ( arrowUp && this.page <= this.defaultPage ) {
            center.removeChild(arrowUp);
        }
        /* 矢印がなく、初期表示のページ番号より現在のページ番号が大きい場合、矢印を追加 */
        else if ( !arrowUp && this.page > this.defaultPage ) {
            var self = this;
            arrowUp = document.createElement('img');
            arrowUp.id = 'arrow_up';
            arrowUp.src = 'images/arrow_up.png';
            arrowUp.addEventListener('click', function() {
                self.remove();
            });
            center.insertBefore(arrowUp, center.firstChild);
        }
    },
    /* 次のエントリへのリンク(AJAX)を更新 */
    updateDownArrow : function (center, hasPre) {
        var arrowDown = document.getElementById('arrow_down');
        /* 前のエントリがなければ、矢印を削除 */
        if ( arrowDown && !hasPre ) {
            center.removeChild(arrowDown);
        }
        /* 前のエントリがあれば、矢印を追加 */
        else if ( !arrowDown && !hasPre ) {
            var self = this;
            arrowDown = document.createElement('img');
            arrowDown.id = 'arrow_down';
            arrowDown.src = "images/arrow_down.png";
            arrowDown.addEventListener('click', function () { self.add(); });
            center.appendChild(arrowDown);
        }
    }
});

