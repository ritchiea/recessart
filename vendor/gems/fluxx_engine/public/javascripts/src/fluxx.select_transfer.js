(function($){
  $.fn.extend({
    selectTransfer: function(options, callback) {
      var defaults = {
        className: 'select-transfer',
        callback: $.noop
      };
      var options = $.extend(defaults, options, {callback: callback});
      return this.each(function(){
        var $original = $(this);
        var $container = $([
          '<div class="', options.className, '">',
            '<select class="unselected" multiple="multiple"></select>',
            '<div class="controls">',
              '<input type="button" value="&gt;" class="select" />',
              '<div class="break"></div>',
              '<input type="button" value="&lt;" class="unselect"/>',
            '</div>',
            '<select class="selected" multiple="multiple"></select>',
          '</div>'
        ].join('')).css({
          height: 100,
          display: $original.css('display')
        });
        var $unselected = $('.unselected', $container).keydown(function(e){
          if (e.which == 39) {
            $('.select', $container).click();
          }
        });
        var $selected = $('.selected', $container).keydown(function(e){
          if (e.which == 37) {
            $('.unselect', $container).click();
          }
        });

        var $controls = $('.controls', $container);
        var $copy = $original.clone();
        $copy.find(':selected').appendTo($selected);
        $copy.children().appendTo($unselected);

        $('select', $container).css({
          width: '40%',
          height: '100%'
        });
        $controls.css({
          width: '20%',
          display: 'inline-block',
          verticalAlign: 'top',
          textAlign: 'center'
        });
        $('input', $controls).css({
          width: '40%',
          margin: 'auto'
        });
        $('.break', $controls).css({
          height: 24
        });

        var updateOriginal = function() {
          var sel = [];
          $selected.children().each(function () {
            sel.push($(this).val());
          });
          $original.val(sel).change();
        };

        var $select = $('.select', $container).click(function() {
          $unselected.find(':selected').remove().appendTo($selected);
          updateOriginal();
        });
        var $unselect = $('.unselect', $container).click(function() {
          $selected.find(':selected').remove().appendTo($unselected);
          updateOriginal();
        });

        $unselected.dblclick(function(e) {$select.click();});
        $selected.dblclick(function(e) {$unselect.click();});

        $original.hide();

        $original.bind('options.updated', function () {
          var items = [];
          $selected.children().each(function() {items.push($(this).val());});
          $unselected.children().remove();
          $original.children().clone().appendTo($unselected);
          $selected.children().remove();
          $unselected.children().each(function() {
            if (items.indexOf($(this).val()) >= 0)
                $(this).appendTo($selected)
          });
          updateOriginal();
        });

        $container.insertAfter($original);
      });
    }
  });
})(jQuery);
