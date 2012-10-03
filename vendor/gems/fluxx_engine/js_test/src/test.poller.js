jQuery(function($){
  module("poller");

  test("$.fluxxPoller()", function(){
    var poller = $.fluxxPoller();
    var interfaceElements = _.reduce(
      ['start', 'stop', 'state', 'id', 'message', 'subscribe'],
      0,
      function (i, m) { return !_.isUndefined(poller[m]) ? ++i : i}
    );
    equals(interfaceElements, 6, 'Has expected interface elements.');
    
    var poller2 = $.fluxxPoller();
    ok(poller.id != poller2.id, "Unique poller IDs");
    
    equals(poller.stateText(), 'off', 'poller is off');
    poller.start();
    equals(poller.stateText(), 'on', 'poller is on');
    poller.stop();
    equals(poller.stateText(), 'off', 'poller is off');    
  });
  
  test("Client-Side Polling Implementation", 3, function(){
    var poller = $.fluxxPoller({
      implementation: 'polling',
      url: '/rtu_polling'
    });
    equals(poller.implementation, 'polling', 'Using polling');
    equals(poller.url, '/rtu_polling', 'Endpoint configured correctly');

    var interfaceElements = _.reduce(
      ['_timeoutID', '_start', '_stop'],
      0,
      function (i, m) { return !_.isUndefined(poller[m]) ? ++i : i}
    );
    equals(interfaceElements, 3, 'Has expected interface elements.');
  });

  asyncTest("Do polling", 4, function () {
    var poller = $.fluxxPoller({
      url: '/rtu_polling',
      interval: 1,
      update: function (e, data, status) {
        ok(data, "Update Callback Triggered");
        ok(data.last_id, "We have a counter: " + data.last_id);
        poller.stop();
      }
    });
    poller.subscribe(function(e, data, status){
      equals(e.target.id, poller.id, 'e.target is poller object');
      ok(data.last_id, "We have a counter: " + data.last_id);
    });
    poller.start();
    setTimeout(function(){start();}, 2200);
  });
  
  test("Destroy Pollers", 3, function () {
    var totalPollers = $.fluxxPollers().length;
    equals($.fluxx.pollers.length, totalPollers, "We have the right number of pollers");
    var first = _.first($.fluxxPollers());
    first.destroy();
    equals($.fluxxPollers().length, totalPollers - 1, "One less poller.");
    $.destroyFluxxPollers();
    equals($.fluxxPollers().length, 0, "No more pollers");
  });
});
