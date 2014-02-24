require "version"

module RSpec
  module Core
    module Set
      module ClassMethods
        # Set @variable_name in a before(:all) block and give access to it
        # via let(:variable_name)
        #
        # Example:
        #
        #   set(:transaction) { Factory(:address) }
        #
        #   it "should be valid" do
        #     transaction.should be_valid
        #   end
        #
        def set(variable_name, &block)
          before(:all) do
            # Create model
            self.class.send(:class_variable_set, "@@__rspec_set_#{variable_name}".to_sym, instance_eval(&block))
          end

          before(:each) do
            model = send(variable_name)
          end

          define_method(variable_name) do
            model = self.class.send(:class_variable_get, "@@__rspec_set_#{variable_name}".to_sym)
            if model.is_a?(ActiveRecord::Base)
              model.class.find(model.id)
            else
              model
            end
          end
        end # set()

      end # ClassMethods

      def self.included(mod) # :nodoc:
        mod.extend ClassMethods
      end
    end # Set

    class ExampleGroup
      include Set
    end # ExampleGroup

  end # Core
end # RSpec
