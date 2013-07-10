class DefinitionTest < ActiveSupport::TestCase

  def definition_dsl
    dsl = MergingQueue::DefinitionDSL.new(:new_enquiry)
    dsl.actor(:User)
    dsl.act_object(:Article)
    dsl.act_target(:Volume)
    dsl
  end

  def test_initialization
    _definition_dsl = definition_dsl
    _definition     = MergingQueue::Definition.new(_definition_dsl)

    assert _definition.actor      == :User
    assert _definition.act_object == :Article
    assert _definition.act_target == :Volume

  end

  def test_register_definition_and_return_new_definition

    assert MergingQueue::Definition.register(definition_dsl).is_a?(MergingQueue::Definition)

  end

  def test_register_invalid_definition

    assert MergingQueue::Definition.register(false)  == false

  end

  def test_return_registered_definitions

    MergingQueue::Definition.register(definition_dsl)
    assert MergingQueue::Definition.registered.size > 0

  end

  def test_return_definition_by_name
    assert MergingQueue::Definition.find(:new_enquiry).name == :new_enquiry

  end

  def test_raise_exception_if_invalid_queued_task

    assert_raises(MergingQueue::InvalidQueuedTask){ MergingQueue::Definition.find(:unknown_queued_task) }

  end

end