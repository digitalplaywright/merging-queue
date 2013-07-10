require 'generators/merging-queue'
require 'rails/generators/active_record'

module MergingQueue
  module Generators
    # QueuedTask generator that creates queued_task model file from template
    class QueuedTaskGenerator < ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => 'queued_task'
      # Create model in project's folder
      def generate_files
        copy_file 'queued_task.rb', "app/models/#{name}.rb"
      end
    end
  end
end
