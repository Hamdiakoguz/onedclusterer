module OnedClusterer

  # Common methods fo all
  module Clusterer

    # Returns zero based index of cluster which a value belongs to
    # value must be in data array
    def classify(value)
      raise ArgumentError, "value: #{value} must be in data array" unless @data.include?(value)

      bounds[1..-1].index { |bound| value <= bound }
    end

    # Returns inclusive interval limits
    def intervals
      first, *rest = bounds.each_cons(2).to_a
      [first, *rest.map {|lower, upper| [data[data.rindex(lower) + 1] , upper] }]
    end
  end
end