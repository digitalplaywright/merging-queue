class QueuedTaskTest < ActiveSupport::TestCase

  def test_truth
    assert true
  end

  def test_register_definition

    @definition = QueuedTask.queued_task(:test_queued_task) do
      actor :user, :cache => [:full_name]
      act_object :listing, :cache => [:title, :full_address]
      act_target :listing, :cache => [:title]
    end

    assert @definition.is_a?(MergingQueue::Definition)

  end

  def test_publish_new_queued_task
    _user    = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    _queued_task = QueuedTask.publish(:new_enquiry, Time.now, :actor => _user, :act_object => _article, :act_target => _volume)

    assert _queued_task.persisted?
    #_queued_task.should be_an_instance_of QueuedTask

  end

  def test_description
    _user    = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    _description = "this is a test"
    _queued_task = QueuedTask.publish(:test_description, Time.now,  :actor => _user, :act_object => _article, :act_target => _volume,
                                 :description => _description )

    assert _queued_task.description  == _description

  end

  def test_options
    _user    = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    _country = "denmark"
    _queued_task = QueuedTask.publish(:test_option, Time.now, :actor => _user, :act_object => _article, :act_target => _volume,
                                 :country => _country )

    assert _queued_task.options[:country]  == _country

  end

  def test_bond_type
    _user    = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    _queued_task = QueuedTask.publish(:test_bond_type, Time.now, :actor => _user, :act_object => _article, :act_target => _volume)

    assert _queued_task.bond_type  == 'global'

  end

  def test_poll_changes

    _user    = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    QueuedTask.publish(:test_bond_type, Time.now, :actor => _user, :act_object => _article, :act_target => _volume)

    assert QueuedTask.all.size > 0

    QueuedTask.poll_for_changes() do |verb, hash|
      #assert hash[:actor].id == _user.id
    end

    assert QueuedTask.all.size == 0


  end






end