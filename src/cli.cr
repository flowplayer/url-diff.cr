require "option_parser"
require "./url-diff"

opts = {} of Symbol => String|Tuple(String, String)
whitelist = [] of String

parser = OptionParser.parse do |parser|
  parser.banner = <<-BANNER
    version #{Url::Diff::VERSION}
    Usage: url-diff [arguments]
  BANNER
  
  parser.on("-b baseline", "--baseline=baseline", "basis url to compare against") do |baseline|
    opts[:baseline] = baseline
  end
  
  parser.on("-a against", "--against=against", "the secondary url") do |against| 
    opts[:against] = against
  end

  parser.on("-f FILE", "--file=FILE", "new line delimited pair of urls to compare") do |file|
    opts[:file] = file
  end

  parser.on("-k KEYS", "--keys=KEYS", "whitelist of diff keys to report about") do |keys|
    whitelist.concat keys.split(",")
  end
  
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  
  parser.invalid_option do |flag|
    STDERR.puts Color.red "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

if opts.empty?
  puts parser
  puts opts
  exit(1)
end

if opts.has_key?(:file)
  file = opts[:file]
  raise "file name must be a string" unless file.is_a?(String)

  urls = File.read(file).split("\n").reject{|line| line.empty? || line.starts_with?("#") }
  
  if urls.empty?
    raise "urls file was empty"
  end

  if urls.size > 2 || (urls.size > 1 && (opts.has_key?(:baseline) || opts.has_key?(:against)))
    raise "can only compare 2 urls at once currently"
  end

  labeled_urls = urls.map {|line|
    if info = /^(?<label>\w+)=(?<url>.*)$/.match(line)
      label = info.try &.["label"]
      url   = info.try &.["url"]
      {label, url}
    else
      {line, line}
    end
  }

  opts[:against]  = labeled_urls.first if opts.has_key?(:baseline)
  opts[:baseline] = labeled_urls.first if opts.has_key?(:against)

  unless opts.has_key?(:baseline) && opts.has_key?(:against)
    opts[:baseline] = labeled_urls.first
    opts[:against]  = labeled_urls.last
  end
end

baseline = opts[:baseline]
against  = opts[:against]

raise "baseline must be a Tuple(String, String)" unless baseline.is_a?(Tuple(String, String))
raise "against must be a Tuple(String, String)" unless against.is_a?(Tuple(String, String))

diffs = Url::Diff.compare(baseline: baseline, against: against)

Url::Diff.view(diffs, 
  whitelist: whitelist)