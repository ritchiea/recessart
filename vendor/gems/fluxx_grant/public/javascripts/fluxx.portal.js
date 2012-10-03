(function($){
  $.fn.extend({
    initGranteePortal: function() {
      $.fn.installFluxxDecorators();
      $('.notice').delay(5000).fadeOut('slow');
    },
		installFluxxDecorators: function() {
		  $.each($.fluxx.decorators, function(key,val) {
		    $(key).live.apply($(key), val);
		  });
		},
		loadTable: function($table, pageIncrement) {
      $table.css('opacity', '0.2');
			$table.attr('data-src', $table.attr('data-src').replace(/page=(\d+)/, function(a,b){
			  var page = parseInt(b) + pageIncrement;
			  return 'page=' + page;
			}));
			$.ajax({
        url: $table.attr('data-src'),
		    success: function(data, status, xhr){
				  $table.html(data);
          $table.css('opacity', '1');
        }
      });
		}
	});

  $.fn.extend({
    fluxxCard: function() {
      return $(document);
    },
    openCardModal: function(options) {
      $.ajax({
        url: options.url,
        type: 'GET',
        success: function(data, status, xhr){
          $('.page').fadeTo('slow','.2');
          $('<div id="modal-content">' + data + '</div>').dialog({
            modal: true,
            minWidth: 500,
            minHeight: 500,
            close: function(event, ui) {
              $('.page').fadeTo('slow','1');
            }
          });
        }
      });
      $(document).data('modal-target', options.target);
    }
  });

	$.extend(true, {
		fluxx: {
		  decorators: {
	      'a.prev-page': [
	        'click', function(e) {          
                e.preventDefault();
                var $elem = $(this);
                if ($elem.hasClass('disabled'))
                    return;
                var $area = $elem.parents('.container');
                    $.fn.loadTable($area, -1);
	        }
	      ],
	      'a.next-page': [
	        'click', function(e) {          
                e.preventDefault();
                var $elem = $(this);
                if ($elem.hasClass('disabled'))
                    return;
                var $area = $elem.parents('.container');
                $.fn.loadTable($area, 1);
	        }
	      ],
          'a.to-upload': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              $('.page').fadeTo('slow','.2');
              $('<div class="upload-queue"></div>').dialog({
                minWidth: 700,
                minHeight: 400,
                open: function () {
                  $('.upload-queue').pluploadQueue({
                    url: $elem.attr('href'),
                    runtimes: 'html5, flash',
                    flash_swf_url: '/javascripts/fluxx_engine/lib/plupload.flash.swf',
                    multipart: false,
                    filters: [{title: "Allowed file types", extensions: $elem.attr('data-extensions')}]
                  });
                },
                close: function(){
                  $('.page').fadeTo('slow','1');
                  var $area = $elem.parents('.reports');
                  if (!$area.attr('data-src'))
                    $area = $elem.parents('.partial');
                  $.fn.loadTable($area, 0);
                }
              });
            }
          ],
          'a.submit-workflow': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              var $area = $elem.parents('.reports');
              if ($area.length == 0)
                $area = $elem.parents('.container');
              if ($elem.attr('data-confirm') && !confirm($elem.attr('data-confirm')))
                return false;
              $.ajax({
                url: $elem.attr('href'),
                type: 'PUT',
                data: {},
		            success: function(data, status, xhr){
                  if ($elem.attr('data-success-message'))
                    alert($elem.attr('data-success-message'));
				          $.fn.loadTable($area, 0);
                }
              });
            }
          ],
          'a.delete-report': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              var $area = $elem.parents('.reports');
              if ($area.length == 0)
                $area = $elem.parents('.container');
              if (confirm('The report you recently submitted will be deleted. Are you sure?'))
              $.ajax({
                url: $elem.attr('href'),
                type: 'DELETE',
                data: {},
		            success: function(data, status, xhr){
				          $.fn.loadTable($area, 0);
                }
              });
            }
          ],
          'a.as-delete': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              $area = $elem.parents('[data-src]');
              if (confirm('This request will be deleted. Are you sure?'))
                $.ajax({
                  url: $elem.attr('href'),
                  type: 'DELETE',
		              success: function(data, status, xhr){
    		    		    $.fn.loadTable($area, 0);
                  }
                });
            }
          ],
          'input.open-link' : [
             'click', function(e) {
               e.preventDefault();
               var $elem = $(this);
               window.location = $elem.attr('data-href');
            }
          ],
          'a.to-modal': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              $elem.openCardModal({
                url:    $elem.attr('href'),
                header: $elem.attr('title') || $elem.text(),
                target: $elem
              });
            }
          ],
          '#modal-content form' : [
            'submit', function(e) {
              e.preventDefault();
              $form = $(this);
              $.ajax({
                url: $form.attr('action'),
                type: 'POST',
                data: $form.serialize(),
                success: function(data, status, xhr){
                  if (xhr.getResponseHeader('fluxx_result_success')) {
                    $.fn.loadTable($(document).data('modal-target').parents('[data-src]'), 0);
                    $('.ui-icon-closethick').click();
                  } else {
                    $('#modal-content').html(data);
                  }
                }
              });
            }
          ]
		    }
	    }
	});
})(jQuery);

$(document).ready(function() {
	$.fn.initGranteePortal();
});
