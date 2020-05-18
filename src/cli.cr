require "option_parser"
require "./url-diff"

opts = {} of Symbol => String

OptionParser.parse do |parser|
  parser.banner = <<-BANNER
    version #{Url::Diff::VERSION}
    Usage: url-diff [arguments]
  BANNER
  
  parser.on("-l LEFT", "--left=LEFT", "left url to diff") do |left|
    opts[:left] = left
  end
  
  parser.on("-r RIGHT", "--right=RIGHT", "right url for diff") do |right| 
    opts[:right] = right
  end

  parser.on("-f FILE", "--file=FILE", "new line delimited pair of urls to compare") do |file|
    opts[:file] = file
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

Url::Diff.view Url::Diff.compare(
  left:  opts[:left], 
  right: opts[:right])