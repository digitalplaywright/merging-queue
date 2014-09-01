module MergingQueue
  module QueuedTask
    extend ActiveSupport::Concern

    included do

      store :options

      belongs_to :actor,      :polymorphic => true
      belongs_to :act_object, :polymorphic => true
      belongs_to :act_target, :polymorphic => true

      validates_presence_of :actor_id, :actor_type, :verb
    end

    module ClassMethods

      def poll_for_changes()
    
        _cur_time = DateTime.now.utc

        ::QueuedTask.where('state = ? AND publish_on <= ?', 'initial',  _cur_time).pluck(:actor_id, :verb).each do |_actor_id,_verb|
    
          changes_for_actor = ::QueuedTask.where('state = ? AND actor_id = ? AND verb = ? AND publish_on <= ?', 'initial', _actor_id, _verb, _cur_time )
    
          begin
            yield  _verb, accumulate_changes(changes_for_actor)
    
            changes_for_actor.destroy_all
    
          rescue ActiveRecord::RecordNotFound
          end
    
    
    
        end
      end

      #---- general helpers

      #---- add up all actors, act_objects and act_targets in the search results.
      #     it does not matter what is where
      def accumulate_changes(search_result)
        act_targets    = []
        act_target_ids = []
        act_objects    = []
        act_object_ids = []

        _actor = search_result.first.actor

        search_result.each do |result|
          result.update_attributes(:state => 'pending')

          act_object = result.act_object
          act_target = result.act_target

          if act_object != nil && !act_object_ids.include?(act_object.id)
            act_objects    << act_object
            act_object_ids << act_object.id

          end

          if act_target != nil && !act_target_ids.include?(act_target.id)
            act_targets    << act_target
            act_target_ids << act_target.id

          end

        end

        {:actor => _actor, :act_objects => act_objects, :act_object_ids => act_object_ids,
         :act_targets => act_targets, :act_target_ids => act_target_ids}
      end

      # Defines a new QueuedTask2 type and registers a definition
      #
      # @param [ String ] name The name of the queued_task
      #
      # @example Define a new queued_task
      #   queued_task(:enquiry) do
      #     actor :user, :cache => [:full_name]
      #     act_object :enquiry, :cache => [:subject]
      #     act_target :listing, :cache => [:title]
      #   end
      #
      # @return [Definition] Returns the registered definition
      def queued_task(name, &block)
        definition = MergingQueue::DefinitionDSL.new(name)
        definition.instance_eval(&block)
        MergingQueue::Definition.register(definition)
      end

      # Publishes an queued_task using an queued_task name and data
      #
      # @param [ String ] verb The verb of the queued_task
      # @param [ Hash ] data The data to initialize the queued_task with.
      #
      # @return [MergingQueue::QueuedTask2] An QueuedTask instance with data
      def publish(verb, cur_publish_on, data)
        new.publish({:verb => verb, :publish_on => cur_publish_on}.merge(data))
      end

    end



    # Publishes the queued_task to the receivers
    #
    # @param [ Hash ] options The options to publish with.
    #
    def publish(data = {})
      assign_properties(data)

      self
    end


    def refresh_data
      save(:validate => false)
    end

    protected

    def assign_properties(data = {})

      self.verb      = data.delete(:verb)

      write_attribute(:publish_on, data[:publish_on])
      data.delete(:publish_on)

      self.state = 'initial'

      [:actor, :act_object, :act_target].each do |type|

        cur_object = data[type]

        unless cur_object
          if definition.send(type.to_sym)
            raise verb.to_json
            #raise MergingQueue::InvalidData.new(type)
          else
            next

          end
        end

        class_sym = cur_object.class.name.to_sym

        raise MergingQueue::InvalidData.new(class_sym) unless definition.send(type) == class_sym

        case type
          when :actor
            self.actor = cur_object
          when :act_object
            self.act_object = cur_object
          when :act_target
            self.act_target = cur_object
          else
            raise "unknown type"
        end

        data.delete(type)

      end

      [:grouped_actor].each do |group|


        grp_object = data[group]

        if grp_object == nil
          if definition.send(group.to_sym)
            raise verb.to_json
            #raise MergingQueue::InvalidData.new(group)
          else
            next

          end
        end

        grp_object.each do |cur_obj|
          raise MergingQueue::InvalidData.new(class_sym) unless definition.send(group) == cur_obj.class.name.to_sym

          self.grouped_actors << cur_obj

        end

        data.delete(group)

      end

      cur_bond_type = definition.send(:bond_type)

      if cur_bond_type
        write_attribute( :bond_type, cur_bond_type.to_s )
      end

      def_options = definition.send(:options)
      def_options.each do |cur_option|
        cur_object = data[cur_option]

        if cur_object

          if cur_option == :description
            self.description = cur_object
          else
            options[cur_option] = cur_object
          end
          data.delete(cur_option)

        else
          #all options defined must be used
          raise Streama::InvalidData.new(cur_object[0])
        end
      end

      if data.size > 0
        raise "unexpected arguments: " + data.to_json
      end



      self.save


    end

    def definition
      @definition ||= MergingQueue::Definition.find(verb)
    end


  end
end
