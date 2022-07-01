require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"





before do # performed before all other methods
	@contents = File.readlines("data/toc.txt")
end

get "/" do # shows home page
	@title = "The Adventures of Sherlock Holmes"

	erb :home
end

get '/chapters/:chapter_number' do # shows chapter page (reader page)
	ch_number = params['chapter_number'].to_i # retrieves chapter number from params hash, converts to integer
	@title = "Chapter #{ch_number}: #{@contents[ch_number - 1]}" # Generates title line for page
	
	redirect "/" unless (1..@contents.size).cover? ch_number # Redirects to home page unless chapter_number paramter is between 1 and the size of the ToC array.

	@chapter = File.read "data/chp#{ch_number}.txt" # Retrieves the relevant chapter text

	erb :chapter
end

get '/search' do
	@results = chapters_matching(params[:query]) # Passes return of params[:query] to chapters_matching method
	erb :search
end


not_found do # Redirects to home on an 404
	redirect "/"
end

helpers do
	def highlight_matches(paragraph, query)		
		paragraph.gsub(query, "<strong>#{query}</strong>")
	end

	def in_paragraphs(string) # splits text on newlines, replaces them with paragraph tags.
		arr = string.split("\n\n").each_with_index.map do |line, index| 
			"<p id=paragraph#{index}>#{line}</p>"
		end
		arr.join
	end

  def slugify(text) # replaces whitespace with '-', replaces non-word characters with empty strings
    text.downcase.gsub(/\s+/, "-").gsub(/[^\w-]/, "")
  end
end

def each_chapter #takes a block, iterates over the ToC array.
	@contents.each_with_index do |name, index|
		number = index + 1
		contents = File.read("data/chp#{number}.txt") # Retrieves relevant chapter text as "contents"
		yield number, name, contents # Yields chapter number, chapter name, and the text to the block
	end
end

def chapters_matching(query)
	results = []
	return results if !query || query.empty? # Returns empty arr on if query is falsey or .empty? returns true on query object

	each_chapter do |number, name, contents| # Calls each chapter method, passes chapter num, name, and text as block parameters 
		matches = paragraph_matching(query, contents)
		results << {number: number.to_i, name: name, paragraphs: matches} if contents.include? query
	end
	results
end

def paragraph_matching(query, contents) # Iterates over the paragraphs in a chapter, returning a hash with a corresponding index number for
	# as keys for paragraphs which include the query
	text = contents.split("\n\n")
	matches = {}
	text.each_with_index do | paragraph, index |
		matches[index] = paragraph if paragraph.include?(query)
	end
	matches
end

=begin
Paragraph matching
	Purpose: To return an array of strings which contain the query
	Input: contents - a formatted string of text
	Return: Array of strings, wrapped in <a> tags with links to their relevant chapters

Algorithm:
	Initialize holder hash
	Split contents on newline
	Iterate through array, appending key pairs if the paragraph includes the query 
=end

# Improved Search
	# Use existing method to iterate over each chapter
		# append matching paragraphs to results array, then use said paragraphs in the results view

# get "/" do
#   @files = Dir.glob("public/*.*").map { |file| File.basename(file)}.sort
#   @files.reverse! if params[:sort] == "desc"
#   erb :list
# end