jQuery(function($){
  $.extend($.fluxx.stage.decorators, {
    '.to-fullscreen-modal': [
      'click', function(e) {
        $.fluxx.util.itEndsWithMe(e);
        var $elem = $(this);
        $.ajax({
          url: $elem.attr('href'),
          success: function(data) {
            $.modal(data, {
              position: ["15%",],
              overlayId: 'modal-overlay',
              containerId: 'modal-container',
              dataId: $elem.attr('data-container-id') ? $elem.attr('data-container-id') : 'simplemodal-data',
              onOpen: function(dialog) {
                $.my.stage.resizeFluxxStage();
                $('#fluxx-admin li.entry:first').click();
                dialog.overlay.fadeIn(200, function () {
                  dialog.container.fadeIn(200, function () {
                    dialog.data.fadeIn(200)
                  });
                });
              },
              onClose: function(dialog) {
                dialog.data.fadeOut(200, function () {
                  dialog.container.fadeOut(200, function () {
                    dialog.overlay.fadeOut(200, function () {
                      $.modal.close();
                    });
                  });
                });
              }
            });
          }
        });
      }
    ],
    '.to-admin': [
      'click', function(e) {
        $.fluxx.util.itEndsWithMe(e);
        var $elem = $(this);
        if ($elem.attr('href') != "") {
          $('#admin-buttons').fadeOut();
          $('#fluxx-admin li.entry').removeClass('selected');
          $elem.addClass('selected');
          var $detail = $('#fluxx-admin .fluxx-admin-partial');
          $detail.fluxxCard().closeCardModal();
          var properties = {
            area: $detail,
            url: $elem.attr('href')
          };
           $detail
            .addClass('updating')
            .children()
            .fadeTo(300, 0);
          $elem.fluxxCardLoadContent(properties, function() {
            $detail.removeClass('updating').children().fadeTo(300, 1);
          });
        }
      }
    ]
  });
});
