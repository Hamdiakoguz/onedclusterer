# Onedclusterer

a tiny ruby library for one-dimensional clustering methods.

## Usage

### Ckmeans.1d.dp

A dynamic programming algorithm for optimal one-dimensional k-means clustering. The algorithm minimizes the sum of squares of within-cluster distances. As an alternative to the standard heuristic k-means algorithm, this algorithm guarantees optimality and repeatability.  
https://cran.r-project.org/web/packages/Ckmeans.1d.dp/index.html

```ruby
require 'onedclusterer'
data = [1259.61,2024.82,1855.75,1559.04,1707.65,1107.1,2155.8]
ckmeans = OnedClusterer::Ckmeans.new(data, 1, 7) # chooses an optimal number clusters between 1 and 7
p ckmeans.bounds # => [0, 1259.61, 1855.75, 2155.8]
p ckmeans.clusters # => [[1107.1, 1259.61], [1559.04, 1707.65, 1855.75], [2024.82, 2155.8]]

# exact number of clusters can be requested instead of min and max
ckmeans = OnedClusterer::Ckmeans.new(data, 4)
p ckmeans.bounds # => [0, 1259.61, 1559.04, 1855.75, 2155.8]
p ckmeans.clusters # => [[1107.1, 1259.61], [1559.04], [1707.65, 1855.75], [2024.82, 2155.8]]  
```

### Jenks natural breaks:

The Jenks natural breaks classification method seeks to reduce the variance within classes and maximize the variance between classes.  
http://en.wikipedia.org/wiki/Jenks_natural_breaks_optimization  
http://www.macwright.org/2013/02/18/literate-jenks.html

```ruby
require 'onedclusterer'
data = [1259.61,2024.82,1855.75,1559.04,1707.65,1107.1,2155.8]
jenks = OnedClusterer::Jenks.new(data, 4)
p jenks.bounds # => [0, 1259.61, 1559.04, 1855.75, 2155.8]
p jenks.clusters # => [[1107.1, 1259.61], [1559.04], [1707.65, 1855.75], [2024.82, 2155.8]]
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'onedclusterer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onedclusterer

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Hamdiakoguz/onedclusterer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

