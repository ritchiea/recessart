module ActionDispatch
  module Session
    class AbstractStore
      private
      # NOTE: this is highly dependent on rails 3 lib/action_dispatch/middleware/session/abstract_store.rb
      # In rails2 we set the session cookie every request.  In rails3, it only sets the cookie when the session is established.
      # This occasionally results in a lost session in Safari.
      def set_cookie(request, options)
        request.cookie_jar[@key] = options
      end
    end
  end
end