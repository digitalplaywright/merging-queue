# QueuedTask model for customisation & custom methods
class QueuedTask < ActiveRecord::Base
  include MergingQueue::QueuedTask

end
