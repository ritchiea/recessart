/*
* jQuery RTE plugin 0.5.1 - create a rich text form for Mozilla, Opera, Safari and Internet Explorer
*
* Copyright (c) 2009 Batiste Bieler
* Distributed under the GPL Licenses.
* Distributed under the MIT License.
* 
* 11/5/10 - Andrew Lee, modified for FLUXX use
*/

// define the rte light plugin
(function($) {

if(typeof $.fn.rte === "undefined") {

    var defaults = {
        media_url: "",
        content_css_url: "rte.css",
        dot_net_button_class: null,
        bold: false,
        italic: false,
        underline: false,
        strikethrough: false,
        unorderedlist: false,
        link: false,
        image: false,
        disable: false
    };

    $.fn.rte = function(options) {

    $.fn.rte.html = function(iframe) {
        return iframe.contentWindow.document.getElementsByTagName("body")[0].innerHTML;
    };

    // build main options before element iteration
    var opts = $.extend(defaults, options);
    
    if (opts.hasOwnProperty('buttons')) {
      var b = opts.buttons; 
      for ( var i=b.length-1; i>=0; --i ){
        opts[b[i]] = true;
      }
    }

    // iterate and construct the RTEs
    return this.each( function() {
        var textarea = $(this);
        var iframe;
        var element_id = textarea.attr("id");

        // enable design mode
        function enableDesignMode() {

            var content = textarea.val();

            // Mozilla needs this to display caret
            if($.trim(content)=='') {
                content = '<br />';
            }

            // already created? show/hide
            if(iframe) {
                console.log("already created");
                textarea.hide();
                $(iframe).contents().find("body").html(content);
                $(iframe).show();
                $("#toolbar-" + element_id).remove();
                textarea.before(toolbar());
                return true;
            }

            // for compatibility reasons, need to be created this way
            iframe = document.createElement("iframe");
            iframe.frameBorder=0;
            iframe.frameMargin=0;
            iframe.framePadding=0;            

//            iframe.height=200;
            if(textarea.attr('class'))
                iframe.className = textarea.attr('class');
            if(textarea.attr('id'))
                iframe.id = element_id;
            if(textarea.attr('name'))
                iframe.title = textarea.attr('name');

            textarea.after(iframe);
            
            //TODO: Setting the height of the text input element.
            //      This should not be hardcoded, but I can not find any other way atm.
            var heightAdjust = 260;
            iframe.height=textarea.fluxxCard().height() - heightAdjust;
            $('.body', textarea.fluxxCardArea()).css('overflow', 'hidden');
            $(window).resize(function(e){
              iframe.height=textarea.fluxxCard().height() - heightAdjust;
            });

            var css = "";
            if(opts.content_css_url) {
                css = "<link type='text/css' rel='stylesheet' href='" + opts.content_css_url + "' />";
            }

            var doc = "<html><head>"+css+"</head><body class='frameBody'>"+content+"</body></html>";
            tryEnableDesignMode(doc, function() {
                $("#toolbar-" + element_id).remove();
                textarea.before(toolbar());
                // hide textarea
                textarea.hide();

            });

        }

        function tryEnableDesignMode(doc, callback) {
            if(!iframe) { return false; }

            try {
                iframe.contentWindow.document.open();
                iframe.contentWindow.document.write(doc);
                iframe.contentWindow.document.close();
            } catch(error) {
                //console.log(error);
            }
            if (document.contentEditable) {
                iframe.contentWindow.document.designMode = "On";
                callback();
                return true;
            }
            else if (document.designMode != null) {
                try {
                    iframe.contentWindow.document.designMode = "on";
                    callback();
                    return true;
                } catch (error) {
                    //console.log(error);
                }
            }
            setTimeout(function(){tryEnableDesignMode(doc, callback)}, 500);
            return false;
        }

        function disableDesignMode(submit) {
            var content = $(iframe).contents().find("body").html();

            if($(iframe).is(":visible")) {
                textarea.val(content);
            }

            if(submit !== true) {
                textarea.show();
                $(iframe).hide();
            }
        }

        // create toolbar and bind events to it's elements
        function toolbar() {
            var timestamp = Number(new Date());
            var tb = $("<div class='rte-toolbar' id='toolbar-"+ element_id + timestamp +"'><div>" +
//                <p>\
//                    <select>\
//                        <option value=''>Block style</option>\
//                        <option value='p'>Paragraph</option>\
//                        <option value='h3'>Title</option>\
//                        <option value='address'>Address</option>\
//                    </select>\
//                </p>\
                "<p>" +
                    (opts.bold ? "<a href='#' class='bold' title='Bold'><img src='"+opts.media_url+"text_bold.png' alt='bold' /></a> " : "") +
                    (opts.italic ? "<a href='#' class='italic' title='Italic'><img src='"+opts.media_url+"text_italic.png' alt='italic' /></a> " : "") +
                    (opts.underline ? "<a href='#' class='underline' title='Underline'><img src='"+opts.media_url+"text_underline.png' alt='underline' /></a> " : "") +
                    (opts.strikethrough ? "<a href='#' class='strikethrough' title='Strikethrough'><img src='"+opts.media_url+"text_strikethrough.png' alt='strikethrough' /></a> " : "") +
                    (opts.unorderedlist ? "<a href='#' class='unorderedlist' title='List'><img src='"+opts.media_url+"text_list_bullets.png' alt='unordered list' /></a> " : "") +
                    (opts.link ? "<a href='#' class='link' title='Add Link'><img src='"+opts.media_url+"link.png?t=1' alt='link' /></a> " : "") +
                    (opts.image ? "<a href='#' class='image' title='Add Image'><img src='"+opts.media_url+"image.png?t=1' alt='image' /></a> " : "") +
                    (opts.disable ? "<a href='#' class='disable' title='Plain Text'><img src='"+opts.media_url+"code.png' alt='close rte' /></a> " : "") +
                "</p></div></div>");

            $('select', tb).change(function(){
                var index = this.selectedIndex;
                if( index!=0 ) {
                    var selected = this.options[index].value;
                    formatText("formatblock", '<'+selected+'>');
                }
            });
            $('.bold', tb).click(function(){ formatText('bold');return false; });
            $('.italic', tb).click(function(){ formatText('italic');return false; });
            $('.underline', tb).click(function(){ formatText('underline');return false; });
            $('.strikethrough', tb).click(function(){ formatText('strikethrough');return false; });
            $('.unorderedlist', tb).click(function(){ formatText('insertunorderedlist');return false; });
            $('.link', tb).click(function(){
                var p=prompt("URL:");
                if(p)
                    formatText('CreateLink', p);
                return false; });

            $('.image', tb).click(function(){
                var p=prompt("image URL:");
                if(p)
                    formatText('InsertImage', p);
                return false; });

            $('.disable', tb).click(function() {
                disableDesignMode();
                var edm = $('<a class="rte-edm" href="#">Enable design mode</a>');
                tb.empty().append(edm);
                edm.click(function(e){
                    e.preventDefault();
                    enableDesignMode();
                    // remove, for good measure
                    $(this).remove();
                });
                return false;
            });

            // .NET compatability
            if(opts.dot_net_button_class) {
                var dot_net_button = $(iframe).parents('form').find(opts.dot_net_button_class);
                dot_net_button.click(function() {
                    disableDesignMode(true);
                });
            // Regular forms
            } else {
                $(iframe).parents('form').submit(function(){
                    disableDesignMode(true);
                });
            }

            var iframeDoc = $(iframe.contentWindow.document);

            var select = $('select', tb)[0];
            iframeDoc.mouseup(function(){
                setSelectedType(getSelectionElement(), select);
                return true;
            });

            iframeDoc.keyup(function() {
                setSelectedType(getSelectionElement(), select);
                var body = $('body', iframeDoc);
                if(body.scrollTop() > 0) {
                    var iframe_height = parseInt(iframe.style['height'])
                    if(isNaN(iframe_height))
                        iframe_height = 0;
//                    var h = Math.min(opts.max_height, iframe_height+body.scrollTop()) + 'px';
//                    iframe.style['height'] = h;
                }
                return true;
            });
 
            return tb;
        };

        function formatText(command, option) {
            iframe.contentWindow.focus();
            try{
                iframe.contentWindow.document.execCommand(command, false, option);
            }catch(e){
                //console.log(e)
            }
            iframe.contentWindow.focus();
        };

        function setSelectedType(node, select) {
            if (!select)
                return;
            while(node.parentNode) {
                var nName = node.nodeName.toLowerCase();
                for(var i=0;i<select.options.length;i++) {
                    if(nName==select.options[i].value){
                        select.selectedIndex=i;
                        return true;
                    }
                }
                node = node.parentNode;
            }
            select.selectedIndex=0;
            return true;
        };

        function getSelectionElement() {
            if (iframe.contentWindow.document.selection) {
                // IE selections
                selection = iframe.contentWindow.document.selection;
                range = selection.createRange();
                try {
                    node = range.parentElement();
                }
                catch (e) {
                    return false;
                }
            } else {
                // Mozilla selections
                try {
                    selection = iframe.contentWindow.getSelection();
                    range = selection.getRangeAt(0);
                }
                catch(e){
                    return false;
                }
                node = range.commonAncestorContainer;
            }
            return node;
        };
        
        // enable design mode now
        enableDesignMode();

    }); //return this.each
    
    }; // rte

} // if

})(jQuery);
