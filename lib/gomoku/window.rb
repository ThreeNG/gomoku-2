module Gomoku
  # Main Gomoku window and game loop
  class Window < Gosu::Window
    def initialize
      super 800, 800, false
      self.caption = 'Gomoku'
      @board = Board.new(self)
      @black_player = Human.new(self, @board, :black)
      @white_player = Human.new(self, @board, :white)
      # @white_player = Computer.new(self, @board, :white)
      # Start a new game
      new_game
    end

    def new_game
      # Reset the board
      @board.reset
      # Black goes first
      @turn = :black
      # Setup flag to indicate a turn needs to be processed
      @done_turn = false
      @winner = false
    end

    def needs_cursor?
      true
    end

    def button_down(id)
      case id
      when Gosu::KbEscape
        close
      when Gosu::MsLeft
        process_click
      end
    end

    def process_click
      if @winner
        # We already have a winner, so start new game
        new_game
      else
        # Get the location of the click
        click_r = Utility.y_to_r(mouse_y)
        click_c = Utility.x_to_c(mouse_x)
        case @turn
        when :black
          @black_player.click(click_r, click_c)
        when :white
          @white_player.click(click_r, click_c)
        end
      end
    end

    def button_up(_id)
    end

    def update
      case @turn
      when :black
        @black_player.update
        move = @black_player.pick_move
      when :white
        @white_player.update
        move = @white_player.pick_move
      end
      # Perform the move
      do_move(move) if move
      # Process the turn if done
      process_turn if @done_turn
    end

    def do_move(move)
      r = move[0]
      c = move[1]
      # Return if not blank
      return unless @board.state[[r, c]] == :empty
      # Perform move
      @board.state[[r, c]] = @turn
      # Update turn
      @turn = Utility.toggle_color(@turn)
      # Update flag
      @done_turn = true
    end

    # Loop through board cells and check winner, break when found
    def process_turn
      Board.each_r_c do |r, c|
        win = @board.check_win(r, c)
        unless win == :none
          @winner = true
          @winner_direction = win
          @winner_r = r
          @winner_c = c
          break
        end
      end
      # Done processing, reset flag
      @done_turn = false
    end

    def draw
      @board.draw
      if @winner
        # Mark the winning sequence
        draw_winner
      else
        # No winner, draw the current player
        case @turn
        when :black
          @black_player.draw
        when :white
          @white_player.draw
        end
      end
    end

    # Draw three adjacent 1px lines to make a single 3px line.
    # Worst code I ever wrote.
    def draw_winner
      case @winner_direction
      when :horizontal
        line_x1_1 = Utility.c_to_x(@winner_c)
        line_y1_1 = Utility.r_to_y(@winner_r) + 20
        line_x1_2 = Utility.c_to_x(@winner_c + 5)
        line_y1_2 = Utility.r_to_y(@winner_r) + 20

        line_x2_1 = line_x1_1
        line_y2_1 = line_y1_1 + 1
        line_x2_2 = line_x1_2
        line_y2_2 = line_y1_2 + 1

        line_x3_1 = line_x1_1
        line_y3_1 = line_y1_1 + 2
        line_x3_2 = line_x1_2
        line_y3_2 = line_y1_2 + 2
      when :vertical
        line_x1_1 = Utility.c_to_x(@winner_c) + 20
        line_y1_1 = Utility.r_to_y(@winner_r)
        line_x1_2 = Utility.c_to_x(@winner_c) + 20
        line_y1_2 = Utility.r_to_y(@winner_r + 5)

        line_x2_1 = line_x1_1 + 1
        line_y2_1 = line_y1_1
        line_x2_2 = line_x1_2 + 1
        line_y2_2 = line_y1_2

        line_x3_1 = line_x1_1 + 2
        line_y3_1 = line_y1_1
        line_x3_2 = line_x1_2 + 2
        line_y3_2 = line_y1_2
      when :diagonal_up
        line_x1_1 = Utility.c_to_x(@winner_c)
        line_y1_1 = Utility.r_to_y(@winner_r + 1)
        line_x1_2 = Utility.c_to_x(@winner_c + 5)
        line_y1_2 = Utility.r_to_y(@winner_r - 4)

        line_x2_1 = line_x1_1
        line_y2_1 = line_y1_1 + 1
        line_x2_2 = line_x1_2 + 1
        line_y2_2 = line_y1_2

        line_x3_1 = line_x1_1 + 1
        line_y3_1 = line_y1_1 + 1
        line_x3_2 = line_x1_2 + 1
        line_y3_2 = line_y1_2 + 1
      when :diagonal_down
        line_x1_1 = Utility.c_to_x(@winner_c)
        line_y1_1 = Utility.r_to_y(@winner_r)
        line_x1_2 = Utility.c_to_x(@winner_c + 5)
        line_y1_2 = Utility.r_to_y(@winner_r + 5)

        line_x2_1 = line_x1_1 + 1
        line_y2_1 = line_y1_1
        line_x2_2 = line_x1_2
        line_y2_2 = line_y1_2 - 1

        line_x3_1 = line_x1_1
        line_y3_1 = line_y1_1 + 1
        line_x3_2 = line_x1_2 - 1
        line_y3_2 = line_y1_2
      end

      # Render the three lines
      draw_line(line_x1_1, line_y1_1, Gosu::Color.argb(0xffff0000),
                line_x1_2, line_y1_2, Gosu::Color.argb(0xffff0000), 2, :default)
      draw_line(line_x2_1, line_y2_1, Gosu::Color.argb(0xffff0000),
                line_x2_2, line_y2_2, Gosu::Color.argb(0xffff0000), 2, :default)
      draw_line(line_x3_1, line_y3_1, Gosu::Color.argb(0xffff0000),
                line_x3_2, line_y3_2, Gosu::Color.argb(0xffff0000), 2, :default)
    end
  end
end
