jQuery(function($){
  $.extend($.fluxx.stage.decorators, {
    '.geo_country_select': [
      'change', function(e) {
        var country_id  = $(this).val(),
            $state      = $('.geo_state_select', $(this).parents('form')),
            state_cache = $.fluxx.cache('geo_state_select');
        var states_data = _.select(state_cache, function(i){ if (i.country_id = country_id) return true; });
        $('<option ....></option>').appendTo($state);
      }
    ]
  });
});

