module JSparrow
  module Interactors
    
    #
    # Class methods to build interactors (Client and Listener).
    #
    class << self

      def new_client
        Client.new(new_connection)
      end

      #
      # Example:
      #
      #   new_listener :as => ListenerClass
      #
      # ou
      #
      #   new_listener(
      #     :listen_to => { :queue => :registered_name_of_queue },
      #     :receive_only_in_criteria => { :selector => "recipient = 'jsparrow-spec'" }
      #     ) do |received_message|

      #     # do something
      #   end
      #
      def new_listener(listener_spec, &on_receive_message)
        is_anonymous_listener = listener_spec[:as].nil?

        if is_anonymous_listener
          new_anonymous_listener(listener_spec, &on_receive_message)
        else
          new_named_listener(listener_spec)
        end
      end

      private

        def new_named_listener(listener_spec)
          listener_spec[:as].new(new_connection)
        end

        def new_anonymous_listener(listener_spec, &on_receive_message)
          listener = Listener.new(new_connection)

          (class << listener; self; end;).class_eval do
            listen_to listener_spec[:listen_to] if listener_spec[:listen_to]
            receive_only_in_criteria listener_spec[:receive_only_in_criteria] if listener_spec[:receive_only_in_criteria]
    
            define_method(:on_receive_message, &on_receive_message)
          end

          listener
        end
        
        def new_connection
          JSparrow::Connection.new
        end
    end
  end
end

def new_jsparrow_client
  JSparrow::Interactors.new_client
end

def new_jsparrow_listener(listener_spec, &on_receive_message)
  JSparrow::Interactors.new_listener(listener_spec, &on_receive_message)
end