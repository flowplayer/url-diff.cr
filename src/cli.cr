require "option_parser"
require "./url-diff"

opts = {} of Symbol => String
whitelist = [] of String

parser = OptionParser.parse do |parser|
  parser.banner = <<-BANNER
    version #{Url::Diff::VERSION}
    Usage: url-diff [arguments]
  BANNER
  
  parser.on("-l LEFT", "--left=LEFT", "basis url to compare against") do |left|
    opts[:left] = left
  end
  
  parser.on("-r RIGHT", "--right=RIGHT", "the secondary url") do |right| 
    opts[:right] = right
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
  urls = File.read(opts[:file]).split("\n").reject &.empty?

  if urls.empty?
    raise "urls file was empty"
  end

  if urls.size > 2 || (urls.size > 1 && (opts.has_key?(:left) || opts.has_key?(:right)))
    raise "can only compare 2 urls at once currently"
  end

  opts[:right] = urls.first if opts.has_key?(:left)
  opts[:left]  = urls.first if opts.has_key?(:right)

  unless opts.has_key?(:left) && opts.has_key?(:right)
    opts[:left]  = urls.first
    opts[:right] = urls.last
  end
end

diffs = Url::Diff.compare(
  left:  opts[:left], 
  right: opts[:right])

Url::Diff.view(diffs, 
  whitelist: whitelist)