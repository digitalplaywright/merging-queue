# MergingQueue

MergingQueue is a simple gem for grouping tasks by type and time using the ActiveRecord ODM framework and
background jobs.

This gem is inspired by Streama by Christopher Pappas.

[![Build Status](https://secure.travis-ci.org/digitalplaywright/merging-queue.png)](http://travis-ci.org/digitalplaywright/merging-queue) [![Dependency Status](https://gemnasium.com/digitalplaywright/merging-queue.png)](https://gemnasium.com/digitalplaywright/merging-queue) [![Code Climate](https://codeclimate.com/github/digitalplaywright/merging-queue.png)](https://codeclimate.com/github/digitalplaywright/merging-queue)


## Install

    gem install merging-queue

## Usage

### Create migration for queued_tasks and migrate the database (in your Rails project):

```ruby
rails g merging-queue:migration
rake db:migrate
```

### Define Queued Task

Create an QueuedTask model and define the queued_tasks and the fields you would like to cache within the queued_task.

An queued_task consists of an actor, a verb, an act_object, and a target.

``` ruby
class QueuedTask < ActiveRecord::Base
  include MergingQueue::QueuedTask

  queued_task :new_enquiry do
    actor        :User
    act_object   :Article
    act_target   :Volume
  end
end
```

The queued_task verb is implied from the queued_task name, in the above example the verb is :new_enquiry

The act_object may be the entity performing the queued_task, or the entity on which the queued_task was performed.
e.g John(actor) shared a video(act_object)

The target is the act_object that the verb is enacted on.
e.g. Geraldine(actor) posted a photo(act_object) to her album(target)

This is based on the QueuedTask Streams 1.0 specification (http://queued_taskstrea.ms)

### Setup Actors

Include the Actor module in a class and override the default followers method.

``` ruby
class User < ActiveRecord::Base
  include MergingQueue::Actor

end
```



### Publishing QueuedTask

In your controller or background worker:

``` ruby
current_user.publish_queued_task(:new_enquiry, :act_object => @enquiry, :target => @listing)
```
  
This will publish the queued_task to the mongoid act_objects returned by the #followers method in the Actor.


## Retrieving QueuedTask

To retrieve all queued_task for an actor

``` ruby
current_user.queued_tasks
```
  
To retrieve and filter to a particular queued_task type

``` ruby
current_user.queued_tasks(:verb => 'new_enquiry')
```

#### Options

Additional options can be required:

``` ruby
class QueuedTask < ActiveRecord::Base
  include MergingQueue::QueuedTask

  queued_task :new_enquiry do
    actor        :User
    act_object   :Article
    act_target   :Volume
    option       :country
    option       :city
  end
end
```

The option fields are stored using the ActiveRecord 'store' feature.


#### Bond type

A verb can have one bond type. This bond type can be used to classify and quickly retrieve
queued_task feed items that belong to a particular aggregate feed, like e.g the global feed.

``` ruby
class QueuedTask < ActiveRecord::Base
  include MergingQueue::QueuedTask

  queued_task :new_enquiry do
    actor        :User
    act_object   :Article
    act_target   :Volume
    bond_type    :global
  end
end
```

### Poll for changes and empty queue

There is a poll changes interface that will group tasks by first actor and then verb. 

```ruby
QueuedTask.poll_for_changes() do |verb, hash|
  #verb is the verb the changes are group by
  #hash has format: {:actor          => _actor /* actor is the  */, 
  #                  :act_objects    => act_objects    /* all objects from matching tasks */, 
  #                  :act_object_ids => act_object_ids /* all object ids from matching tasks */,
  #                  :act_targets    => act_targets /* all targets from  matching tasks */ , 
  #                  :act_target_ids => act_target_ids /* all target ids from matching tasks}
end
```




