(function($){
  function Storage(options) {
    options = $.fluxx.util.options_with_callback({},options);
    this.name = options.name;
    this.data = options.data;
    this.type = options.type || options.client_store_type;
    this.url  = options.url;
    
  }
  $.extend(Storage.prototype, {
    asPost: function(){
      return {
        client_store: {
          name: this.name,
          data: $.toJSON(this.data),
          client_store_type: this.type
        }
      }
    }
  });

  $.extend(true, $.fluxx, {
    storage: {
      createStore: function(options, callback) {
        options = $.fluxx.util.options_with_callback({type: 'dashboard'},options,callback);
        var store = new Storage(options);
        $.ajax({
          type: 'POST',
          url: '/client_stores',
          data: store.asPost(),
          complete: function (xhr, status) {
            if (xhr.status) {
              store.url = xhr.getResponseHeader('Location');
              callback(store);
            }
          }
        })
      },
      getStored: function(options, callback){
        options = $.fluxx.util.options_with_callback({type: 'dashboard', name: ''},options,callback);
        $.ajax($.extend(
          ( options.url ?
            {url: options.url} :
            {
              url: '/client_stores.json/',
              data: $.extend(
                (options.name ? {name: options.name} : {}),
                {client_store_type: options.type}
              )
            }
          ),
          {
            type: 'GET',
            dataType: 'json',
            success: function(data, xhr, status) {
            options.callback(_.map($.makeArray(data), function(i) {
                var entry = i.client_store;
                entry.data = $.parseJSON(entry.data);
                return new Storage($.extend(entry,{url: i.url}));
              }));
            }
          }
        ));
      },
      updateStored: function(options, callback) {
        options = $.fluxx.util.options_with_callback({},options,callback);
        $.ajax({
          type: 'PUT',
          url: options.store.url,
          data: options.store.asPost(),
          complete: function (xhr, status) {
            callback(options.store);
          }
        })
      },
      deleteStored: function(options, callback) {
        options = $.fluxx.util.options_with_callback({},options,callback);
        $.ajax({
          type: 'DELETE',
          url: options.store.url,
          complete: function (xhr, status) {
            callback(options.store);
          }
        })
      },
    },
    
    config: {
      storage: {
      }
    },
  });
})(jQuery);
