// This is a benchmark for computing primes.
// It toggles central LED on completion.
// Surrounding LEDs are used to mark progress.

module bench (
  input clk,
  output LED[4:0]);

  // WLOG=5 (i.e. 32-bit primes) takes a LOT more time to build...
  localparam WLOG = 4;
  localparam W = 1 << WLOG;
  localparam HI = W - 1;
  localparam MAX = {W{1'd1}};

  localparam LED_STEP_1 = MAX / 5'd16;
  localparam LED_STEP = LED_STEP_1 + (LED_STEP_1 * 5'd16 < MAX ? 1'd1 : 1'd0);
  reg [HI:0] leds_num;

  reg go;
  wire rdy, err;
  wire [HI:0] res;
  reg [HI:0] prime;

  wire rst;

  por por_inst(.clk(clk), .rst(rst));

  primogen #(.WIDTH_LOG(WLOG)) pg(
    .clk(clk),
    .go(go),
    .rst(rst),
    .ready(rdy),
    .error(err),
    .res(res));

  always @(posedge clk) begin
    if (rst) begin
      go <= 0;
    end else begin
      go <= 0;
      // !go - give primogen 1 clock to register inputs
      if (rdy && !err && !go) begin
        go <= 1;
        prime <= res;
      end
    end
  end

  // Show progress

  always @(posedge clk) begin
    if (rst) begin
      leds_num <= 0;
    end else begin
      if (prime > leds_num) begin
        leds_num <= leds_num + LED_STEP;
      end
    end
  end

  assign LED[3:0] = leds_num;
  assign LED[4] = err;  // Overflow

endmodule
