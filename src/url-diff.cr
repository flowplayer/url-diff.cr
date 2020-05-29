require "uri"
require "./color"
require "pretty_print"

alias Report = Array(Tuple(String, String?, String?))

module Url::Diff
  VERSION = "0.1.1"

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
    baseline = a.query_params.to_h
    against = b.query_params.to_h

    (baseline.keys - against.keys).each do |k|
      unless against.has_key?(k)
        report << {k, baseline[k], nil}
      end
    end

    (against.keys - baseline.keys).each do |k|
      unless baseline.has_key?(k)
        report << {k, nil, against[k]}
      end
    end

    (baseline.keys & against.keys).each do |k|
      unless baseline[k] == against[k]
        report << {k, baseline[k], against[k]}
      end
    end
  end

  def self.compare(baseline : Tuple(String, String), against : Tuple(String,String)) : Tuple(String, String, Report)
    report = [] of {String, String?, String?}
    return {baseline[0], against[0], report} if baseline == against
    a = URI.parse baseline[1]
    b = URI.parse against[1]
    compare_scheme(report, a, b)
    compare_hostname(report, a, b)
    compare_path(report, a, b)
    compare_query_params(report, a, b)
    return {baseline[0], against[0], report}
  end

  def self.compare(baseline : String, against : String)
    compare({baseline, baseline}, {against, against})
  end

  def self.view(args, whitelist = [] of String)
    baseline, against, diffs = args
    STDOUT.puts Color.underline "comparing:\n"
    STDOUT.puts "baseline: #{baseline}\n against: #{against}\n"

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
    
    report.each do |key, baseline, against|
      pretty.text Color.underline(key) + ":\n"

      if baseline.nil? && against.is_a?(String)
        pretty.text  "\t - " + Color.red(against) + "\n"
      end

      if against.nil? && baseline.is_a?(String)
        pretty.text  "\t + " + Color.green(baseline) + "\n"
      end

      if baseline.is_a?(String) && against.is_a?(String)
        pretty.text  "\t + " + Color.green(baseline) + "\n"
        pretty.text  "\t - " + Color.red(against) + "\n"
      end
    end
  end
end
