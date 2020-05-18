require "uri"
require "./colors"

alias Report = Array(Tuple(String, String?, String?))

module Url::Diff
  VERSION = "0.1.0"

  def self.compare_scheme(report : Report, a : URI, b : URI)
    return if a.scheme == b.scheme
    report << {":scheme", a.scheme, b.scheme}
  end

  def self.compare_hostname(report : Report, a : URI, b : URI)
    return if  a.hostname == b.hostname
    report << {":hostname", a.hostname, b.hostname}
  end

  def self.compare_path(report : Report, a : URI, b : URI)
    return if  a.path == b.path
    report << {":path", a.path, b.path}
  end

  def self.compare_query_params(report : Report, a : URI, b : URI)
    left = a.query_params.to_h
    right = b.query_params.to_h

    left.keys.each do |k|
      unless right.has_key?(k)
        report << {k, left[k], nil}
      end
    end

    right.keys.each do |k|
      unless left.has_key?(k)
        report << {k, nil, right[k]}
      end
    end

    (left.keys & right.keys).each do |k|
      unless left[k] == right[k]
        report << {k, left[k], right[k]}
      end
    end
  end

  def self.compare(left : String, right : String)
    report = [] of {String, String?, String?}
    return report if left == right
    a = URI.parse left
    b = URI.parse right
    compare_scheme(report, a, b)
    compare_hostname(report, a, b)
    compare_path(report, a, b)
    compare_query_params(report, a, b)
    return report
  end

  def self.view(report : Report)
    STDOUT.puts Color.green "no diff" if report.empty?
    
    report.each do |key, left, right|
      STDOUT.puts key + ":\n"

      if left.nil? && right.is_a?(String)
        STDOUT.puts  "\t" + Color.red("- " + right) + "\n"
      end

      if right.nil? && left.is_a?(String)
        STDOUT.puts  "\t" + Color.green("+ " + left) + "\n"
      end

      if left.is_a?(String) && right.is_a?(String)
        STDOUT.puts  "\t" + Color.green(left) + "\n"
        STDOUT.puts  "\t" + Color.red(right) + "\n"
      end
    end
  end
end
