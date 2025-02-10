require 'tk'
require 'open-uri'
require 'json'
require 'uri'

# Create the main window
root = TkRoot.new do
  title "Google Books ISBN Lookup"
  minsize(400, 200)
end

# Label prompting for ISBN input
TkLabel.new(root) do
  text "Enter ISBN:"
  pack('padx' => 10, 'pady' => 10)
end

# TkVariable and entry widget for the ISBN input
isbn_var = TkVariable.new
TkEntry.new(root) do
  textvariable isbn_var
  width 30
  pack('padx' => 10, 'pady' => 5)
end

# Define a method to look up the book information by ISBN
def lookup_isbn(isbn)
  isbn.strip!
  # Build the query URL; note that we prefix the query with "isbn:" so that
  # Google Books searches by ISBN.
  query = URI.encode_www_form_component("isbn:#{isbn}")
  url = "https://www.googleapis.com/books/v1/volumes?q=#{query}"
  response = URI.open(url).read
  JSON.parse(response)
end

# Define a method to extract the title from the API result
def extract_title(result)
  if result['totalItems'] > 0 && result['items']
    volume = result['items'].first
    title = volume['volumeInfo']['title'] || "No title available"
    "Book title: #{title}"
  else
    "No book found for that ISBN."
  end
end

# Button that triggers the API lookup when clicked
TkButton.new(root) do
  text "Search"
  command do
    isbn = isbn_var.value
    if isbn.strip.empty?
      Tk.messageBox(
        'type'    => 'ok',
        'icon'    => 'warning',
        'title'   => 'Input Error',
        'message' => 'Please enter an ISBN.'
      )
      next
    end

    begin
      result = lookup_isbn(isbn)
      message = extract_title(result)
      Tk.messageBox(
        'type'    => 'ok',
        'icon'    => 'info',
        'title'   => 'Lookup Result',
        'message' => message
      )
    rescue StandardError => e
      Tk.messageBox(
        'type'    => 'ok',
        'icon'    => 'error',
        'title'   => 'Error',
        'message' => "An error occurred: #{e.message}"
      )
    end
  end
  pack('padx' => 10, 'pady' => 10)
end

# Start the Tk main event loop
Tk.mainloop
