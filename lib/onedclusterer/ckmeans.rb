require 'matrix'
require_relative 'clusterer'

module OnedClusterer

 # Ckmeans clustering is an improvement on heuristic-based clustering
 # approaches like Jenks. The algorithm was developed in
 # [Haizhou Wang and Mingzhou Song](http://journal.r-project.org/archive/2011-2/RJournal_2011-2_Wang+Song.pdf)
 # as a [dynamic programming](https://en.wikipedia.org/wiki/Dynamic_programming) approach
 # to the problem of clustering numeric data into groups with the least
 # within-group sum-of-squared-deviations.
 #
 # Minimizing the difference within groups - what Wang & Song refer to as
 # `withinss`, or within sum-of-squares, means that groups are optimally
 # homogenous within and the data is split into representative groups.
 # This is very useful for visualization, where you may want to represent
 # a continuous variable in discrete color or style groups. This function
 # can provide groups that emphasize differences between data.
 #
 # being a dynamic approach, this algorithm is based on two matrices that
 # store incrementally-computed values for squared deviations and backtracking
 # indexes.
 #
 # This implementation is ported from original c++ implementation.
 #
 ## References
 # _Ckmeans.1d.dp: Optimal k-means Clustering in One Dimension by Dynamic
 # Programming_ Haizhou Wang and Mingzhou Song ISSN 2073-4859
 #
 # from []The R Journal Vol. 3/2, December 2011](http://journal.r-project.org/archive/2011-2/RJournal_2011-2.pdf)

  class Ckmeans
    include Clusterer

    attr_reader :data, :kmin, :kmax, :cluster_details

    # Input:
    #  data -- a vector of numbers, not necessarily sorted
    #  kmin -- the minimum number of clusters expected
    #  kmax -- the maximum number of clusters expected
    # If only kmin is given exactly kmin clusters will be returned
    # else algorithm chooses an optimal number between Kmin and Kmax
    def initialize(data, kmin, kmax = kmin)
      @data_size = data.size
      @data = data.sort # All arrays here is considered starting at position 1, position 0 is not used.
      @kmin = kmin
      @unique = data.uniq.size
      @kmax = @unique < kmax ? @unique : kmax

      raise ArgumentError, "kmin can not be greater than kmax." if kmin > kmax
      raise ArgumentError, "kmin can not be greater than data size." if kmin > @data_size
      raise ArgumentError, "kmax can not be greater than data size." if kmax > @data_size
    end

    # returns clustered data as array and sets :cluster_details
    def clusters
      @clusters_result ||=begin
        if @unique <= 1 # A single cluster that contains all elements
          return [data]
        end

        rows = @data_size
        cols = kmax

        distance = *Matrix.zero(cols + 1, rows + 1) # 'D'
        backtrack = *Matrix.zero(cols + 1, rows + 1) # 'B'

        fill_dp_matrix(data.insert(0, nil), distance, backtrack)

        # Choose an optimal number of levels between Kmin and Kmax
        kopt = select_levels(data, backtrack, kmin, kmax)
        backtrack = backtrack[0..kopt]

        results = []
        backtrack(backtrack) do |k, left, right|
          results[k] = data[left..right]
        end
        results.drop(1)
      end
    end

    def bounds
      @bounds ||= clusters.map { |cluster| cluster.last }.insert(0, 0)
    end

    private

    def backtrack(matrix)
      right = matrix[0].size - 1

      for k in (matrix.size - 1).downto 1
        left = matrix[k][right]

        yield k, left, right

        if k > 1
          right = left - 1
        end
      end
    end

    def fill_dp_matrix(data, distance, backtrack)
      for i in 1..kmax
        distance[i][1] = 0.0
        backtrack[i][1] = 1
      end

      for k in 1..kmax
        mean_x1 = data[1]

        for i in ([2,k].max)..@data_size
          if k == 1
            distance[k][i] = distance[k][i-1] + (i-1) / Float(i) * (data[i] - mean_x1) ** 2
            mean_x1 = ((i - 1) * mean_x1 + data[i]) / Float(i)
            backtrack[1][i] = 1
          else
            d = 0.0 # the sum of squared distances from x_j ,. . ., x_i to their mean
            mean_xj = 0.0

            for j in i.downto k
              d = d + (i - j) / Float(i - j + 1) * (data[j] - mean_xj) ** 2
              mean_xj = (data[j] + (i - j) * mean_xj) / Float(i - j + 1)

              if j == i
                distance[k][i] = d
                backtrack[k][i] = j
                distance[k][i] += distance[k - 1][j - 1] unless j == 1
              else
                if j == 1
                  if d <= distance[k][i]
                    distance[k][i] = d
                    backtrack[k][i] = j
                  end
                elsif d + distance[k - 1][j - 1] < distance[k][i]
                    distance[k][i] = d + distance[k - 1][j - 1]
                    backtrack[k][i] = j
                end
              end
            end
          end
        end
      end

    end

    # Choose an optimal number of levels between Kmin and Kmax
    def select_levels(data, backtrack, kmin, kmax)
      return kmin if kmin == kmax

      method = :normal # "uniform" or "normal"

      kopt = kmin

      base = 1 # The position of first element in x: 1 or 0.
      n = data.size - base

      max_bic = 0.0

      for k in kmin..kmax
        cluster_sizes = []
        kbacktrack = backtrack[0..k]
        backtrack(kbacktrack) do |cluster, left, right|
          cluster_sizes[cluster] = right - left + 1
        end

        index_left = base
        index_right = 0

        likelihood = 0
        bin_left, bin_right = 0
        for i in 0..(k-1)
          points_in_bin = cluster_sizes[i + base]
          index_right = index_left + points_in_bin - 1

          if data[index_left] < data[index_right]
            bin_left = data[index_left]
            bin_right = data[index_right]
          elsif data[index_left] == data[index_right]
            bin_left = index_left == base ? data[base] : (data[index_left-1] + data[index_left]) / 2
            bin_right = index_right < n-1+base ? (data[index_right] + data[index_right+1]) / 2 : data[n-1+base]
          else
            raise "ERROR: binLeft > binRight"
          end

          bin_width = bin_right - bin_left
          if method == :uniform
            likelihood += points_in_bin * Math.log(points_in_bin / bin_width / n)
          else
            mean = 0.0
            variance = 0.0

            for j in index_left..index_right
              mean += data[j]
              variance += data[j] ** 2
            end
            mean /= points_in_bin
            variance = (variance - points_in_bin * mean ** 2) / (points_in_bin - 1) if points_in_bin > 1

            if variance > 0
              for j in index_left..index_right
                likelihood += - (data[j] - mean) ** 2 / (2.0 * variance)
              end
              likelihood += points_in_bin * (Math.log(points_in_bin / Float(n))
                - 0.5 * Math.log( 2 * Math::PI * variance))
            else
              likelihood += points_in_bin * Math.log(1.0 / bin_width / n)
            end
          end

          index_left = index_right + 1
        end

        # Compute the Bayesian information criterion
        bic = 2 * likelihood - (3 * k - 1) * Math.log(Float(n))

        if k == kmin
          max_bic = bic
          kopt = kmin
        elsif bic > max_bic
          max_bic = bic
          kopt = k
        end

      end

      kopt
    end

  end

end
