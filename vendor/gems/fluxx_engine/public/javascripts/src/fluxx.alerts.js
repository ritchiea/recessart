//TODO:
//   - Refactor using jQuery UI .dialog()
//   - Remove simplemodal including css styles and images
//   - Refactor dashboard manager to use dialog instead of simplemodal
//   - Confirm that nothing else uses simplemodal
//   - Remove jquery.alerts.js and all styling
//   - Refactor dashboard manager prompts to use fluxx.ajerts.js
(function($){
  var DEBUG = true;
  var D = function (args) { if (DEBUG) console.log('jquery.colorbox.alerts', args) };
  
  var AlertClass = function (options) {
    var defaults = {
      text: null,
      isCanceled: false
    };
    return $.extend(defaults, options);
  }
  
  var ui = {
    titleBar:     function(o) {return $('<div/>').addClass('title-bar').text(o.text)},
    promptInput:  function(o) {return $('<form class="prompt-form"><textarea class="prompt-input">'+(o.text || '')+'</textarea>')},
    cancelButton: function(o) {return $('<a/>').addClass('cancel-button').attr('href','#').html(o.text)},
    okButton:     function(o) {return $('<ul class="ok-buttons"><li><a href="#" class="ok-button">'+o.text+'</a></li></ul>')},
    clearDiv:     function(o) {return $('<div class="clear"></div>')},
    box:          function(o) {
      D(['box', o]);
      var $box = $('<div class="jquery-alert" />');
      var $content = $('<div class="content" />');
      $.each(o.elements, function () { $content.append(this) });
      return $('<div/>').append($box.append($content)).html();
    }
  };

  $.extend($, {
    _box: function (options) {
      if (!options) options = {};
      var onOK = options.onOK; delete options.onOK;      
      var defaults = {
        elements: [ $('<div/>').text('It is a box.') ],
        scrolling: false,
        onShow: function(box){
          $('.cancel-button', '.jquery-alert').click(function(e){
            $.modal.close();
            e.preventDefault();
            e.stopImmediatePropagation();
          });
          $('.ok-button', '.jquery-alert').click(function(e){
            var $colorbox = box.data;
            var promptInput = $(this).parents('.jquery-alert').find('.prompt-input').val();
            $colorbox.data('onOK', function(){
              if (onOK) {
                onOK(AlertClass({
                  text: promptInput,
                  isCanceled: false
                }));
              }
            });
            $.modal.close();
            e.preventDefault();
            e.stopImmediatePropagation();
            return false;
          });
        },
        onClose: function (box) {
          var $colorbox = box.data;
          var onOK = $colorbox.data('onOK');
          (onOK || $.noop)();
          $colorbox.data('onOK', null);
          $.modal.close();
        }
      };
      var options = $.extend(defaults, options);

      var html = ui.box({elements: options.elements});
      delete options.elements;
      delete options.title;
      
      if (!options.html) options.html = html;
      options = $.extend(
        {
          //closeHTML: '<span>Close</span>',
          //close:true,
          overlayClose:true,
          escClose:true,
          opacity: 50,
          onShow:function(d){d.container.hide().fadeIn('slow')},
          onClose:function(d){d.overlay.fadeOut('slow');d.container.fadeOut('slow');$.modal.close()}
        },
        options
      );
      D(options.html, options);
      $.modal(options.html, options);
    },
    prompt: function (options) {
      if (!options) options = {};
      var defaults = {
        elements: [
                    ui.titleBar({text: options.title || 'Prompt'}),
                    ui.promptInput({}),
                    ui.cancelButton({text: 'Cancel'}),
                    ui.okButton({text: 'OK'}),
                    ui.clearDiv()
                  ]
      };
      $._box($.extend(defaults, options));
    },
    confirm: function (options) {
      if (!options) options = {};
      var defaults = {
        elements: [
                    ui.titleBar({text: options.title || 'Confirm'}),
                    ui.cancelButton({text: 'Cancel'}),
                    ui.okButton({text: 'OK'}),
                    ui.clearDiv()
                  ]
      };
      $._box($.extend(defaults, options));
    },
    alert: function (options) {
      if (!options) options = {};
      var defaults = {
        elements: [
                    ui.titleBar({text: options.title || 'Alert!'}),
                    ui.okButton({text: 'Close'}),
                    ui.clearDiv()
                  ],
      };
      $._box($.extend(defaults, options));
    }
  })
})(jQuery);