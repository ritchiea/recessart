(function($){
  $.fn.extend({
    initFluxxDashboard: function(options, complete) {
      $.fluxx.dashboard.ui.call(this)
        .prependTo($('.actions', $.my.header))
        .populateDashboards(_.bind($.fn.loadDashboard, $('.picker')));
    },
    populateDashboards: function (callback) {
      var options = $.fluxx.util.options_with_callback({},callback);
      $.my.dashboardPicker = $('.picker', this);
      $.my.dashboardPicker.getDashboards(options.callback);
    },
    loadDashboard: function () {
      var $item = $('.item:first a', $(this));
      if ($.cookie('dashboard')) {
        $found = $('.item a[href="'+$.cookie('dashboard')+'"]', $(this));
        if ($found.length)
          $item = $found;
      }
      $.cookie('dashboard', $item.click().attr('href'));
      $item.parent().addClass('selected').siblings().removeClass('selected');
    },

    getDashboards: function (callback) {
      var options = $.fluxx.util.options_with_callback({},callback);
      $.fluxx.storage.getStored({type: 'dashboard'}, function(items) {
        if (items && items.length) {
          _.each(items, function(item){
            $($.fluxx.dashboard.ui.pickerItem({url: item.url, name: item.name}))
              .find('a').data('dashboard', item).end()
              .appendTo($.my.dashboardPicker);
          });
          options.callback();
        } else {
          $.fluxx.storage.createStore($.fluxx.config.dashboard.default_dashboard, function(item) {
            $($.fluxx.dashboard.ui.pickerItem({url: item.url, name: item.name}))
              .find('a').data('dashboard', item).end()
              .appendTo($.my.dashboardPicker);
            options.callback();
          });
        }
      });
    },
    saveDashboard: function(){
      var $dashboard = $('.selected a', $.my.dashboardPicker);
      if ($dashboard.data('locked')) return this;

      var dashboard = $dashboard.data('dashboard');
      if (!dashboard)
        return;
      if (!dashboard.data)
        dashboard.data = {"cards": []};
      dashboard.data.cards = $.my.stage.serializeFluxxCards();
      $dashboard.parent().addClass('saving');
      $.fluxx.storage.updateStored({store: dashboard}, function(dashboard){
        $dashboard.data('dashboard', dashboard).parent().removeClass('saving');
      });
//      $.fluxx.log($dashboard.data('dashboard'), $.my.stage.serializeFluxxCards());

      return this;
    },
    newDashboard: function(e) {
      $(e.target).after(
        $('<input type="text" class="new-dashboard-input"/>').keypress(function(e){
          if (e.which == 13 || e.which == 10) {
            e.preventDefault();
            var name = $(e.target).val();
            if (name.length > 0) {
              var dashboard = jQuery.extend(true, {cards: []}, $.fluxx.config.dashboard.default_dashboard);
              dashboard.name = name;

              $.fluxx.storage.createStore(dashboard, function(item) {
                $($.fluxx.dashboard.ui.pickerItem({url: item.url, name: item.name}))
                .find('a').data('dashboard', item)
                .end()
                .appendTo($.my.dashboardPicker)
                .find('a').trigger('click');
              });
              $(e.target).hide().prev().show();
            } else {
              $(e.target).hide().prev().show();
            }
          }
        }).select()
      ).hide();
      $('.new-dashboard-input').focus();
    },
    openManager: function() {
     var manager = $.fluxx.dashboard.manager;
     manager.init();
    },
    deleteDashboard: function(dashboard) {
     $.fluxx.storage.deleteStored({store: dashboard}, function(item) {
       var $li = $('a.to-dashboard[href*="' + dashboard.url + '"]').parent().remove();
       if ($li.hasClass('selected')) {
         var $first = $('a.to-dashboard').first();
         if ($first.length > 0)
           $first.click();
         else {
           $('.dashboard').remove();
           $.my.header.initFluxxDashboard();
           $('a.simplemodal-close').click();
         }
       }
     });
    },
    renameDashboard: function(dashboard, name) {
      dashboard.name = name;
      $.fluxx.storage.updateStored({store: dashboard}, function(dashboard){});
      $('a.to-dashboard[href*="' + dashboard.url + '"]').html(name);
    }
  });

  $.extend(true, {
    fluxx: {
      config: {
        dashboard: {
          enabled: true,
          default_dashboard: {
            type: 'dashboard',
            name: 'Default',
            data: {cards: []},
            url: '#default'
          }
        }
      },
      dashboard: {
        attrs: {
        },
        defaults: {
        },
        lastSave: {},
        ui: function(optoins) {
          return $('<li>')
            .addClass('dashboard')
            .attr($.fluxx.dashboard.attrs)
            .html($.fluxx.util.resultOf([
              '<li>',
                '<span class="label">Dashboard:</span>',
                '<ul class="picker">',
                  '<li class="combo"><div>&#9650;</div><div>&#9660;</div></li>',
                  '<li class="new"><a href="#" class="new-dashboard">New</a></li>',
                  '<li class="manage"><a href="#" class="manage-dashboard">Manage</a></li>',
                '</ul>',
              '</li>'
            ]))
        },
        manager: {
          init: function () {

            var $dashboards = $.my.dashboardPicker
              .find('.item')
              .clone(true)
              .wrapAll('<ul class="manager-list" />')
              .parent()
              .before('<h1 class="manager-title">My Dashboards</h1>');

            $dashboards.find('li').each(function() {
              var $item = $('a', $(this));
              var dashboard = $item.data('dashboard');
              $item.after('<ul class="actions">' +
                  '<li><a href="#" class="rename-dashboard"></a></li>' +
                 '<li><a href="#" class="delete-dashboard"></a></li>' +
                 '</ul><div class="manager-card-count">' +
                 dashboard.data.cards.length +
                 ' cards</div>');
            });
            $dashboards.modal({
              closeHTML: "<a href='#' title='Close' class='modal-close'>x</a>",
              position: ["15%",],
              overlayId: 'manager-overlay',
              containerId: 'manager-container',
              onOpen: this.open,
              onClose: this.close
            });
          },
          open: function(dialog) {
            dialog.overlay.fadeIn(200, function () {
              dialog.container.fadeIn(200, function () {
                dialog.data.fadeIn(200)
              });
            });
          },
          close: function(dialog) {
            dialog.data.fadeOut(200, function () {
              dialog.container.fadeOut(200, function () {
                dialog.overlay.fadeOut(200, function () {
                  $.modal.close();
                });
              });
            });
          }
        }
      },
    }
  });
  $.fluxx.dashboard.ui.pickerItem = function(options) {
    return $.fluxx.util.resultOf([
      '<li data-tick="&#10003;" class="item">',
        '<a class="to-dashboard" href="#', options.url, '">',
          options.name,
        '</a>',
      '</li>'
    ]);
  };

  $('#stage').live('complete.fluxx.stage', function(e) {
    $.my.header.initFluxxDashboard();
  });

  $('.area').live('lifetimeComplete.fluxx.area', function(e) {
    var $area = $(this).fluxxCardArea();
    if ($area.data('history') && ($area.data('history')[0].type.toUpperCase() == 'GET' && ($area.hasClass('detail') || $area.hasClass('listing'))) && !$(this).fluxxCard().fromClientStore()) {
        $(this).saveDashboard();
    }
  });
  $('.card').live('unload.fluxx.area', function(e) { $(this).saveDashboard(); });

})(jQuery);
