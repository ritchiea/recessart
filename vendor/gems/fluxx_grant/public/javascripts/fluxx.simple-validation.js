(function($){
  $.fn.extend({
    initValidator: function() {
      var rules = {};
      $('.required').each(function() {
        $input = $(':input', this);
        rules[$input.attr('name')] = {required: true, email: ($input.attr('name').match(/email/) != null)}
      });

      $('#new_loi').validate({
        rules: rules
      });
    }
	});
})(jQuery);

$(document).ready(function() {
	$.fn.initValidator();
});
