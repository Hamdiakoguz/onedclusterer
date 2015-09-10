require 'test_helper'

class JenksTest < Minitest::Test

  TEST_CASES = [
    [
      [1],    # data
      1,      # class count
      [0, 1], # expected bounds
      [[1]]   # expected clusters
    ],
    [
      [100,100,100,99999],
      2,
      [0, 100, 99999],
      [[100,100,100], [99999]]
    ],
    [
      [1,1,1,100,100,100,999,999],
      3,
      [0, 1, 100, 999],
      [[1,1,1], [100,100,100], [999,999]]
    ],
    [
      [0.1, 1.1, 1.2, 1.6, 2.2, 2.5, 2.7, 2.8, 3, 3.1, 7.1],
      4,
      [0, 0.1, 1.6, 3.1, 7.1],
      [[0.1], [1.1, 1.2, 1.6], [2.2, 2.5, 2.7, 2.8, 3, 3.1], [7.1]]
    ],
    [
      [1259.61,2024.82,1855.75,1559.04,1707.65,1107.1,2155.8],
      2,
      [0, 1559.04, 2155.8],
      [[1107.1, 1259.61, 1559.04], [1707.65, 1855.75, 2024.82, 2155.8]]
    ],
    [
      [518.39, 656.4, 735.34, 1532.48, 2443.45],
      2,
      [0, 735.34, 2443.45],
      [[518.39, 656.4, 735.34], [1532.48, 2443.45]]
    ]
  ]

  TEST_CASES.each_with_index do |test_case, index|
    define_method("test_bounds_case_#{index}") do
      data, n, bounds, clusters = test_case
      jenks = OnedClusterer::Jenks.new(data, n)
      assert_equal(bounds, jenks.bounds)
      assert_equal(clusters, jenks.clusters) unless clusters == :skip
    end
  end

  def test_class_count_data_size
    assert_raises(ArgumentError) { OnedClusterer::Jenks.new([], 1)}
  end

  def test_class_count_less_than_one
    assert_raises(ArgumentError) { OnedClusterer::Jenks.new([], 0)}
  end
end