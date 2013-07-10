require 'rails/generators/named_base'

module MergingQueue
  # A generator module with QueuedTask table schema.
  module Generators
    # A base module 
    module Base
      # Get path for migration template
      def source_root
        @_merging_queue_source_root ||= File.expand_path(File.join('../merging_queue', generator_name, 'templates'), __FILE__)
      end
    end
  end
end
