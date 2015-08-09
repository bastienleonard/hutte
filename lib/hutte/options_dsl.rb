module Hutte
  # This class is currently only used internally
  class OptionsDsl
    def initialize(options)
      @callbacks = options[:callbacks]
      @callbacks.each do |name|
        instance_eval <<-END, __FILE__, __LINE__ + 1
          def #{name}(&block)
            if block.nil?
              @#{name}
            else
              @#{name} = block
              self
            end
          end
        END
      end
    end
  end
end
