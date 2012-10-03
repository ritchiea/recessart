(function($){
  $.fn.extend({
    addFluxxDock: function(options, onComplete) {
      var options = $.fluxx.util.options_with_callback($.fluxx.dock.defaults,options,onComplete);
      return this.each(function(){
        $.my.dock = $.fluxx.dock.ui.call($.my.footer, options)
          .appendTo($.my.footer);
        $.my.viewport = $('#viewport');
        $.my.iconlist = $('#iconlist').sortable({
          scroll: false,
          start: function(event, ui) {
            if ((ui.helper !== undefined )) {
              var offset = $(window).scrollLeft();
              ui.helper.css('position','absolute').css('margin-left', offset);
            }
          },
          beforeStop: function (event, ui) {
            if ((ui.offset !== undefined )) {
              ui.helper.css('margin-left', 0);
            }
          },
          update: function (event, ui) {
            var itemID = $('a', ui.item).attr('href').replace(/^#/,'');
            var nextID = $('a', ui.item.next()).attr('href');
            var $card = $('#' + itemID);
            if (typeof nextID != 'undefind' && nextID) {
              var $nextCard = $('#' + nextID.replace(/^#/,''));
              $card.detach().insertBefore($nextCard);
            } else {
              $card.detach().insertAfter($.my.cards.last());
            }
            $.my.cards = $('.card');
            $.my.stage.resizeFluxxStage();
            $card.saveDashboard();
          }
        });

        $.my.quicklinks = $('#quicklinks');
        $.my.lookingGlass = $('#lookingglass');
        $.my.dock
          .bind({
            'complete.fluxx.dock': _.callAll(options.callback, $.fluxx.util.itEndsWithMe)
          })
          .trigger('complete.fluxx.dock');
        $.my.stage.bind('resize.fluxx.stage', $.my.dock.fluxxDockUpdateViewing);
        $(window).scroll($.my.dock.fluxxDockUpdateViewing);

        $('.icon', '.dock').live('mouseover mouseout', function(e) {
          var $icon  = $(e.currentTarget);
          var $popup = $('.popup', $icon);
          if (e.type == 'mouseover') {
            $('.popup', '.dock').not($popup).hide();
            $icon.data('hiding-popup', false);
            $popup.show();
          } else {
            $icon.data('hiding-popup', true);
            setTimeout(function () {
              if ($icon.data('hiding-popup')) {
                $icon.data('hiding-popup', false);
                $popup.fadeOut();
              }
            }, 2000);

          }
        });
      });
    },

    addViewPortIcon: function(options) {
      var options = $.fluxx.util.options_with_callback({}, options);
      return this.each(function(){
        if (options.card.data('icon')) return;
        var $icon = $.fluxx.dock.ui.icon.call($.my.dock, {
          label: options.card.fluxxCardTitle(),
          url: '#'+options.card.attr('id'),
          popup: options.card.fluxxCardTitle(),
          type: options.card.fluxxCardIconStyle()
        }).updateIconBadge();
        if (options.card.prev().length) {
            $icon.insertAfter($('a[href="#'+options.card.prev().attr('id')+'"]', $.my.iconlist).parents('.icon').first());
        } else {
          $icon.prependTo($.my.iconlist);
        }
        options.card.data('icon', $icon);
        $icon.data('card', options.card);
      });
    },
    updateIconBadge: function (options) {
      var options = $.fluxx.util.options_with_callback({badge: ''}, options);
      return this.each(function(){
        var $icon  = $(this),
            $badge = $('.badge', $icon);
        $badge.text(options.badge);
        $badge.is(':empty') || $badge.text() == 0 ? $badge.hide() : $badge.show();
      });
    },
    setDockIconProperties: function (options) {
      var options = $.fluxx.util.options_with_callback({style: '', popup: ''}, options);
      return this.each(function(){
        var $icon  = $(this);
        $icon.addClass(options.style);
        $icon.remove('.popup');
        $('.popup', $icon).html($.fluxx.dock.ui.popup(options));
      });
    },
    removeViewPortIcon: function(options) {
      var options = $.fluxx.util.options_with_callback({}, options);
      return this.each(function(){
        if (!options.card.data('icon')) return;
        options.card.data('icon').remove();
        options.card.data('icon', null);
      });
    },
    fluxxDockIconMargin: function() {
      var $icon = $(this);
      if (!$.my.iconlist.hasOwnProperty('margin')) {
        $.my.iconlist.margin = $.fluxx.util.marginHeight($icon);
      }
      return Math.floor($.my.iconlist.margin / 2);
    },
    fluxxDockSizeIconlist: function(e) {
//      return;
      var $icons = $('li.icon', $.my.iconlist);
      var $ql = ('.qllist', $.my.quicklinks);
      var $scrollers = $('.dock-list-scroller', $.my.viewport);;
      var numIcons = $icons.length;
      var ilWidth =  $ql.offset().left - $.my.iconlist.offset().left - $scrollers.last().outerWidth(true) - 10;
      var iconWidth = $icons.first().outerWidth(true);
      var lastIcon = Math.floor(ilWidth / iconWidth)
      if (lastIcon < numIcons)  {
        $scrollers.css('opacity', 1);
        var firstIcon = $.my.iconlist.data('firstIcon') || 1;
        var numRight = numIcons - lastIcon - firstIcon + 1;
        if (numRight < 0) {
          firstIcon += numRight;
          numRight = 0;
        }

        var goLeft = $(e.currentTarget).hasClass('left');
        var goRight = $(e.currentTarget).hasClass('right')
        if (goLeft && firstIcon > 1)
          firstIcon -= 1;
        if (goRight && numRight > 0)
          firstIcon += 1;
        var numRight = numIcons - lastIcon - firstIcon + 1;
        $.my.iconlist.data('firstIcon', firstIcon);
        $('span.n-cards', $scrollers.first()).html(firstIcon - 1);
        $('span.n-cards', $scrollers.last()).html(numRight);
        $('.dock-list-scroller').show();
        $icons.each(function(i) {
          var $icon = $(this);
          if (i >= firstIcon - 1 && i + 1 < (lastIcon + firstIcon))
            $icon.show();
          else
            $icon.hide();
        });
      } else {
        $scrollers.css('opacity', 0);
        $icons.show();
      }
      $.my.iconlist.width(ilWidth);
    },
    fluxxDockUpdateViewing: function(e){
      if ($.my.stage.animating)
        return;
      $.my.dock.fluxxDockSizeIconlist(e);
      var $cards = $.my.cards;
      var $glass = $.my.lookingGlass;
      if ($cards.length == 0) {
        $glass.hide();
        return;
      }

      var $viewport = $.my.viewport;
      var left = 0;
      var right = 0;
      var scroll = $(window).scrollLeft();
      var viewportFound = false;
      var lastID = $('a', $.my.iconlist).last().attr('href');
      var showViewport = true;
      var leftFound = false;

      $cards.each(function(){
        var $card = $(this);
        var cardWidth = $card.width();
        var cardMargin = $card.fluxxCardMargin();
        var cardLeft = $card.offset().left;
        var cardArea = cardLeft + cardWidth + cardMargin;
        var $icon = $('a[href="#'+$card.attr('id')+'"]', $.my.iconlist);
        if ($icon.length == 0)
          return false;
        var iconMargin = $icon.fluxxDockIconMargin();
        var iconLeft = $icon.offset().left;
        var pixelsIn = 0;
        var percentOver = 0;
        var rightEdge = scroll + $(window).width();
        var iconHidden = ($icon.not(':visible').length == 1);
        if (!viewportFound && !iconHidden)
          viewportFound = true;

        if (!leftFound && scroll < cardArea) {
          if (iconHidden) {
            if (viewportFound) {
              showViewport = false;
              return false;
            }
            left = iconMargin;
          } else if (pixelsIn > cardWidth) {
            percentOver = (pixelsIn - cardWidth) / cardMargin;
            left = Math.round((iconLeft - scroll + $icon.width() - iconMargin) + (iconMargin * percentOver));
          } else if (pixelsIn >= 0) {
            percentOver = (scroll - cardLeft - cardMargin) / cardWidth;
            left = Math.round((iconLeft - scroll - iconMargin) + ($icon.width() * percentOver));
          } else {
            percentOver = (cardMargin + pixelsIn) / cardMargin;
            left = Math.round((iconLeft - scroll - (iconMargin * 2)) + (iconMargin * percentOver));
          }
          leftFound = true;
        }
        var lastCard = ($icon.attr('href') == lastID);
        if ((lastCard || cardArea > rightEdge) && iconHidden) {
         if (!viewportFound) {
           showViewport = false;
         }
         right = $('a.dock-list-scroller.right', $.my.viewport).position().left;
         return false;
        }
        if (lastCard && cardArea <= rightEdge) {
          right = (iconLeft - scroll + $icon.width() - iconMargin) + iconMargin;
          return false;
        } else if (cardArea > rightEdge) {
          if ($icon.not(':visible').length == 1) {
            right = 0;
            return false;
          }
          pixelsIn = (rightEdge - cardLeft);
          if (pixelsIn > cardWidth) {
            percentOver = (pixelsIn - cardWidth) / cardMargin;
            right = Math.round((iconLeft - scroll + $icon.width() - iconMargin) + (iconMargin * percentOver));
          } else if (pixelsIn >= 0) {
            percentOver = (rightEdge - cardLeft - cardMargin) / cardWidth;
            right = Math.round((iconLeft - scroll - iconMargin) + ($icon.width() * percentOver));
          } else {
            percentOver = (cardMargin + pixelsIn) / cardMargin;
            right = Math.round((iconLeft - scroll - iconMargin - (iconMargin / 2)) + (iconMargin * percentOver));
          }
          return false;
        }
      });
      if (showViewport && left > 0) {
        $glass.css({left: left, top: $viewport.offset().top});
        $glass.show();
        $glass.width(Math.round(right - left));
      } else {
        $glass.hide();
      }
    }
  });
  $.extend(true, {
    fluxx: {
      dock: {
        defaults: {
        },
        attrs: {
          'class': 'dock'
        },
        ui: function(options) {
          return $('<div>')
            .attr($.fluxx.dock.attrs)
            .html($.fluxx.util.resultOf([
              $.fluxx.dock.ui.viewport(options),
              $.fluxx.dock.ui.quicklinks(options),
              $.fluxx.dock.ui.lookingGlass(options)
            ]));
        }
      }
    }
  });
  $.fluxx.dock.ui.quicklinks = function (options) {
    return $.fluxx.util.resultOf([
      '<div id="quicklinks">',
          _.map($.fluxx.config.dock.quicklinks, function(qlset) {
            return [
              '<ol class="qllist">',
                _.map(qlset, function(ql) {
                  return $.fluxx.dock.ui.icon.call($.my.dock, ql);
                }),
              '</ol>'
            ];
          }),
      '</div>'
    ]);
  };
  $.fluxx.dock.ui.viewport = function (options) {
    return $.fluxx.util.resultOf([
      '<div id="viewport">',
        '<a class="dock-list-scroller left" href="#" title="Scroll Dock Icons Left">',
          '<span class="arrow">&larr;</span>',
          '<span class="n-cards">0</span>',
        '</a>',
        '<ol id="iconlist"></ol>',
        '<a class="dock-list-scroller right" href="#" title="Scroll Dock Icons Right">',
          '<span class="n-cards">5</span>',
          '<span class="arrow">&rarr;</span>',
        '</a>',
      '</div>'
    ]);
  };
  $.fluxx.dock.ui.lookingGlass = function (option) {
    return '<div id="lookingglass"></div>';
  };
  $.fluxx.dock.ui.popup = function(options) {
    return (!_.isNull(options.popup)
      ? $.fluxx.util.resultOf([
          '<ul>',
            _.map(
              _.flatten($.makeArray(options.popup)),
              function (line) {return ['<li>', line, '</li>'];}
            ),
          '</ul><div class="arrow"/>'
        ])
      : ''
    );
  },
  $.fluxx.dock.ui.icon = function(options) {
    var options = $.fluxx.util.options_with_callback({
      label: '',
      badge: '',
      url:   '',
      popup: null,
      openOn: ['hover'],
      className: 'scroll-to-card',
      type: null
    }, options);

    return $($.fluxx.util.resultOf([
      '<li class="icon ', options.type, '">',
        '<a class="link ', options.className, '" href="', options.url, '" title="', options.label, '">',
          '<span class="label">', options.label, '</span>',
          '<span class="badge">', options.badge, '</span>',
        '</a>',
        '<div class="popup">',
        $.fluxx.dock.ui.popup(options),
        '</div>',
      '</li>'
    ]));
  };

  $(function($){
    $('#stage').live('complete.fluxx.stage', function(e) {
      $.my.footer.addFluxxDock(function(){
        $('.card')
          .live('lifetimeComplete.fluxx.area', function(e){
            $.fluxx.log("dock is bound to lifetimeComplete.fluxx.card");
            $.fluxx.util.itEndsWithMe(e);
          })
         .live('close.fluxx.card', function(e){
            $.fluxx.util.itEndsWithMe(e);
            $.my.dock.removeViewPortIcon({card: $(this)});
          })
          .live('update.fluxx.card', function (e, nUpdate) {
            if (!_.isEmpty(nUpdate) || !$(e.target).data('icon')) return;
            var $card = $(e.target);
            $card.data('icon')
              .updateIconBadge({badge: $card.fluxxCardUpdatesAvailable()});
          });
      });
    });
  });
})(jQuery);