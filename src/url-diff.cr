require "uri"
require "./color"
require "pretty_print"

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

  def self.compare(left : String, right : String) : Tuple(String, String, Report)
    report = [] of {String, String?, String?}
    return {left, right, report} if left == right
    a = URI.parse left
    b = URI.parse right
    compare_scheme(report, a, b)
    compare_hostname(report, a, b)
    compare_path(report, a, b)
    compare_query_params(report, a, b)
    return {left, right, report}
  end

  def self.view(args, whitelist = [] of String)
    left, right, diffs = args
    STDOUT.puts Color.underline "comparing:\n"
    STDOUT.puts "#{left}\n\n#{right}\n"

    report = if whitelist.empty? 
      diffs
    else
      diffs.select {|k, lv, rv| whitelist.includes?(k) }
    end

    if diffs.empty?
      STDOUT.puts Color.green "\nno diff" 
      exit(0)
    end

    if report.empty?
      STDOUT.puts Color.red "\nno params matching #{whitelist.join(",")} were found"
      exit(1)
    end
    
    STDOUT.puts Color.blue "\n\ndiffs:\n" if whitelist.empty?
    STDOUT.puts Color.blue "\n\ndiffs(keys: #{whitelist.join(",")}):\n" unless whitelist.empty?

    pretty = PrettyPrint.new(STDOUT)
    
    report.each do |key, left, right|
      pretty.text Color.underline(key) + ":\n"

      if left.nil? && right.is_a?(String)
        pretty.text  "\t" + Color.red("- " + right) + "\n"
      end

      if right.nil? && left.is_a?(String)
        pretty.text  "\t" + Color.green("+ " + left) + "\n"
      end

      if left.is_a?(String) && right.is_a?(String)
        pretty.text  "\t" + Color.green(left) + "\n"
        pretty.text  "\t" + Color.red(right) + "\n"
      end
    end
  end
end
