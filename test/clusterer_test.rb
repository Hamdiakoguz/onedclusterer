require 'test_helper'

# noinspection RubyInstanceMethodNamingConvention
class ClustererTest < Minitest::Test

  [OnedClusterer::Jenks, OnedClusterer::Ckmeans].each do |klass|
    class_name = klass.name.split("::").last
    define_method("test_classify_#{class_name}") do
      test_classify(klass)
      end

    define_method("test_intervals_#{class_name}") do
      test_intervals(klass)
    end
  end

  private

  def test_classify(klass)
    data = [0, 0, 0, 100, 100, 100, 99999]
    clusterer = klass.new(data, 3)
    assert_equal(0, clusterer.classify(0))
    assert_equal(1, clusterer.classify(100))
    assert_equal(2, clusterer.classify(99999))
    assert_raises(ArgumentError) { clusterer.classify(123)}
  end

  def test_intervals(klass)
    data = [0, 0, 1, 100, 100, 100, 99999]
    intervals = klass.new(data, 3).intervals
    expected = [[0, 1], [100, 100], [99999, 99999]]
    assert_equal(expected, intervals)
  end

end