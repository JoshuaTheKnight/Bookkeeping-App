require 'tk'
require_relative 'graph_drawer'  # Loads the GraphDrawer module

# Create the main window for input controls
root = TkRoot.new do
  title "Graph Plotter - Input"
  minsize(520, 150)
end

# Create a frame for input controls (label, entry, and button)
input_frame = TkFrame.new(root) do
  pack('side' => 'top', 'fill' => 'x', 'padx' => 10, 'pady' => 10)
end

# Label for instructions
TkLabel.new(input_frame) do
  text "Enter values (comma-separated):"
  pack('side' => 'left')
end

# TkVariable to hold the text entry value
values_var = TkVariable.new

# Entry widget for the user to input numeric values
TkEntry.new(input_frame) do
  textvariable values_var
  width 40
  pack('side' => 'left', 'padx' => 5)
end

# Button to trigger graph plotting
plot_button = TkButton.new(input_frame) do
  text "Plot Graph"
  pack('side' => 'left', 'padx' => 5)
end

# When the Plot Graph button is clicked, create a popup window with the graph
plot_button.command = proc do
  input = values_var.value
  # Split the input string by commas and remove extra whitespace
  values_str = input.split(',').map(&:strip)
  
  begin
    # Convert the string values to floats
    values = values_str.map { |s| Float(s) }
  rescue ArgumentError
    Tk.messageBox(
      'type'    => 'ok',
      'icon'    => 'error',
      'title'   => 'Invalid Input',
      'message' => 'Please enter valid numeric values separated by commas.'
    )
    next
  end
  
  # Define dimensions for the popup canvas
  canvas_width  = 480
  canvas_height = 300

  # Create a new Toplevel window (popup) for the graph
  popup = TkToplevel.new(root) do
    title "Graph Plotter - Graph"
    minsize(520, 450)
  end

  # Create a canvas widget in the popup window to display the graph
  canvas = TkCanvas.new(popup) do
    width canvas_width
    height canvas_height
    background "white"
    pack('side' => 'top', 'padx' => 10, 'pady' => 10)
  end

  # Define margins for drawing within the canvas
  margin_left   = 40
  margin_right  = 20
  margin_top    = 20
  margin_bottom = 40

  # Draw the graph using our helper method from GraphDrawer module
  GraphDrawer.draw_graph(canvas, values, canvas_width, canvas_height,
                         margin_left, margin_right, margin_top, margin_bottom)
end

# Start the Tk event loop
Tk.mainloop