require 'matrix'
require_relative 'clusterer'

module OnedClusterer
  # [Jenks natural breaks optimization](http://en.wikipedia.org/wiki/Jenks_natural_breaks_optimization)
  #
  # Adapted from javascript implementation: https://gist.github.com/tmcw/4977508
  class Jenks
    include Clusterer

    attr_reader :data, :n_classes

    # @param data one dimensional numerical array
    # @param n_classes number of classes
    def initialize(data, n_classes)
      @data = data.sort
      @n_classes = n_classes

      raise ArgumentError, "Number of classes can not be greater than size of data array." if n_classes > data.size
      raise ArgumentError, "Number of classes can not be less than 1." if n_classes < 1

      @lower_class_limits, @variance_combinations = matrices
    end

    # get clustered array with `n` number of clusters
    def clusters(n = n_classes)
      bounds_iter = bounds(n).drop(1).each_with_index
      result = Array.new(n) { [] }

      data.each do |value|
        bound, index = bounds_iter.peek
        if value > bound
          bounds_iter.next
          index += 1
        end
        result[index].push(value)
      end

      result
    end

    # get bounds array for `n` number of classes
    def bounds(n = n_classes)
      raise ArgumentError, "n must be lesser than or equal to n_classes: #{n_classes}" if n > n_classes

      k = data.size
      bounds = []

      # the calculation of classes will never include the upper and
      # lower bounds, so we need to explicitly set them
      bounds[n] = data.last
      bounds[0] = 0

      for countNum in n.downto 2
        id = @lower_class_limits[k][countNum]
        bounds[countNum - 1] = data[id - 2]
        k = id - 1
      end

      bounds
    end

    private

    # Compute the matrices required for Jenks breaks. These matrices
    # can be used for any classing of data with `classes <= n_classes`
    def matrices
      rows = data.size
      cols = n_classes

      # in the original implementation, these matrices are referred to
      # as `LC` and `OP`
      # * lower_class_limits (LC): optimal lower class limits
      # * variance_combinations (OP): optimal variance combinations for all classes
      lower_class_limits = *Matrix.zero(rows + 1, cols + 1)
      variance_combinations = *Matrix.zero(rows + 1, cols + 1)

      # the variance, as computed at each step in the calculation
      variance = 0

      for i in 1..cols
        lower_class_limits[1][i]    = 1
        variance_combinations[1][i] = 0
        for j in 2..rows
          variance_combinations[j][i] = Float::INFINITY
        end
      end

      for l in 2..rows
        sum         = 0 # `SZ` originally. this is the sum of the values seen thus far when calculating variance.
        sum_squares = 0 # `ZSQ` originally. the sum of squares of values seen thus far
        w           = 0 # `WT` originally. This is the number of data points considered so far.

        for m in 1..l
          lower_class_limit = l - m + 1 # `III` originally
          val = data[lower_class_limit - 1]

          # here we're estimating variance for each potential classing
          # of the data, for each potential number of classes. `w`
          # is the number of data points considered so far.
          w += 1

          # increase the current sum and sum-of-squares
          sum += val
          sum_squares += (val ** 2)

          # the variance at this point in the sequence is the difference
          # between the sum of squares and the total x 2, over the number
          # of samples.
          variance = sum_squares - (sum ** 2) / w

          i4 = lower_class_limit - 1 # `IV` originally
          if i4 != 0
            for j in 2..cols
             # if adding this element to an existing class
             # will increase its variance beyond the limit, break
             # the class at this point, setting the lower_class_limit
             # at this point.
             if variance_combinations[l][j] >= (variance + variance_combinations[i4][j - 1])
               lower_class_limits[l][j] = lower_class_limit
               variance_combinations[l][j] = variance +
                 variance_combinations[i4][j - 1]
             end
            end
          end
        end

        lower_class_limits[l][1] = 1
        variance_combinations[l][1] = variance
      end

      [lower_class_limits, variance_combinations]
    end
  end
end
