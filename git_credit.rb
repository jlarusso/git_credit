#!/usr/bin/env ruby

# For use in a git repository.
# Pass in a path (directory or file) to determine relative historical contributions by author.
class Credit
  def initialize(target_path, using_old_ruby)
    @target_path = target_path
    @using_old_ruby = using_old_ruby
  end

  # Handle invalid byte sequences in the raw output.
  def encode(str)
    if @using_old_ruby
      # Because ruby 1.8.7 doesn't have String#encode.
      require 'iconv'
      Iconv.conv('UTF-8//IGNORE', 'UTF-8', str + ' ')[0..-2]
    else
      str.encode('utf-8', 'binary', :invalid => :replace, :undef => :replace)
    end
  end

  def stats
    # Get a git log as an array of strings.
    log_lines = encode(`git log --numstat -p #{@target_path}`).split("\n")

    # Discard unwanted lines from log_lines.
    contribute_lines = log_lines.select do |line|
      line[/Author\:\ /] || line[/#{@target_path}/]
    end.delete_if do |line|
      line[/diff/] || line[/\+\+\+/] || line[/---/]
    end

    # Construct hash, keying authors to historical lines of code added.
    raw_stats = {}
    current_author = nil
    contribute_lines.each do |line|
      if line[/Author/]
        author = line.split('<')[0].strip.split.tap(&:shift).join(' ')
        current_author = author
      else
        if raw_stats[current_author]
          raw_stats[current_author] += line.split("\t").first.to_i
        else
          raw_stats[current_author] = line.split("\t").first.to_i
        end
      end
    end

    # Sort stats descending.
    sorted_stats = raw_stats.to_a.sort { |a, b| b[1] <=> a[1] }

    # Total used for determining relative contribution.
    total = sorted_stats.reduce(0) { |sum, stat| sum += stat[1] }.to_f

    # Score stats as percentages.
    sorted_stats.map do |stat|
      if stat[0] && stat[1] # Stupid to check for nil this far down.  Improve log line selection.
        [stat[0], ((stat[1] / total) * 100.0).round]
      else
        nil
      end
    end.compact
  end
end

require 'rubygems'
ruby_version = Gem::Version.new(RUBY_VERSION)
using_old_ruby = ruby_version < Gem::Version.new('1.9.3')
c = Credit.new(ARGV[0], using_old_ruby)
c.stats.each do |stat|
  puts [stat[1], '% ', stat[0]].join
end
