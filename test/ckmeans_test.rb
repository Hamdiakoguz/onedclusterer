require 'test_helper'

# noinspection RubyInstanceMethodNamingConvention
class CkmeansTest < Minitest::Test

  def test_kmax_equals_kmin_if_omitted
    ckmeans = OnedClusterer::Ckmeans.new([1], 1)
    assert_equal(1, ckmeans.kmax)
  end

  def test_kmin_less_or_equal_to_kmax
    assert_raises(ArgumentError) { OnedClusterer::Ckmeans.new([1], 2, 1) }
    end

  def test_kmin_and_kmax_less_or_equal_to_data_size
    assert_raises(ArgumentError) { OnedClusterer::Ckmeans.new([1], 1, 2) }
  end

  TEST_CASES = [
    [
      [1],    # data
      1,      # class count
      [0, 1], # expected bounds
      [[1]]   # expected clusters
    ],
    [
      [1, 1, 1, 1],
      2,
      [0, 1],
      [[1, 1, 1, 1]]
    ],
    [
      [100, 100, 100, 99999],
      2,
      [0, 100, 99999],
      [[100, 100, 100], [99999]]
    ],
    [
      [1, 1, 1, 100, 100, 100, 999, 999],
      [1, 3],
      [0, 100, 999],
      [[1, 1, 1, 100, 100, 100], [999, 999]]
    ],
    [
      [0.1, 1.1, 1.2, 1.6, 2.2, 2.5, 2.7, 2.8, 3, 3.1, 7.1],
      [1, 4],
      [0, 0.1, 1.6, 3.1, 7.1],
      [[0.1], [1.1, 1.2, 1.6], [2.2, 2.5, 2.7, 2.8, 3, 3.1], [7.1]]
    ],
    [
      [1259.61, 2024.82, 1855.75, 1559.04, 1707.65, 1107.1, 2155.8, 9999],
      [2, 4],
      [0, 1259.61, 1855.75, 2155.8, 9999],
      [[1107.1, 1259.61], [1559.04, 1707.65, 1855.75], [2024.82, 2155.8], [9999]]
    ],
  ]

  TEST_CASES.each_with_index do |test_case, index|
    define_method("test_bounds_case_#{index}") do
      data, n, bounds, clusters = test_case
      kmin, kmax = n
      kmax ||= kmin
      ckmeans = OnedClusterer::Ckmeans.new(data, kmin, kmax)
      assert_equal(bounds, ckmeans.bounds)
      assert_equal(clusters, ckmeans.clusters) unless clusters == :skip
    end
  end

end