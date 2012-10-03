jQuery(function($){
  module("card");

  asyncTest("addFluxxCard", 3, function(){
    $('<div>').appendTo($.my.body).hide().fluxxStage(function(){
      $.my.hand.addFluxxCard();
      equals($('.card').length, 1, "there's a card");
      $.my.hand.addFluxxCard(function(e){
        ok(1,"Fired callback " + $(this).attr('id'));
      });
      equals($.my.cards.length, 2, "two cards");
      setTimeout(function(){start(); $.my.stage.removeFluxxStage()},100);
    });
  });
});
