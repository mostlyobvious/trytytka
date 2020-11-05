require "test_helper"

class TrytytkaTest < Minitest::Test
  Event = Struct.new(:event_id, :causation_id)

  class Magic
    def initialize(collected_events)
      @collected_events = collected_events
      @output = ""
    end

    def call(parent_event_id, indent = 0)
      find_children(parent_event_id).each do |child|
        @output << " " * indent + child.event_id + "\n"
        call(child.event_id, indent + 2)
      end
    end

    def find_children(parent_event_id)
      @collected_events.select { |event| event.causation_id == parent_event_id }
    end

    def output
      @output
    end
  end

  def test_this
    collected_events = [
      Event.new("a", nil),
      Event.new("b", "a"),
      Event.new("c", "b"),
      Event.new("d", "c"),
      Event.new("e", "d"),
    ]

    magic = Magic.new(collected_events)
    magic.call(nil)
    assert_equal magic.output, <<~EOM
    a
      b
        c
          d
            e
    EOM
  end

  def test_that
    collected_events = [
      Event.new("a", nil),
      Event.new("b", "a"),
      Event.new("c", "b"),
      Event.new("d", "c"),
      Event.new("e", "a"),
    ]

    magic = Magic.new(collected_events)
    magic.call(nil)
    assert_equal magic.output, <<~EOM
    a
      b
        c
          d
      e
    EOM
  end
end
