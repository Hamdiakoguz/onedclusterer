module OnedClusterer

  # Common methods fo all
  module Clusterer

    # Returns zero based index of cluster which a value belongs to
    # value must be in data array
    def classify(value)
      raise ArgumentError, "value: #{value} must be in data array" unless @data.include?(value)

      bounds[1..-1].index { |bound| value <= bound }
    end

  end
end