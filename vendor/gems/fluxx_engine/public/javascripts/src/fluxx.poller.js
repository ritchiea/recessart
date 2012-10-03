(function($){

  var STATES = [ 'off', 'on' ],
      S_OFF  = 0,
      S_ON   = 1;

  function Poller(options) {
    var options = $.fluxx.util.options_with_callback($.fluxx.poller.defaults,options);
    options.id  = options.id();
    $.extend(this, $.fluxx.implementations[options.implementation]);
    $.extend(this, options);
    $.fluxx.pollers.push(this);
    this.$ = $(this);
    this.subscribe(this.update);
    this._init();
  }
  $.extend(Poller.prototype, {
    stateText: function () {
      return STATES[this.state];
    },
    start: function () {
      if (this.state == S_ON) return;
      this.state = S_ON;
      this._start();
      /*$(window)
        .focusin(this.start)
        .focusout(this.stop);*/
      this.$.trigger('start.fluxx.poller');
    },
    stop: function () {
      if (this.state == S_OFF) return;
      this.state = S_OFF;
      this._stop();
      /*$(window)
        .unbind('focusin', this.start)
        .unbind('focusout', this.stop);*/
    },
    poll: function () {
      this._poll(0);
    },
    removeEventListener: function () {
    },
    message: function (data, status) {
      ('update.fluxx.poller')
      this.$.trigger('update.fluxx.poller', data, status);
    },
    subscribe: function (fn) {
      this.$.bind('update.fluxx.poller', fn);
    },
    destroy: function () {
      $.fluxx.pollers = _.without($.fluxx.pollers, this);
      delete this;
    }
  });

  $.extend({
    fluxxPoller: function(options) {
      return new Poller(options);
    },
    fluxxPollers: function() {
      return $.fluxx.pollers;
    },
    destroyFluxxPollers: function () {
      _.each($.fluxx.pollers, function (poller) {
        poller.destroy();
      });
    }
  });

  $.extend(true, {
    fluxx: {
      pollers: [],
      poller: {
        defaults: {
          implementation: 'polling',
          state: S_OFF,
          update: $.noop,
          id: function(){ return _.uniqueId('fluxx-poller-'); }
        }
      },
      implementations: {
        polling: {
          interval: $.fluxx.util.seconds(15),
          last_id: '',
          decay: 1.2, /* not used presently */
          maxInterval: $.fluxx.util.minutes(60),

          _timeoutID: null,
          _init: function () {
            _.bindAll(this, 'start', 'stop', '_poll');
            this.last_id = parseInt($.cookie('last_id'));
          },
          _poll: function (intervalOverride) {
            if (this.state == S_OFF) return;
            var i = (typeof(intervalOverride) == 'number' ? intervalOverride : this.interval);
            var doPoll = _.bind(function(){
//              $.fluxx.log("this.last_id = " + this.last_id + ' which is NaN? ' + _.isNaN(this.last_id));
              try {
                $.ajax({
                  url: this.url,
                  dataType: 'json',
                  data: (!_.isNaN(this.last_id) ? {last_id: this.last_id} : {}),
                  success: _.bind(function(data, status){
                    if (typeof data != 'undefined' && data) {
                      this.last_id = parseInt(data.last_id);
                      $.cookie('last_id', this.last_id);
                      this.message(data, status);
                    }
                  }, this),
                 complete: _.bind(function(XMLHttpRequest, textStatus) {
                   this._poll();
                 }, this)});
              } catch(e) {
                $.fluxx.log('Warning: Caught exception polling: ' + e);
                this._poll();
              }
            }, this);
            this._timeoutID = setTimeout(doPoll, i);
          },
          _start: function () {
            this.$
              .unbind('start.fluxx.poller.polling')
              .bind('start.fluxx.poller.polling', _.bind(this._poll, this))
          },
          _stop: function () {
            clearTimeout(this._timeoutID);
          }
        }
      }
    }
  });

})(jQuery);
