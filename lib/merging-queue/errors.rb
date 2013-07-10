module MergingQueue
  
  class MergingQueueError < StandardError
  end
  
  class InvalidQueuedTask < MergingQueueError
  end
  
  # This error is raised when an act_object isn't defined
  # as an actor, act_object or act_target
  #
  # Example:
  #
  # <tt>InvalidField.new('field_name')</tt>
  class InvalidData < MergingQueueError
    attr_reader :message

    def initialize message
      @message = "Invalid Data: #{message}"
    end

  end
  
  # This error is raised when trying to store a field that doesn't exist
  #
  # Example:
  #
  # <tt>InvalidField.new('field_name')</tt>
  class InvalidField < MergingQueueError
    attr_reader :message

    def initialize message
      @message = "Invalid Field: #{message}"
    end

  end
  
  class QueuedTaskNotSaved < MergingQueueError
  end
  
  class NoFollowersDefined < MergingQueueError
  end
  
end