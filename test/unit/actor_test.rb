class ActorTest < ActiveSupport::TestCase


  def test_publish_queued_task

    _user = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    queued_task = _user.publish_queued_task(:new_enquiry, Time.now, :act_object => _article, :act_target => _volume)

    assert queued_task.persisted?

  end

  def test_retrieves_the_stream_for_an_actor
    _user    = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    _user.publish_queued_task(:new_enquiry, Time.now, :act_object => _article, :act_target => _volume)
    _user.publish_queued_task(:new_enquiry, Time.now, :act_object => _article, :act_target => _volume)

    assert _user.queued_tasks.size == 2

  end


  def test_retrieves_the_stream_for_a_particular_queued_task_type
    _user = User.create()
    _article = Article.create()
    _volume  = Volume.create()

    _user.publish_queued_task(:new_enquiry, Time.now, :act_object => _article, :act_target => _volume)
    _user.publish_queued_task(:new_enquiry, Time.now, :act_object => _article, :act_target => _volume)
    _user.publish_queued_task(:test_bond_type, Time.now, :act_object => _article, :act_target => _volume)

    assert _user.queued_merging_tasks(:verb      => 'new_enquiry').size == 2
    assert _user.queued_merging_tasks(:bond_type => 'global').size == 1

  end




end