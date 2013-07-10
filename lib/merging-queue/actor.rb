module MergingQueue
  
  module Actor
    extend ActiveSupport::Concern

    included do
      cattr_accessor :queued_task_klass

      has_many :queued_tasks,             :class_name => "QueuedTask", :as => :actor
      has_many :act_object_queued_tasks,  :class_name => "QueuedTask", :as => :act_object
      has_many :act_target_queued_tasks,  :class_name => "QueuedTask", :as => :act_target


    end

    module ClassMethods

      def queued_task_class(klass)
        self.queued_task_klass = klass.to_s
      end

    end


    # Publishes the queued_task to the receivers
    #
    # @param [ Hash ] options The options to publish with.
    #
    # @example publish an queued_task with a act_object and act_target
    #   current_user.publish_queued_task(:enquiry, :act_object => @enquiry, :act_target => @listing)
    #
    def publish_queued_task(name, cur_publish_on, options={})
      cur_publish_on = Time.now + cur_publish_on if cur_publish_on.kind_of?(Fixnum)
      raise "Expected Time type. Got:" + cur_publish_on.class.name  unless cur_publish_on.kind_of?(Time)
      queued_task_class.publish(name, cur_publish_on, {:actor => self}.merge(options))
    end

    def queued_task_class
      @queued_task_klass ||= queued_task_klass ? queued_task_klass.classify.constantize : ::QueuedTask
    end

    def queued_merging_tasks(options = {})

      if options.empty?
        queued_tasks
      else
        queued_tasks.where(options)
      end

    end

  end
  
end