# graph_drawer.rb
module GraphDrawer
  def self.draw_graph(canvas, values, canvas_width, canvas_height, margin_left, margin_right, margin_top, margin_bottom)
    # Clear any existing drawings on the canvas
    canvas.delete('all')
    return if values.empty?

    # Calculate drawing area dimensions
    draw_width  = canvas_width  - margin_left - margin_right
    draw_height = canvas_height - margin_top  - margin_bottom

    # Draw Y-axis (vertical) and X-axis (horizontal)
    canvas.create('line',
                  margin_left, margin_top,
                  margin_left, canvas_height - margin_bottom,
                  '-fill', 'black')
    canvas.create('line',
                  margin_left, canvas_height - margin_bottom,
                  canvas_width - margin_right, canvas_height - margin_bottom,
                  '-fill', 'black')

    # Label the axes
    canvas.create('text',
                  canvas_width / 2, canvas_height - margin_bottom + 20,
                  '-text', 'X Axis', '-fill', 'black')
    canvas.create('text',
                  margin_left - 20, canvas_height / 2,
                  '-text', 'Y Axis', '-fill', 'black')

    # Determine the maximum value for scaling the Y-axis (avoid division by zero)
    max_value = values.max
    max_value = 1 if max_value == 0

    # Calculate horizontal spacing between data points
    n = values.size
    x_spacing = (n > 1) ? (draw_width.to_f / (n - 1)) : draw_width

    # Compute screen coordinates for each data point and draw them
    points = []
    values.each_with_index do |v, i|
      x = margin_left + i * x_spacing
      # Invert the y-axis so that higher values appear higher on the canvas
      y = canvas_height - margin_bottom - (v.to_f / max_value) * draw_height
      points << [x, y]

      # Draw a small circle (oval) to mark the data point
      r = 3
      canvas.create('oval',
                    x - r, y - r, x + r, y + r,
                    '-fill', 'red',
                    '-outline', 'red')
    end

    # Draw lines connecting the data points
    points.each_cons(2) do |(x1, y1), (x2, y2)|
      canvas.create('line',
                    x1, y1, x2, y2,
                    '-fill', 'blue',
                    '-width', 2)
    end
  end
end