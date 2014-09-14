// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-tmpl
//= require twitter/bootstrap
//= require_tree ../templates
//= require i18n
//= require i18n/translations
//= require_tree .
//= require_self


//=# require plupload
//=# require jquery.plupload.queue 
//=# require plupload.settings 
//=# require plupload.flash        
//=# require plupload.silverlight  
//=# require plupload.html4        
//=# require plupload.html5        
//=# require plupload.gears        
//=# require plupload.browserplus
//= require moxie
//= require plupload.dev
//= require plupload/i18n/de
//= require plupload.settings
//= require jquery.plupload.queue

function show_element(element) {
    if($('#'+element) == null) { element = 'files_and_folders'; }
    $('#files_and_folders, #permissions, #clipboard').fadeOut('fast')
    $('#'+element).fadeIn('fast');

}

function update_counter(element, counter) {
    $(counter).innerHTML = element.value.length;
    $(counter).style.color = element.value.length > 256 ? '#F00' : '#000';
}

function icon(name){
    return $('<i>').addClass('icon-'+name).wrapAll('<div></div>').parent().html()+' ';
}

function document_icon(extension){
    if($.inArray(extension, ['pdf','doc','docx','odt','txt','html','rtf']) >= 0)
        return icon("file-"+extension);
    else
        return icon("file");
}

function document_status(i){
    var status = new Array(
        { icon: icon('upload'), text: I18n.t('upload') },
        { icon: icon('time'), text: I18n.t('in_queue'), badge: 'badge' },
        { icon: icon('cus-loading'), text: I18n.t('indexing'), badge: 'badge badge-inverse' },
        { icon: icon('ok'), text: I18n.t('ready'), badge: 'badge badge-success' }            
    );
    return (i<0 || i>=status.length) ? { icon: icon('warning-sign'), text: I18n.t('error'), badge: 'badge badge-important' } : status[i];
}

function document_status_html(i){
    var status = document_status(i);
    return (
        (i == 0) ? 
        $('<div>').addClass('progress progress-striped active').append(
            $('<div>').addClass('bar').css('width', '0%').html(status.icon+status.text)
        ): 
        $('<span>').addClass(status.badge).html(status.icon+status.text)
    ).wrapAll('<div></div>').parent().html();
}

function scan_status(i){
    var status = new Array(
        { icon: icon('time'), text: I18n.t('in_queue'), badge: 'badge' },
        { icon: icon('cus-loading'), text: I18n.t('scanning'), badge: 'badge badge-info' },
        { icon: icon('ok'), text: I18n.t('completed'), badge: 'badge badge-success' }    
    );
    return (i<0 || i>=status.length) ? { icon: 'icons/no.png', text: I18n.t('error') } : status[i];
}

function scan_status_html(i){
    var status = scan_status(i);
    return (
        (i == 1) ? 
        $('<div>')
        .append($('<span>').addClass(status.badge).css({'float': 'left', 'margin-right':'5px'}).html(status.icon+status.text))
        .append($('<div>').addClass('progress progress-striped active')
            .append($('<div>').addClass('bar').css({'width': '0%'}))
        )
        : $('<span>').addClass(status.badge).html(status.icon+status.text)
    ).wrapAll('<div></div>').parent().html();
}

function truncate(str, limit) {
    var bits, i;
    bits = str.split('');
    if (bits.length > limit) {
        for (i = bits.length - 1; i > -1; --i) {
            if (i > limit) {
                bits.length = i;
            }
            else if (' ' === bits[i]) {
                bits.length = i;
                break;
            }
        }
        bits.push('...');
    }
    return bits.join('');
}


function format(doc) {
    return document_icon(doc.attachment_file_type)+doc.name;
}

$(function () {
    $("[rel='tooltip']").tooltip();
    $("[rel='tooltip nofollow']").tooltip();
    $("[rel='nofollow']").tooltip();
    $(".accordion-toggle a").click(function(e){
        e.stopPropagation();
    })
    /*
    Typeahead.prototype.select = function () {
        var val = JSON.parse(this.$menu.find('.active').attr('data-value')), text
        text = val[this.options.property];
        this.$element.val(text);
        if (typeof this.onselect == "function")
            this.onselect(val);
        return this.hide();
    };
    */
    $('.typeahead').typeahead({
        display: "name",
        val: "id",
        ajax: {
            url: '/typeahead',
            //timeout: 300,
            method: 'post',
            triggerLength: 3,
            //preDispatch: null,
            loadingClass: 'loading',
            //displayField: null,
            //preDispatch: null,
            preProcess: function (data) {
                documents = new Array();
                $.each(data, function(i, doc){
                    documents.push(doc.document);
                });
                return documents;
            }
        },
        select: function () {
            var $selectedItem = this.$menu.find('.active');
            if($selectedItem.length >0)
                this.$element.val($selectedItem.text()).change();
            this.options.itemSelected($selectedItem, $selectedItem.attr('data-value'), $selectedItem.text());
            return this.hide();
        },
        itemSelected: function($el,id,name){
            if(id)
                window.location.href = "/documents/"+id;
            else
                $('.navbar-search').submit();
        },
        render: function (items) {
            var that = this;

            items = $(items).map(function (i, item) {
                i = $(that.options.item).attr('data-value', item[that.options.val]);
                i.find('a').html(document_icon(item.attachment_file_type)+that.highlighter(item[that.options.display], item));
                return i[0];
            });

            items.first().addClass('active');
            this.$menu.html(items);
            return this;
        }
        /*source: function (query, process) {
            var that = this;
            return $.post('/typeahead', { query: query }, function (data) {
                documents = new Array();
                $.each(data, function(i, doc){
                    documents.push(doc.document);
                });
                return process(documents);
            });
        },
        sorter: function(items){return items;},
        matcher: function(item){return true;},
        highlighter: function(doc) {
            return document_icon(doc.attachment_file_type)+doc.name.replace(new RegExp('(' + this.query + ')', 'ig'), function ($1, match) {
                return '<strong>' + match + '</strong>';
            });
        }*/
    });
    /*
    $('.typeahead').select2({
        placeholder: "Search for a Document...",
        minimumInputLength: 3,
        ajax: {
            url: "/typeahead",
            dataType: 'jsonp',
            quietMillis: 100,
            data: function (query, page) { // page is the one-based page number tracked by Select2
                return {
                    query: query, //search term
                    page_limit: 10, // page size
                    page: page // page number
                };
            },
            results: function (data, page) {
                var more = (page * 10) < data.total; 
                return {results: data.documents, more: more};
            }
        },
        formatResult: function (document) {
            return icon(document.attachment_file_type)+document.name;
        }, 
        formatSelection: function(document) {
            return document.name;
        }, 
        dropdownCssClass: "bigdrop", 
        escapeMarkup: function (m) { return m; } 
    });*/

});
