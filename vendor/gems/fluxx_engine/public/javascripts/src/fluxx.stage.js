(function($){
  $.fn.extend({
    fluxxStage: function() {
      if (document.readyState != "complete") {
        setTimeout( arguments.callee, 100 );
        return;
      } else {
        $('body').fluxxStageInit();
      }
    },
    fluxxStageInit: function(options, onComplete) {
      var options = $.fluxx.util.options_with_callback({}, options, onComplete);
      return this.each(function(){
        $.my.fluxx  = $(this).attr('id', 'fluxx');
        $.my.stage  = $.fluxx.stage.ui.call(this, options).appendTo($.my.fluxx.empty());
        $.my.hand   = $('#hand');
        $.my.header = $('#header');
        $.my.footer = $('#footer');
        $.my.stage.animating = false;
        $.my.stage.bind({
          'complete.fluxx.stage': _.callAll(
            _.bind($.fn.setupFluxxPolling, $.my.stage),
            _.bind($.fn.installFluxxDecorators, $.my.stage),
            _.bind($.fn.addFluxxCards, $.my.hand, {cards: $.fluxx.config.cards}),
            options.callback
          )
        });
        // Add browser specific class(es) so we can do special handling in scss
        if (jQuery.browser.mozilla)
          $('body').addClass('mozilla');
        if (navigator.userAgent.search(' Windows '))
          $('body').addClass('windows');
				var timerRunning = false;
        $(window).resize(function(e){
					if (!timerRunning) {
						timerRunning = true;
					  setTimeout(function(e) {
							timerRunning = false;
							$.my.cards.resizeFluxxCard();
						}, 600);
				  }
        }).resize();
        $.my.stage.trigger('complete.fluxx.stage');
      });
    },
    removeFluxxStage: function(onComplete) {
      var options = $.fluxx.util.options_with_callback({}, onComplete);
      return this.each(function(){
        if (!$.my.stage) return;
        $(this).remove();
        $.my.stage.trigger('unload.fluxx.stage');
        $.my.stage = undefined;
        $.my.hand  = undefined;
        $.my.cards = $('.card');
        options.callback.call(this);
      });
    },
    resizeFluxxStage: function(options, onComplete) {
      if ($.my.stage.animating || !this.length) return this;
      var options = $.fluxx.util.options_with_callback({animate: false}, options, onComplete);
      var allCards = _.addUp($.my.cards, 'outerWidth', true);
      var stageWidth = $.my.stage.width();
      $('#modal-container').css('height', '80%');
      $('#fluxx-admin .detail').height($('#modal-container').height() - 46);
      if (options.animate && allCards < stageWidth && stageWidth > $(window).width()) {
        $.my.stage.stop().animate({width: allCards + 40}, function(e) {
          $.my.stage
          .width(allCards + 40)
          .bind('resize.fluxx.stage', options.callback)
          .trigger('resize.fluxx.stage');
        });
      } else {
        $.my.stage
        .stop()
        .width(allCards + 40)
        .bind('resize.fluxx.stage', options.callback)
        .trigger('resize.fluxx.stage');
      }
      return this;
    },
    addFluxxCards: function(options, callback) {
      var options = $.fluxx.util.options_with_callback({}, options, callback);
      if (!options.cards.length) {
		$('#fluxx-loading-bar').fadeOut('slow', function() { $(this).remove();});
        options.callback();
        return this;
      }
      $.each(options.cards, function(i, v) {
        $.my.hand.addFluxxCard(this, function(){
          if (i == options.cards.length - 1) {
            options.callback();
          }
        }, true);
      });
      $('#fluxx-loading-bar').fadeOut('slow', function() { $(this).remove();});
      return this;
    },

    serializeFluxxCards: function () {
      return _.map($.my.cards, function(i){return $(i).serializeFluxxCard()});
    },

    installFluxxDecorators: function() {
      _.each($.fluxx.stage.decorators, function(val,key) {
        $(key).live.apply($(key), val);
      });
    },

    setupFluxxPolling: function () {
      if (! $.fluxx.config.realtime_updates.enabled) return;
      $.fluxx.realtime_updates = $.fluxxPoller($.fluxx.config.realtime_updates.options);
      $.fluxx.realtime_updates.start();
    },
    fluxxAjaxCall: function($elem, type) {
      var onSuccess = $elem.attr('data-on-success');
      if (onSuccess && onSuccess.replace(/\s/g, '').split(/,/).indexOf('refreshCaller') != -1) {
        $.ajax({
          url: $elem.attr('href'),
          type: type,
          complete: function (){
            if ($elem.parents('.partial').length && $elem.parents('.partial').attr('data-src'))
              $elem.refreshAreaPartial({});
            else
              $elem.refreshCardArea();
          }
        });
      } else {
        $elem.fluxxCardLoadContent({
          area: $elem.fluxxCardArea(),
          url: $elem.attr('href'),
          type: type
        });
      }
    },
		loadRelatedData: function($elem, pageIncrement) {
			$elem.fluxxCard().showLoadingIndicator();
			if (pageIncrement != 0)
				$elem.attr('data-src', $elem.attr('data-src').replace(/\&pagenum=(\d)+$/, function(a,b){
							var pagenum = parseInt(b) + pageIncrement;
				      return '&pagenum=' + pagenum;
				 }));			
			var $drawers = $('.section .lazy-load[data-src="' + $elem.attr('data-src') + '"]').next().html('');
			$.ajax({
        url: $elem.attr('data-src'),
				success: function(data, status, xhr){
					$drawers.html(data);
					$elem.fluxxCard().hideLoadingIndicator();
        }
      });							
		}
  });

  $.extend(true, {
    fluxx: {
      config: {
        header: {
          actions: []
        }
      },
      stage: {
        attrs: {
          id: 'stage'
        },
        ui: function(options) {
          return $('<div>')
            .attr($.fluxx.stage.attrs)
            .html($.fluxx.util.resultOf([
              $.fluxx.stage.ui.header(options),
              $.fluxx.stage.ui.cardTable,
              $.fluxx.stage.ui.footer
            ]));
        },
        decorators: {
          'a.with-note': [
            'click', function(e) {
              var $elem = $(this);
              if ($elem.data('has_note')) {
              } else {
                $.fluxx.util.itEndsHere(e);
                $.prompt({
                  title: 'Note for ' + $elem.text(),
                  onOK: function(alert) {
                    var query = {};
                    query[$elem.attr('data-note-param') || 'note'] = alert.text;
                    var note = $.param(query);
                    var href = $elem.attr('href');
                    if (href.match(/\?/)) {
                      href += '&' + note;
                    } else {
                      href += '?' + note;
                    }
                    $elem.attr('href', href);
                    $elem.data('has_note', true);
                    $elem.click();
                  }
                });
                return false;
              }
            }
          ],
          'a.new-detail': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var card = {
                detail: {url: $elem.attr('href')},
                title: ($elem.attr('title') || $elem.text())
              };
              if ($elem.hasClass('area-data'))
                card.detail.data = $.param($elem.fluxxCardAreaData());
              if ($elem.attr('data-insert') == 'after') {
                card.position = function($card) {$card.insertAfter($elem.fluxxCard())};
              } else if ($elem.attr('data-insert') == 'before') {
                card.position = function($card) {$card.insertBefore($elem.fluxxCard())};
              }
              $.my.hand.addFluxxCard(card);
            }
          ],
          'input.new-detail': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $form = $elem.parents('form:eq(0)');
              var card = {
                detail: {url: $form.attr('action'),
                         data: $form.serialize() + '&' + $elem.attr('name') + '=' + $elem.val()},
                title: $form.attr('data-title')
              };
              $.modal.close();
              $.my.hand.addFluxxCard(card);
            }
          ],
          'input.to-detail': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $form = $elem.parents('form:eq(0)');
              $card = $form.data('card');
              var req = $card.fluxxCardDetail().fluxxCardAreaRequest();
              req.data = $form.serialize() + '&' + $elem.attr('name') + '=' + $elem.val();
              $card.fluxxCardLoadDetail(req);
              $.modal.close();
            }
          ],
          'form.to-detail': [
            'submit', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $card = $elem.fluxxCard();
              var req = $card.fluxxCardDetail().fluxxCardAreaRequest();
              req.data = $elem.serialize();
              $card.fluxxCardLoadDetail(req);
            }
          ],
          'input.new-page': [
             'click', function(e) {
               $.fluxx.util.itEndsWithMe(e);
               var $elem = $(this);
               var $form = $elem.parents('form:eq(0)');
               window.open($form.attr('action') + '?' + $form.serialize() + '&' + $elem.attr('name') + '=' + $elem.val());
               $.modal.close();
             }
           ],
          'a.close-detail': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this).fadeOut('slow');
              $elem.closeDetail();
            }
          ],
          'a.new-listing': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var card = {
                listing: {url: $elem.attr('href')},
                title: $elem.attr('title') || $elem.text()
              };
              if ($elem.attr('data-filter'))
                card.listing.data = $.fluxx.unparamToArray($elem.attr('data-filter'));
              if ($elem.attr('data-insert') == 'after') {
                card.position = function($card) {$card.insertAfter($elem.fluxxCard())};
              } else if ($elem.attr('data-insert') == 'before') {
                card.position = function($card) {$card.insertBefore($elem.fluxxCard())};
              }
              $.my.hand.addFluxxCard(card);
            }
          ],
          'a.noop': [
            'click', $.fluxx.util.itEndsHere
          ],
          '.as-put': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              if ($elem.hasClass('with-note') && !$elem.data('has_note'))
                return;
              $.fn.fluxxAjaxCall($elem, 'PUT');
            }
          ],
          '.as-post': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $.fn.fluxxAjaxCall($elem, 'POST');
            }
          ],
          '.as-delete': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              if ($elem.hasClass('disabled'))
                alert('This record can not be deleted.');
              else if ($elem.hasClass('no-confirm'))
                $.fn.fluxxAjaxCall($elem, 'DELETE');
              else if (confirm('This record will be deleted. Are you sure?'))
                $.fn.fluxxAjaxCall($elem, 'DELETE');
            }
          ],
          'a.refresh-card': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              $(this).fluxxCardAreas().refreshCardArea();
            }
          ],
          'select.visualization-selector' : [
            'change', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              reportID = parseInt($(this).val())
              if ( reportID ) {
                var req = $(this).fluxxCardArea().fluxxCardAreaRequest();
                req.url = req.url.replace(/fluxxreport_id=[\-0-9]*$/, 'fluxxreport_id=' + reportID);
                var $card = $(this).fluxxCard();
                $card.fluxxCardLoadDetail(req, function() {
                  $card.saveDashboard();
                });
              }
            }
          ],
					'a.refresh-partial' : [
						'click', function(e) {
							$.fluxx.util.itEndsWithMe(e);
							($('#fluxx-admin').length ? $('#fluxx-admin .fluxx-admin-partial') : $(this)).refreshAreaPartial();
						}
					],
          'select.refresh-partial' : [
            'change', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $area = $elem.fluxxCardArea();
              var $partial = $($elem.attr('data-target'), $area);
              if (!$partial.length) {
                $partial = $($elem.attr('data-target'), '#fluxx-admin');
              }
              if ($partial.length) {
                var param = $elem.attr('name').replace(/\w+\[(\w+)\]/, "$1");
                if (param) {
                  var re = new RegExp('([?&]' + param + '=)([a-z0-9\-\_]+)(\&)?');
                  if ($partial.attr('data-src').match(re)) {
                    var req = $area.fluxxCardAreaRequest();
                    $partial.attr('data-src', $partial.attr('data-src').replace(re, "$1" + $elem.val() + "$3")).refreshAreaPartial();
                    req.url += (req.url.match(/\?/) ? '&' : '?') + param + '=' + $elem.val();
                    if (!$area.data('history')) {
                      $area.data('history', [req]);
                    } else {
                      $area.data('history').unshift(req);
                    }
                  } else {
                    param = $elem.attr('name').replace(/([\[\]])/, "\\$1");
                    re = new RegExp('([?&]' + param + '=)([a-z0-9\-\_]+)(\&)?');
                    $partial.attr('data-src', $partial.attr('data-src').replace(re, "$1" + $elem.val() + "$3")).refreshAreaPartial();
                  }
                } else {
                  var re = new RegExp('\/([A-Za-z0-9\-]+)\/edit');
                  $partial.attr('data-src', $partial.attr('data-src').replace(re, '/' + $elem.val() + '/edit')).refreshAreaPartial();
                }
              }
            }
          ],
          'input.refresh-partial' : [
            'keyup', function(e) {
              var $elem = $(this);
              var $partial = $($elem.attr('data-target'), $elem.fluxxCardArea());
              if ($partial.length) {
                $partial.refreshAreaPartial({data: $elem.parents('form').serialize()});
              }
            }
          ],
          'a.report-modal' : [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $.ajax({
                url: $elem.attr('href'),
                success: function(data, status, xhr) {
                  $.modal(data,{
                    position: ["15%",],
                    containerId: 'report-modal',
                    onOpen: function (dialog) {
                      $('.simplemodal-wrap', dialog.container).css('overflow', 'hidden');
                      dialog.overlay.fadeIn('fast', function () {
                        dialog.data.hide();
                        dialog.container.fadeIn('fast', function () {
                          dialog.data.fadeIn('fast');
                        });
                      });
                    }
                  });
                }
              });
            }
          ],
          'div.report-info' : [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $modal = $('#report-modal');
              $elem.parent().hide('slide', { direction: 'left' }, 'slow', function() {
                $.ajax({
                  url: $elem.attr('data-filter-url'),
                  success: function(data, status, xhr) {
                    $('.report-filter', $modal).html(data + '<div><a href="#" class="report-modal-back"><</a></div>').fadeIn('slow');
                    $('.multiple-select-transfer select[multiple=true], .multiple-select-transfer select[multiple=multiple]', $modal).selectTransfer();
                    $('.date input', $modal).datepicker({ changeMonth: true, changeYear: true, dateFormat: $.fluxx.config.date_format});
                  }
                });
              });

            }
          ],
          'a.report-modal-back' : [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $modal = $('#report-modal');
              $('.report-filter', $modal).hide('slide', { direction: 'right' }, 'slow', function() {
                $('.report-list', $modal).fadeIn('slow');
              });
            }
          ],
          'a.edit-report-filter': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              var $card = $elem.fluxxCard();
              var fromRequestCard = $('.visualizations', $card).attr('data-from-request-card') == 'true';
              if (fromRequestCard) {
                if ($('.filters', $(this).fluxxCard()).length) {
                  $(this).closeListingFilters(true);
                } else {
                  $(this).openListingFilters(true);
                }
              } else {
                $.ajax({
                  url: $card.fluxxCardDetail().fluxxCardAreaRequest().url + '?fluxxreport_filter=1',
                  success: function(data, status, xhr) {
                    $.modal('<div class="report-modal"><div class="report-filter">' + data + '</div></div>',{
                      position: ["15%",],
                      containerId: 'report-modal',
                      onOpen: function (dialog) {
                        var $form = $('form', dialog.data);
                        $('.multiple-select-transfer select[multiple=true], .multiple-select-transfer select[multiple=multiple]', $form).selectTransfer();
                        $('.new-detail', $form).removeClass('new-detail').addClass('to-detail').val('Update Report');
                        $form.data('card', $card);
                        _.each($.fluxx.unparam($card.fluxxCardDetail().fluxxCardAreaData()), function(value, name) {
                          var $felem = $('[name="' + name + '"]', $form);
                          if ($felem.length) {
                            var type = $felem.attr('type');
                            if (type == 'select-multiple') {
                              multiple = value;
                            }
                            if (type == 'select-multiple') {
                              $felem.parent().find('.unselected').val(value);
                              $felem.parent().find('.select').click();
                            } else if (type != 'hidden' && type != 'button')
                              $felem.val(value);
                          }
                        });
                        $('.date input', $form).datepicker({ changeMonth: true, changeYear: true, dateFormat: $.fluxx.config.date_format});
                        dialog.overlay.fadeIn('fast', function () {
                          dialog.data.hide();
                          dialog.container.fadeIn('fast', function () {
                            dialog.data.fadeIn('fast');
                          });
                        });
                      }
                    });
                  }
                });
              }
            }
          ],
          'a.clone-template': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this),
                template = _.template($elem.attr('data-template').replace(/'/g, '"'),{record_index: _.uniqueId()}),
                $target = $($elem.attr('data-append-to'), $elem.fluxxCardArea());
              $(template).appendTo($target).areaDetailTransform();
            }
          ],
          'a.delete-parent': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this),
                $parent = $elem.parents($elem.attr('data-parent')).first();
              if (!$parent.length) return;

              // Take the element that contains the hidden destroy element and prepend it to the parent and set the value to 1
              var deleteFlagElement = $($elem.attr('data-hidden-destroy'), $parent);
              if(deleteFlagElement != null) {
                var clonedDeleteFlagElement = deleteFlagElement.clone();
                $parent.parents().first().prepend(clonedDeleteFlagElement);
                clonedDeleteFlagElement.val(1);
              }

              // Take the element that contains the model ID and clone it and prepend it to the parent
              var hiddenIdElement = $($elem.attr('data-hidden-id'), $parent);
              if(hiddenIdElement != null) {
                var clonedhiddenIdElement = hiddenIdElement.clone();
                $parent.parents().first().prepend(clonedhiddenIdElement);
              }

              $parent.remove();
            }
          ],
          '.listing .actions': [
            'click', function (e) {
              var $head = $('.listing .header', $(this).fluxxCard());
              var $actions = $('.actions', $head);
              if ($head.hasClass('actions-open')) {

                $('.search', $head).fadeIn();
                $head.removeClass('actions-open');
                $actions.animate({left: $head.outerWidth(true)});
              } else {
                $('.search', $head).fadeOut();
                var iconWidth = $('li:not(.open-listing-actions):last', $actions).width();
                $actions.animate({left: $head.outerWidth(true) - (iconWidth * ($('li:not(.open-listing-actions)', $actions).length-1))
                  }, function() {
                    $head.addClass('actions-open').show()
                  }
                );

              }
            }
          ],
          'a.toggle-visible': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var targets = $(this).attr('data-selector');
              if (!targets) return;
              var $targets = $(targets, $(this).fluxxCardArea());
              _.each($targets, function(target) {
                var $target = $(target);
                $target[$target.is(':visible') ? 'hide' : 'show']();
              });
            }
          ],
          'a.open-filters': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              if ($('.filters', $(this).fluxxCard()).length) {
                $(this).closeListingFilters();
              } else {
                $(this).openListingFilters();
              }
            },
            function(e) {
              $.fluxx.util.itEndsWithMe(e);
            }
          ],
          '[data-related-child]': [
            'change', function (e) {
              var updateChild = function ($child, parentId, relatedChildParam) {
                // Prevent stacking updates
                $child.data('updating', true);
                var relatedChildParam = relatedChildParam ? relatedChildParam : $child.attr('data-param');
                var query = {};
                if ($child.attr('data-require-parent-id') && !parentId)
                  return;
                if ($child.attr('data-param-list')) {
                  _.each($child.attr('data-param-list').split(','), function(field) {
                    var names = field.split('=');
                    if (names.length != 2)
                      return;
                    query[names[0]] = $(names[1]).val();
                  });
                } else {
                  query[relatedChildParam] = parentId;
                }
                $.getJSON($child.attr('data-src'), query, function(data, status) {
                  var oldVal = $child.val();
                  if ($child.attr('data-required')) {
                    $child.empty();
                  } else {
                    $child.html('<option></option>');
                  }
                  _.each(data, function(i){ $('<option></option>').val(i.value).html(i.label).appendTo($child)  });
                  $child.val(oldVal).trigger('options.updated').change();
                });
              };

              var updateChildren = function($children, parentId, relatedChildParam) {
                $children.each(function(){
                  updateChild($(this), parentId, relatedChildParam);
                });
              }
              var $parent   = $(this),
                  $children = $($parent.attr('data-related-child'), $parent.parents('form').eq(0));
              if ($parent.attr('data-sibling')) {
                $('[data-sibling="'+ $parent.attr('data-sibling') +'"]', $parent.parent()).not($parent)
                  .one('change', function(){
                    updateChildren($children, $(this).val(), $parent.attr('data-related-child-param'));
                  });
              } else {
                updateChildren($children, $parent.val(), $parent.attr('data-related-child-param'));
              }
            }
          ],
          'a.to-dashboard': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $selected = $(this);
              if ($selected.parent().hasClass('selected'))
                return;
              var $previous = $('.selected a', $.my.dashboardPicker);
              $previous.data('locked', true);
              $selected.data('locked', true);
              $.my.lookingGlass.hide();
              $.my.cards.each(function() {
                var $card = $(this);
                $.my.dock.removeViewPortIcon({card: $(this)});
                $card.remove();
              });
              var dashboard = $selected.data('dashboard');
              if (dashboard && dashboard.data && dashboard.data.cards) {
                $('a.to-dashboard[href="#' + dashboard.url + '"]').parent().addClass('selected').siblings().removeClass('selected');
                $.my.hand
                  .addFluxxCards({cards: dashboard.data.cards}, function(){
                    $selected.data('locked', false);
                    $previous.data('locked', false);
                  });
                $.cookie('dashboard', '#' + dashboard.url);
              	$.my.stage.resizeFluxxStage();
              } else {
                $selected.data('locked', false);
                $previous.data('locked', false);
              }
            }
          ],
          'a.new-dashboard': [
             'click', function(e) {
               $.fluxx.util.itEndsWithMe(e);
               $.my.dashboardPicker.newDashboard(e);
             }
           ],
           'a.manage-dashboard': [
             'click', function(e) {
               $.fluxx.util.itEndsWithMe(e);
               $.my.dashboardPicker.openManager();
             }
           ],
           'a.delete-dashboard': [
              'click', function(e) {
                $.fluxx.util.itEndsWithMe(e);
                var dashboard = $(this).parent().parent().parent().find('a.to-dashboard').data('dashboard');
                $('#manager-container').fadeTo(500,0.2);
                jConfirm('<p>You are about to delete the dashboard</p><span class="manager-title">' + dashboard.name + '</span>',
                  'Can you confirm this?', function(r) {
                    $('#manager-container').fadeTo(500, 1);
                    if (r)
                      $.my.dashboardPicker.deleteDashboard(dashboard);
                });
              }
            ],
            'a.rename-dashboard': [
               'click', function(e) {
                 $.fluxx.util.itEndsWithMe(e);
                 var dashboard = $(this).parent().parent().parent().find('a.to-dashboard').data('dashboard');
                 $('#manager-container').fadeTo(500,0.2);
                 jPrompt('Rename dashboard ' + dashboard.name + ' to:',
                   dashboard.name, '', function(r) {
                   $('#manager-container').fadeTo(500, 1);
                   if (r)
                     $.my.dashboardPicker.renameDashboard(dashboard, r);
                 });
               }
             ],
          'a.to-upload': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $.modal('<div class="upload-queue"></div>', {
                minWidth: 700,
                minHeight: 400,
                closeHTML: '<span>Close</span>',
                close: true,
                closeOverlay: true,
                escClose:true,
                opacity: 50,
                onShow: function () {
                  $('.upload-queue').pluploadQueue({
                    url: $elem.attr('href'),
                    runtimes: 'html5',
                    multipart: false,
                    documentTypeParam: $elem.data('document-type-param'),
                    documentTypeUrl: $elem.data('document-type-url'),
                    filters: [{title: "Allowed file types", extensions: $elem.attr('data-extensions')}]
                  });
                },
                onClose: function(){
                  if ($elem.parents('.partial').length) {
                    $elem.refreshAreaPartial();
                  } else {
                    $elem.refreshCardArea();
                  }
                  $.modal.close();
                }
              });
            }
          ],
          'a.to-modal': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              if (!$elem.hasClass('disabled'))
                $elem.openCardModal({
                  url:    $elem.attr('href'),
                  header: $elem.attr('title') || $elem.text(),
                  target: $elem,
                  hideFooter: $elem.hasClass('hide-footer'),
                  event: e
                });
            }
          ],
          'a.to-div': [
             'click', function(e) {
               $.fluxx.util.itEndsWithMe(e);
               var $elem = $(this);
               $('.loading-indicator', $elem.fluxxCard()).addClass('loading');
               $.get($elem.attr('href'), function(data, status) {
                 $('.loading-indicator', $elem.fluxxCard()).removeClass('loading');
                 $elem.parent().children('.closeable-div').remove();
                 var $div = $('<div class="closeable-div"><a class="close-parent" href="#"><img src="/images/fluxx_engine/theme/default/icons/cancel.png" /></a></div>')
                   .append($('<div class="partial" data-src="' + $elem.attr('href') + '" />').append(data));
                 $elem.after($div.fadeIn('slow'));

               });
             }
           ],
          'a.close-modal': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              $(this).closeCardModal();
            }
          ],
          'a.close-parent': [
            'click', function(e){
              $.fluxx.util.itEndsWithMe(e);
              $(this).parent('div:first').fadeOut(250,function(){
                var $card = $(this).fluxxCard();
                var $area = $(this).fluxxCardArea();
                $('.header,.body,.footer', $area).filter(':empty').addClass('empty');
                $card.resizeFluxxCard();
              });
            }
          ],
          'a.to-self':   [
            'click', function (e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $elem.fluxxCardLoadContent({
                url: $elem.attr('href'),
                area: $elem.fluxxCardArea(),
                target: $elem
              });
            }
          ],
          'a.to-listing': [
            'click', function (e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $elem.fluxxCardLoadListing({
                url: $elem.attr('href')
              });
            }
          ],
          'a.tab-open': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this).addClass('disabled');
              var $area = $(this).fluxxCardArea();
              $($elem.attr('data-target'), $area).show();
              $area.find('.tab').not($($elem.attr('data-target'), $area)).hide();
              $area.find('.tab-open').not($elem).removeClass('disabled');
              if ($elem.hasClass('hide-footer'))
                $area.find('.footer').hide();
              else if ($elem.hasClass('show-footer'))
                $area.find('.footer').show();
            }
          ],
          'form.to-listing': [
            'submit', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $elem.fluxxCardLoadListing({
                url: $elem.attr('action'),
                type: $elem.attr('method'),
                data: $elem.serializeArray()
              });
            }
          ],
          'form.filters-form': [
            'submit', function(e) {
              var $elem = $(this);
              $elem.closeListingFilters();
            }
          ],
					'.next-page': [
						'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
							var $elem = $(this);
							if (!$elem.hasClass('disabled')) {
								var $link = $elem.parents().find('.lazy-load');
								$.fn.loadRelatedData($link, 1);
						  }
						}
					],
					'.prev-page': [
						'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
							var $elem = $(this);
							if (!$elem.hasClass('disabled')) {					
								var $link = $elem.parents().find('.lazy-load');
								$.fn.loadRelatedData($link, -1);
							}
						}
					],					
          '.tabs-right': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);						
              var $elem = $(this);
							if ($elem.hasClass('disabled'))
								return;
							var $card = $elem.fluxxCard();
              var $tabs = $('.tabs', $card);
							$('.tabs-left', $card).removeClass('disabled');
              $tabs.scrollTop( $tabs.scrollTop() + 44 );
							if ($tabs.attr("scrollHeight") - $tabs.scrollTop() - 5 == $tabs.outerHeight())
								$elem.addClass('disabled');
            }
          ],
          '.tabs-left': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
							if ($elem.hasClass('disabled'))
								return;
							var $card = $elem.fluxxCard();
	 					  var $tabs = $('.tabs', $card);
							$('.tabs-right', $card).removeClass('disabled');
              $tabs.scrollTop( $tabs.scrollTop() - 44 );
							if ($tabs.scrollTop() == 0)
								$elem.addClass('disabled');

            }
          ],
          '.tabs .label': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this), label = $elem.text(), $card = $elem.fluxxCard();
              $.my.stage.animating = true;
              var $info = $('.info', $card);
              if ($elem.hasClass('selected')) {
                $elem.removeClass('selected');
                $info.css({bottom: '15px'});
                // Workaround to prevent the bottom dropshadow from disappearing when the drawer is animating
                $card.height($card.height() + 20);
                $card.animate({width: '-=226'}, function() {
                  $info.css({bottom: '-5px'});
                  $card.height($card.height() - 20);
                  $.my.stage.animating = false;
                  $info.removeClass('open').resizeFluxxCard();
                });
              } else {
								// Some related data areas only load when the drawer is opened
								if ($elem.hasClass('lazy-load')) {
									var $entries = $elem.next().html('');
								$.fn.loadRelatedData($elem, 0);								}
                $elem.addClass('selected').parent().siblings().children().removeClass('selected');
                $('.drawer .entries', $card).removeClass('selected');
                $('.drawer .label:contains('+label+')', $card).siblings().addClass('selected');
                if (!$info.hasClass('open'))
                  $info.addClass('open', 1, function(){
                    $info.css({bottom: '15px'});
                    $card.height($card.height() + 20);
                    // TODO: probably shouldn't hardcode this number
                    $.my.stage.width($.my.stage.width()+226);
                    $card.animate({width: '+=226'}, function() {
                      $info.css({bottom: '-5px'});
                      $card.height($card.height() - 20);
                      $.my.stage.animating = false;
                      $card.resizeFluxxCard();
                      if (!$card.cardVisibleRight())
                        $card.focusFluxxCard({scrollEdge: 'right'});
                    });
                  ;});
              }
            }
          ],
          'li.entry a': [
            'click', function(e) {
              var $elem = $(this);
              var $entry = $elem.parent();
              $entry.removeClass('latest').addClass('selected').siblings().removeClass('selected');
            }
          ],
          'a.close-card': [
            'click', function(e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              if ($elem.hasClass('no-confirm'))
                $(this).removeFluxxCard();
              else if (confirm('Are you sure you want to close this card?'))
                $(this).removeFluxxCard();
            }
          ],
          'a.minimize-card, a.maximize-card': ['click', function (e) {
            $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $elem.minimizeFluxxCard();
            }
          ],
          'a.to-detail': ['click', function (e) {
            $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              $elem.fluxxCardLoadDetail({
                url: $elem.attr('href')
              });
            }
          ],
          'a.area-url': [
            'click', function(e) {
              var $elem = $(this);
              var current = $elem.fluxxCardAreaRequest();
              var url = $elem.fluxxCardAreaURL();
              var params = url.match(/\?(.*)$/);

              if (params && params.length > 0)
                params = params[1];

              $elem.attr('href', url.replace(/\?.*$/, '') + ($elem.hasClass('pdf') ? '.pdf' : '') + "?printable=1" + (params ? '&' + params : ''));
            }
          ],
          'a.area-data': [
            'click', function(e) {
              var $elem = $(this);
              $elem.attr('href', $elem.attr('href') + '?' + $.param($elem.fluxxCardAreaData()))
            }
          ],
          'a.dock-list-scroller': [
             'click', function(e) {
               $.my.dock.fluxxDockUpdateViewing(e);
             }
          ],
          'form.area-url': [
            'submit', function(e) {
              var $elem = $(this);
              $elem.attr('action', $elem.fluxxCardAreaURL({without: $elem.serializeArray()}));
            }
          ],
          'form.to-self': [
            'submit', function (e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
							// Don't send blank password type input fields, that would force a password change
							// every time a user was edited.
							$('input:password', $elem).each(function() {
								var $pwe = $(this);
								if (!$pwe.val())
									$pwe.attr("disabled", "disabled");
							});
              var properties = {
                area: $elem.fluxxCardArea(),
                url: $elem.attr('action'),
                data: $elem.serializeArray()
              };
							$('input:password', $elem).removeAttr("disabled");
              if ($elem.attr('method'))
                properties.type = $elem.attr('method');
              $elem.fluxxCardLoadContent(properties)							
            },
          ],
          'form.listing-search': [
             'submit', function (e) {
               $.fluxx.util.itEndsWithMe(e);
               var $elem = $(this);
               var $card = $elem.fluxxCard();
               var data = $card.fluxxCardListing().fluxxCardAreaRequest().data;
               if ($.isArray(data))
                 data = _.select(data, function(obj){ if ( obj && obj.name && obj.name != 'utf8' && obj.name != 'q[q]') return obj; });
               data = ($.isArray(data) ? data.concat($elem.serializeArray()) : $elem.serializeArray());
               var properties = {
                 area: $elem.fluxxCardArea(),
                 url: $.fluxx.cleanupURL($elem.attr('action')),
                 data: data
               };
               if ($elem.attr('method'))
                 properties.type = $elem.attr('method');								
               $elem.fluxxCardLoadContent(properties)
             },
           ],
          'input[data-autocomplete]': [
            'focus', function (e) {
              $.fluxx.util.itEndsWithMe(e);
              var $elem = $(this);
              if ($elem.data('autocomplete_initialized')) return;
              $elem.data('autocomplete_initialized', 1);

              var endPoint = $elem.attr('data-autocomplete');

              $elem.autocomplete({
                source: function (query, response) {
                  $.getJSON(
                    endPoint,
                    query,
                    function(data, status){
                      response(data);
                    }
                  );
                },
                focus: function (e, ui) {
                  $elem.val(ui.item.label);
                  return false;
                },
                select: function (e, ui) {
                  $elem.val(ui.item.label);
                  $elem.change()
                    .parent()
                    .find('input[data-sibling='+ $elem.attr('data-sibling') +']')
                    .not($elem)
                    .val(ui.item.value)
                    .change();

                  return false;
                }
              }).change(function(e) {
                if ($elem.val() == '') {
                  $elem
                    .parent()
                    .find('input[data-sibling='+ $elem.attr('data-sibling') +']')
                    .not($elem)
                    .val('').change();
                  $elem.
                    parent().parent()
                    .find($elem.attr('data-related-child'))
                    .val('').change();
                }
              });
            }
          ],
          'input[data-duplicate-lookup]': [
             'focusout', function (e) {
               $.fluxx.util.itEndsWithMe(e);
               var $elem = $(this);
               var endPoint = $elem.attr('data-duplicate-lookup');
               // The data-related parameter allow you to concat two field for duplicate lookup.
               // This is useful in the case of first and last name.
               var related = $elem.attr('data-related');
               var val = jQuery.trim($elem.val());
               if (related) {
                 var rVal = $(related).val().trim();
                 // This is kind of lame, determining the order by looking for the string
                 // "first" in the ID of the input element
                 if ($elem.attr('id').match(/first/))
                   val = val + ' ' + rVal;
                 else
                   val = rVal+ ' ' + val;
               }
               query = {term: val}
               $.getJSON(endPoint, query, function(data, status) {
                 var match = false;
                 _.each(data, function(i){
                   if (jQuery.trim(i.label.toLowerCase()) == val.toLowerCase())
                     match = true;
                 });
                 if (match) {
                   var clearError = function(e) {
                     $elem.unbind('focus').parent().removeClass('error').children('.inline-errors').remove();
                     if (related)
                       $(related).unbind('focus').parent().removeClass('error').children('.inline-errors').remove();
                   };

                   clearError();
                   $elem.parent().addClass('error');
                   $('<p class="inline-errors">The name ' + val + ' has already been taken, please choose another.</p>').appendTo($elem.parent());

                   $elem.focus(clearError);
                   if (related) {
                     $(related).parent().addClass('error');
                     $(related).focus(clearError);
                   }
                 }
               });
             },
           ],
          'a.scroll-to-card': [
            'click', function(e) {
              $.fluxx.util.itEndsHere(e);
              var target = $(this).attr("href");
              var $card = $(target);
              $card.focusFluxxCard({}, function() {
//                $('.toolbar, .titlebar, .card-footer', $card).effect('highlight', {}, 500);
                location.hash = target;
              });
            }
          ],
          '.show-child-if-selected"': [
            'change', function(e) {
              var $elem = $(this);
              var $parent = $elem.parents().first('div').parent();
              $('.sub_program_filter:gt(0)', $parent).remove();
              $('.initiative_filter:gt(0)', $parent).remove();
              $('.sub_initiative_filter:gt(0)', $parent).remove();
              $('.do-add-another:gt(0)', $parent).show();
              if ($elem.val())
                $elem.parent().parent().children('div').show();
              else
                $elem.parent().parent().children('div').hide().find('select').val('');
            }
          ],
          'a.do-add-another': [
            'click', function(e) {
              $.fluxx.util.itEndsHere(e);
              var $link = $(e.target);
              var $elem = $link.prev();

              if ($elem.parents('.hierarchical-filter').length > 0) {
                var unique = _.uniqueNumber();
                var $parent = $elem.parents().first('div').parent();
                var $add = $parent.clone();
                $('.sub_program_filter:gt(0)', $add).remove();
                $('.initiative_filter:gt(0)', $add).remove();
                $('.sub_initiative_filter:gt(0)', $add).remove();
                $('.do-add-another', $add).show();
                // Turns off the label
//                $add.find('label').first().html('');
                $link.hide();
                $add.children('div').hide();
                $('[data-related-child]', $add).each(function() {
                  var $e = $(this);
                  var children = [];
                  _.each($e.attr('data-related-child').split(/,/), function(child) {
                    var newChild = child + '_' + unique;
                    children.push(newChild);
                    $(child, $add).removeClass(child.replace('.', '')).addClass(newChild.replace('.', ''));
                  });
                  $e.attr('data-related-child', children.join(','));
                });
                $parent.after($add);
              } else {
                var $add  = $elem.clone();
                $elem.after($add);
                $add.before($('<label/>'));
              }
              return false;
            }
          ],
          'img.clear-selected-org': [
            'click', function(e) {
              $.fluxx.util.itEndsHere(e);
              var $link = $(e.target),
                $elem = $link.parent().prev(),
                $area = $(this).fluxxCardArea();

              var $autosel = $('[data-related-child=".' + $elem.attr('class') + '"]');
               $elem.val('');
              $elem.val('').html('<option value=""></option>').val('');
              $autosel.val('').next().val('').change();
              var children = $elem.data('related-child').split(',');
              $.each(children, function() {
                $('select' + this, $area).val('').children('option').remove();
              });
            }
		      ],
          'select.date-presets': [
            'change', function(e) {
              $.fluxx.util.itEndsHere(e);
              var $elem = $(this);
              var $area = $elem.fluxxCardArea();
              var $start_field = $($elem.attr('data-start-date-field'));
              var $end_field = $($elem.attr('data-end-date-field'));
              if ($elem.val() == 'this_week') {
                var d = new Date();
                $start_field.datepicker('setDate', '-' + d.getDay());
                $end_field.datepicker('setDate', '+' + (6 - d.getDay()));
              } else if ($elem.val() == 'last_week') {
                  var d = new Date();
                  $start_field.datepicker('setDate', '-' + (7 + d.getDay()));
                  $end_field.datepicker('setDate', '-' + (7 - (6 - d.getDay())));
              }
            }
          ],
          '#help-logo': [
            'click', function(e) {
               window.open('https://sites.google.com/a/fluxxlabs.com/fluxxlabs/','_blank');
             }
          ],
          '#logo': [
            'click', function(e) {
               location.reload(true);
             }
          ],
          'div.toolbar': [
            'mousedown', function(e) {
              var $window = $('html,body');
              $('#fluxx').css('-webkit-user-select', 'none').css('-moz-user-select', 'none');
              $window.data('lastPageX', e.pageX);
              $window.data('scrolling', true);
              $window.mousemove(function(e) {
                var $window = $('html,body');
                if ($window.data('skipScroll')) {
                  $window.data('skipScroll', false);
                  return;
                }
                $window.data('skipScroll', true);
                var lastPageX = $window.data('lastPageX');
                var offset = lastPageX - e.pageX;
                var scrollLeft = $(window).scrollLeft() + offset;
                $window.data('lastOffset', offset);
                $window.data('lastPageX', e.pageX + offset);
                $window.scrollLeft(scrollLeft);
              });
            }
          ],
          'html,body': [
            'mouseup', function(e) {
              var $window = $('html,body');
              if (!$window.data('scrolling'))
                return;
              $window.data('scrolling', false);
              $window.unbind('mousemove');
              $('#fluxx').css('-webkit-user-select', 'auto').css('-moz-user-select', 'auto');
            }
          ]
        }
      }
    }
  });
  $.fluxx.stage.ui.header = function(options){return $.fluxx.util.resultOf([
    '<div id="header">',
      '<div id="logo"><a href=".">FLUXX</a></div>',
        '<ul class="actions">',
          _.map($.fluxx.config.header.actions, function(action) {
            return ['<li>', action, '</li>'];
          }),
        '</ul>',
        '<img src="/images/fluxx_engine/theme/_common/loaders/loading-bar.gif" id="fluxx-loading-bar">',
    '</div>'
  ])};
  $.fluxx.stage.ui.cardTable = [
    '<div id="card-table">',
      '<ul id="hand">',
      '</ul>',
    '</div>'
  ].join('');
  $.fluxx.stage.ui.footer = [
    '<div id="footer"></div>'
  ].join('');

  $(window).resize(function(e){
    if (!$.my.stage) return;
    $.my.stage.resizeFluxxStage();
  });

})(jQuery);
