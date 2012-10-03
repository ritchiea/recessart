jQuery(function($){
  module("core");

  test("$.my", 1, function(){
    ok($.isPlainObject($.my), "jQuery Selector Cache Initialized")
  });
  
  test("$.fluxx.util.options_with_callback", 13, function(){
    var empty = $.fluxx.util.options_with_callback();
    ok($.isPlainObject(empty), "recieved an object");
    same(empty.callback, $.noop, "callback is a noop");
    equals(_.keys(empty).length, 1, "just one key");
    
    var cb     = function(){$.noop()};
    var cbOnly = $.fluxx.util.options_with_callback({},{},cb);
    ok($.isPlainObject(cbOnly), "recieved an object");
    same(cbOnly.callback, cb, "callback is cb()");
    equals(_.keys(cbOnly).length, 1, "just one key");
    
    var cbOpts = $.fluxx.util.options_with_callback({},{callback: cb});
    ok($.isPlainObject(cbOpts), "recieved an object");
    same(cbOpts.callback, cb, "callback is cb()");
    equals(_.keys(cbOpts).length, 1, "just one key");
    
    var allOut = $.fluxx.util.options_with_callback(
      {title: 'Foo', url: '/'},
      {title: 'Bar', other: 'Thing'},
      function(){return 'Called back.'}
    );
    equals(allOut.callback(), 'Called back.', 'Callback retained.');
    equals(allOut.title, 'Bar', 'Changed with options');
    equals(allOut.url, '/', 'Stayed the same');
    equals(allOut.other, 'Thing', 'Added options remained');
  });
  
  test("_.callAll", 1, function(){
    _.callAll(function(n) {equals(n, 1, "argument passed properly")})(1);
  });
  
  test("_.addUp", function(){
    $('<div>').addClass('addUpTest').hide().css({width: 200, margin: 20}).appendTo($('body'));
    $('<div>').addClass('addUpTest').hide().css({width: 200, margin: 10}).appendTo($('body'));
    var $addUpTest = $('.addUpTest');
    equals(_.addUp($addUpTest, 'width'), 400);
    equals(_.addUp($addUpTest, 'outerWidth', true), 460);
  });
  
  test("_.intersectProperties", function() {
    var intersect = _.intersectProperties(
      {a: null, b: true},
      {a: 1,    b: true}
    );
    equals(_.keys(intersect).length, 1, "Just one intersection");
    same(intersect, {b: true}, "It was b");
  });
  test("_.isFilterMatch", function() {
    var filter = {foo: null, bar: 'baz'};
    var object = {foo: 'is', bar: 'baz'};
    ok(_.isFilterMatch(filter, object), "Yes, they match");
    
    filter = {foo: null, bar: 'baz'};
    object = {foo: 'is', bar: 'bax'};
    ok(!_.isFilterMatch(filter, object), "No, they don't match");

    filter = {foo: null, bar: null};
    object = {foo: 'is', bar: 'bax'};
    ok(_.isFilterMatch(filter, object), "Yes, they match null filters");

    filter = {};
    object = {foo: 'is', bar: 'bax'};
    ok(_.isFilterMatch(filter, object), "Yes, they match no filters");

    filter = {other: null};
    object = {foo: 'is', bar: 'bax'};
    ok(_.isFilterMatch(filter, object), "Yes, they match, null mismatched filters");

    filter = {other: null, foo: 'not'};
    object = {foo: null, bar: 'bax'};
    ok(!_.isFilterMatch(filter, object), "No, they don't, null test on defined filter");
  });
});
